import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateWeeklyPlanDto,
  UpdateWeeklyPlanDto,
} from '../dto/weekly-plan.dto';
import { TaskMediaService } from './task-media.service';
import { ExerciseConfigService } from '../../exercise-config/services/exercise-config.service';
import type { RequestContext } from '../../common/types/request-context.type';
import {
  WeeklyPlanStatus,
  WeeklyPlan,
  DayPlan,
  Task,
  TaskAttachment,
  TaskMedia,
  Media,
  ExerciseConfig,
  WorkoutProfile,
} from 'generated/prisma/client';

type FullTaskAttachment = TaskAttachment & {
  taskMedia: TaskMedia & { media: Media };
};

export interface FullTask extends Task {
  attachments: FullTaskAttachment[];
  exerciseConfig: (ExerciseConfig & { media: Media }) | null;
}

export interface FullDayPlan extends DayPlan {
  tasks: FullTask[];
}

export interface FullWeeklyPlan extends WeeklyPlan {
  dayPlans: FullDayPlan[];
}

/** Shared nested include: day plans → tasks → attachments → library media. */
const weeklyPlanInclude = {
  dayPlans: {
    orderBy: { dayIndex: 'asc' as const },
    include: {
      tasks: {
        orderBy: { sequenceIndex: 'asc' as const },
        include: {
          attachments: {
            orderBy: { sequenceIndex: 'asc' as const },
            include: { taskMedia: { include: { media: true } } },
          },
          exerciseConfig: {
            include: { media: true },
          },
        },
      },
    },
  },
};

@Injectable()
export class WeeklyPlanService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskMediaService: TaskMediaService,
    private readonly exerciseConfigService: ExerciseConfigService,
  ) {}

  async create(
    profileId: string,
    dto: CreateWeeklyPlanDto,
    ctx: RequestContext,
  ) {
    // 1. Verify profile exists
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id: profileId },
    });
    if (!profile || profile.isDeleted) {
      throw new NotFoundException(
        `Workout profile with ID ${profileId} not found`,
      );
    }

    // 2. Validate ownership (trainer or admin)
    this.checkTrainerOrAdminAccess(profile, ctx);

    // 2b. Every referenced library media item must exist and be usable.
    const referencedMediaIds = dto.days.flatMap((d) =>
      (d.tasks || []).flatMap((t) =>
        (t.attachments || []).map((a) => a.taskMediaId),
      ),
    );
    await this.taskMediaService.assertUsable(referencedMediaIds, ctx);

    // 2c. Every referenced exercise config must exist and be active.
    const referencedConfigIds = dto.days.flatMap((d) =>
      (d.tasks || []).map((t) => t.exerciseConfigId),
    );
    await this.exerciseConfigService.assertAllUsable(referencedConfigIds);

    // 3. Prepare the nested day plans structure
    const status = dto.activateImmediately
      ? WeeklyPlanStatus.ACTIVE
      : WeeklyPlanStatus.UPCOMING;
    const now = new Date();
    const effectiveFrom = dto.activateImmediately ? now : null;

    // Check unique dayIndex values in input
    const dayIndicesInInput = dto.days.map((d) => d.dayIndex);
    const uniqueIndices = new Set(dayIndicesInInput);
    if (uniqueIndices.size !== dayIndicesInInput.length) {
      throw new ConflictException('Duplicate day indices are not allowed');
    }

    // 4. Run in transaction
    const newPlan = await this.prisma.$transaction(async (tx) => {
      if (dto.activateImmediately) {
        // Archive existing active plan
        const activePlan = await tx.weeklyPlan.findFirst({
          where: {
            workoutProfileId: profileId,
            status: WeeklyPlanStatus.ACTIVE,
          },
        });
        if (activePlan) {
          await tx.weeklyPlan.update({
            where: { id: activePlan.id },
            data: {
              status: WeeklyPlanStatus.ARCHIVED,
              effectiveTo: now,
            },
          });
        }
      }

      // Create new plan with nested days, tasks, attachments (media refs)
      const createdPlan = await tx.weeklyPlan.create({
        data: {
          name: dto.name,
          workoutProfileId: profileId,
          status,
          effectiveFrom,
          createdById: ctx.userId,
          notes: dto.notes || undefined,
          dayPlans: {
            create: [1, 2, 3, 4, 5, 6, 7].map((i) => {
              const incomingDay = dto.days.find((d) => d.dayIndex === i);
              const isRestDay = incomingDay ? incomingDay.isRestDay : true;
              const label = incomingDay ? incomingDay.label : undefined;
              const tasks =
                !isRestDay && incomingDay?.tasks ? incomingDay.tasks : [];

              return {
                dayIndex: i,
                label,
                isRestDay,
                tasks: {
                  create: tasks.map((t) => ({
                    sequenceIndex: t.sequenceIndex,
                    name: t.name,
                    description: t.description || undefined,
                    machineDetails: t.machineDetails || undefined,
                    notes: t.notes || undefined,
                    sets: t.sets,
                    reps: t.reps,
                    restSeconds: t.restSeconds || undefined,
                    tempo: t.tempo || undefined,
                    exerciseConfigId: t.exerciseConfigId || undefined,
                    attachments: {
                      create: (t.attachments || []).map((a) => ({
                        taskMediaId: a.taskMediaId,
                        caption: a.caption || undefined,
                        sequenceIndex: a.sequenceIndex,
                        createdById: ctx.userId,
                      })),
                    },
                  })),
                },
              };
            }),
          },
        },
        include: weeklyPlanInclude,
      });

      if (dto.activateImmediately) {
        // Update WorkoutProfile pointer and reset currentDayIndex cursor
        await tx.workoutProfile.update({
          where: { id: profileId },
          data: {
            activeWeeklyPlanId: createdPlan.id,
            currentDayIndex: 1,
          },
        });
      }

      return createdPlan;
    });

    return this.mapToResponse(newPlan as unknown as FullWeeklyPlan);
  }

  async findAll(
    profileId: string,
    page = 1,
    pageSize = 20,
    ctx: RequestContext,
  ) {
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id: profileId },
    });
    if (!profile || profile.isDeleted) {
      throw new NotFoundException(
        `Workout profile with ID ${profileId} not found`,
      );
    }

    this.checkProfileAccess(profile, ctx);

    const skip = (page - 1) * pageSize;

    const [total, plans] = await Promise.all([
      this.prisma.weeklyPlan.count({ where: { workoutProfileId: profileId } }),
      this.prisma.weeklyPlan.findMany({
        where: { workoutProfileId: profileId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: pageSize,
        include: {
          _count: {
            select: { dayPlans: true },
          },
        },
      }),
    ]);

    const data = plans.map((p) => ({
      id: p.id,
      name: p.name,
      status: p.status,
      effectiveFrom: p.effectiveFrom,
      effectiveTo: p.effectiveTo,
      createdById: p.createdById,
      dayPlanCount: p._count.dayPlans,
    }));

    return {
      data,
      plans: data,
      meta: {
        total,
        page,
        pageSize,
      },
    };
  }

  async findOne(id: string, ctx: RequestContext) {
    const plan = await this.prisma.weeklyPlan.findUnique({
      where: { id },
      include: {
        workoutProfile: true,
        ...weeklyPlanInclude,
      },
    });

    if (!plan || plan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Weekly plan with ID ${id} not found`);
    }

    this.checkProfileAccess(plan.workoutProfile, ctx);

    return this.mapToResponse(plan as unknown as FullWeeklyPlan);
  }

  async update(id: string, dto: UpdateWeeklyPlanDto, ctx: RequestContext) {
    const plan = await this.prisma.weeklyPlan.findUnique({
      where: { id },
      include: { workoutProfile: true },
    });
    if (!plan || plan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Weekly plan with ID ${id} not found`);
    }

    this.checkTrainerOrAdminAccess(plan.workoutProfile, ctx);

    const updated = await this.prisma.weeklyPlan.update({
      where: { id },
      data: {
        name: dto.name,
        notes: dto.notes,
      },
      include: weeklyPlanInclude,
    });

    return this.mapToResponse(updated as unknown as FullWeeklyPlan);
  }

  async activate(id: string, ctx: RequestContext) {
    const plan = await this.prisma.weeklyPlan.findUnique({
      where: { id },
      include: { workoutProfile: true },
    });
    if (!plan || plan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Weekly plan with ID ${id} not found`);
    }

    if (plan.status !== WeeklyPlanStatus.UPCOMING) {
      throw new ConflictException(
        `Only UPCOMING plans can be activated. Current status is ${plan.status}`,
      );
    }

    this.checkTrainerOrAdminAccess(plan.workoutProfile, ctx);

    const now = new Date();

    const activatedPlan = await this.prisma.$transaction(async (tx) => {
      // Archive current active plan if any
      const activePlan = await tx.weeklyPlan.findFirst({
        where: {
          workoutProfileId: plan.workoutProfileId,
          status: WeeklyPlanStatus.ACTIVE,
        },
      });
      if (activePlan) {
        await tx.weeklyPlan.update({
          where: { id: activePlan.id },
          data: {
            status: WeeklyPlanStatus.ARCHIVED,
            effectiveTo: now,
          },
        });
      }

      // Activate this plan
      const updatedPlan = await tx.weeklyPlan.update({
        where: { id },
        data: {
          status: WeeklyPlanStatus.ACTIVE,
          effectiveFrom: now,
        },
        include: weeklyPlanInclude,
      });

      // Update WorkoutProfile pointer & reset cursor
      await tx.workoutProfile.update({
        where: { id: plan.workoutProfileId },
        data: {
          activeWeeklyPlanId: updatedPlan.id,
          currentDayIndex: 1,
        },
      });

      return updatedPlan;
    });

    return this.mapToResponse(activatedPlan as unknown as FullWeeklyPlan);
  }

  async remove(id: string, ctx: RequestContext) {
    const plan = await this.prisma.weeklyPlan.findUnique({
      where: { id },
      include: { workoutProfile: true },
    });
    if (!plan || plan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Weekly plan with ID ${id} not found`);
    }

    if (plan.status !== WeeklyPlanStatus.UPCOMING) {
      throw new ConflictException(
        `Only UPCOMING plans can be deleted. Current status is ${plan.status}`,
      );
    }

    this.checkTrainerOrAdminAccess(plan.workoutProfile, ctx);

    await this.prisma.weeklyPlan.delete({
      where: { id },
    });

    return { success: true };
  }

  private checkProfileAccess(profile: WorkoutProfile, ctx: RequestContext) {
    if (ctx.isAdmin) return;

    const isOwnerClient =
      ctx.profileId && ctx.profileId === profile.clientProfileId;
    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;

    if (!isOwnerClient && !isAssignedTrainer) {
      throw new ForbiddenException(
        'You do not have permission to access this weekly plan',
      );
    }
  }

  private checkTrainerOrAdminAccess(
    profile: WorkoutProfile,
    ctx: RequestContext,
  ) {
    if (ctx.isAdmin) return;

    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;
    if (!isAssignedTrainer) {
      throw new ForbiddenException(
        'Only the assigned trainer can manage plans for this profile',
      );
    }
  }

  private async mapToResponse(plan: FullWeeklyPlan) {
    const days = await Promise.all(
      plan.dayPlans.map(async (d) => ({
        id: d.id,
        weeklyPlanId: d.weeklyPlanId,
        dayIndex: d.dayIndex,
        label: d.label,
        isRestDay: d.isRestDay,
        tasks: await Promise.all(
          d.tasks.map(async (t) => ({
            id: t.id,
            dayPlanId: t.dayPlanId,
            sequenceIndex: t.sequenceIndex,
            name: t.name,
            description: t.description,
            machineDetails: t.machineDetails,
            notes: t.notes,
            sets: t.sets,
            reps: t.reps,
            restSeconds: t.restSeconds,
            tempo: t.tempo,
            attachments: await Promise.all(
              t.attachments.map(async (a) => ({
                id: a.id,
                taskId: a.taskId,
                taskMediaId: a.taskMediaId,
                caption: a.caption,
                sequenceIndex: a.sequenceIndex,
                createdAt: a.createdAt,
                taskMedia: await this.taskMediaService.mapToResponse(
                  a.taskMedia,
                ),
              })),
            ),
            exerciseConfig: t.exerciseConfig
              ? await this.exerciseConfigService.mapToResponse(t.exerciseConfig)
              : null,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
          })),
        ),
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      })),
    );

    return {
      id: plan.id,
      workoutProfileId: plan.workoutProfileId,
      name: plan.name,
      status: plan.status,
      effectiveFrom: plan.effectiveFrom,
      effectiveTo: plan.effectiveTo,
      createdById: plan.createdById,
      notes: plan.notes,
      days,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    };
  }
}
