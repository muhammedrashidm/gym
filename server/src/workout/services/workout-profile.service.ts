import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateWorkoutProfileDto,
  WorkoutProfileQueryDto,
  UpdateWorkoutProfileDto,
} from '../dto/workout-profile.dto';
import type { RequestContext } from '../../common/types/request-context.type';
import type { WorkoutProfile } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { TaskMediaService } from './task-media.service';
import { ExerciseConfigService } from '../../exercise-config/services/exercise-config.service';

@Injectable()
export class WorkoutProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskMediaService: TaskMediaService,
    private readonly exerciseConfigService: ExerciseConfigService,
  ) {}

  async create(dto: CreateWorkoutProfileDto, ctx: RequestContext) {
    const trainerProfileId = dto.trainerProfileId || ctx.staffProfileId;
    if (!trainerProfileId) {
      throw new BadRequestException('trainerProfileId is required');
    }

    // 1. Validate trainer profile exists and get their userId
    const trainerProfile = await this.prisma.staffProfile.findUnique({
      where: { id: trainerProfileId },
      select: { userId: true },
    });
    if (!trainerProfile) {
      throw new NotFoundException(
        `Trainer profile with ID ${trainerProfileId} not found`,
      );
    }

    // 2. Validate client profile exists and get their userId (if any)
    const clientProfile = await this.prisma.profile.findUnique({
      where: { id: dto.clientProfileId },
      select: { userId: true },
    });
    if (!clientProfile) {
      throw new NotFoundException(
        `Client profile with ID ${dto.clientProfileId} not found`,
      );
    }

    // 3. Check for existing active, non-deleted workout profile for the client
    const existing = await this.prisma.workoutProfile.findFirst({
      where: {
        clientProfileId: dto.clientProfileId,
        isActive: true,
        isDeleted: false,
      },
    });
    if (existing) {
      throw new ConflictException(
        `Active workout profile for client profile ${dto.clientProfileId} already exists`,
      );
    }

    // 4. Validate trainer-client connection unless the user is an admin
    if (!ctx.isAdmin) {
      const connection = await this.prisma.staffClientConnection.findUnique({
        where: {
          staffProfileId_clientProfileId: {
            staffProfileId: trainerProfileId,
            clientProfileId: dto.clientProfileId,
          },
        },
      });
      if (!connection || !connection.isActive) {
        throw new ForbiddenException(
          'A trainer can only create workout profiles for clients they are connected to.',
        );
      }
    }

    // 5. Create profile
    return this.prisma.workoutProfile.create({
      data: {
        clientProfileId: dto.clientProfileId,
        clientUserId: clientProfile.userId,
        trainerProfileId: trainerProfileId,
        trainerUserId: trainerProfile.userId,
        currentDayIndex: 1,
        isActive: true,
        isDeleted: false,
      },
    });
  }

  async findOne(id: string, ctx: RequestContext) {
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id },
      include: {
        activeWeeklyPlan: {
          select: {
            id: true,
            name: true,
            status: true,
          },
        },
      },
    });

    if (!profile || profile.isDeleted) {
      throw new NotFoundException(`Workout profile with ID ${id} not found`);
    }

    this.checkAccess(profile, ctx);

    return profile;
  }

  async findTodayPlan(id: string, ctx: RequestContext) {
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id },
    });

    if (!profile || profile.isDeleted) {
      throw new NotFoundException(`Workout profile with ID ${id} not found`);
    }

    this.checkAccess(profile, ctx);

    if (!profile.activeWeeklyPlanId) {
      return null;
    }

    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: {
        weeklyPlanId_dayIndex: {
          weeklyPlanId: profile.activeWeeklyPlanId,
          dayIndex: profile.currentDayIndex,
        },
      },
      include: {
        tasks: {
          orderBy: { sequenceIndex: 'asc' },
          include: {
            attachments: {
              orderBy: { sequenceIndex: 'asc' },
              include: { taskMedia: { include: { media: true } } },
            },
            exerciseConfig: {
              include: { media: true },
            },
          },
        },
      },
    });

    if (!dayPlan) return null;

    // Resolve fresh media URLs for each task's attachments + exercise config.
    const tasks = await Promise.all(
      dayPlan.tasks.map(async (t) => ({
        ...t,
        attachments: await Promise.all(
          t.attachments.map(async (a) => ({
            id: a.id,
            taskId: a.taskId,
            taskMediaId: a.taskMediaId,
            caption: a.caption,
            sequenceIndex: a.sequenceIndex,
            createdAt: a.createdAt,
            taskMedia: await this.taskMediaService.mapToResponse(a.taskMedia),
          })),
        ),
        exerciseConfig: t.exerciseConfig
          ? await this.exerciseConfigService.mapToSummary(t.exerciseConfig)
          : null,
      })),
    );

    return { ...dayPlan, tasks };
  }

  async findAll(query: WorkoutProfileQueryDto, ctx: RequestContext) {
    const page = Math.max(1, Number(query.page || 1));
    const pageSize = Math.max(1, Number(query.pageSize || 20));
    const skip = (page - 1) * pageSize;

    const where: Prisma.WorkoutProfileWhereInput = { isDeleted: false };
    if (query.clientProfileId) {
      where.clientProfileId = query.clientProfileId;

      if (!ctx.isAdmin && ctx.profileId !== query.clientProfileId) {
        const connection = await this.prisma.staffClientConnection.findFirst({
          where: {
            clientProfileId: query.clientProfileId,
            staffProfileId: ctx.staffProfileId,
            isActive: true,
          },
        });
        if (!connection) {
          throw new ForbiddenException(
            "You do not have access to this client's workout profiles.",
          );
        }
      }
    } else {
      if (!ctx.isAdmin) {
        where.OR = [
          { clientProfileId: ctx.profileId },
          { trainerProfileId: ctx.staffProfileId },
        ];
      }
    }

    const [total, profiles] = await Promise.all([
      this.prisma.workoutProfile.count({ where }),
      this.prisma.workoutProfile.findMany({
        where,
        orderBy: [{ isActive: 'desc' }, { createdAt: 'desc' }],
        skip,
        take: pageSize,
        include: {
          activeWeeklyPlan: {
            select: {
              id: true,
              name: true,
              status: true,
            },
          },
        },
      }),
    ]);

    return {
      data: profiles,
      profiles,
      meta: {
        total,
        page,
        pageSize,
      },
    };
  }

  async update(id: string, dto: UpdateWorkoutProfileDto, ctx: RequestContext) {
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id },
    });

    if (!profile || profile.isDeleted) {
      throw new NotFoundException(`Workout profile with ID ${id} not found`);
    }

    this.checkAccess(profile, ctx);

    if (dto.isActive === true && !profile.isActive) {
      const activeProfile = await this.prisma.workoutProfile.findFirst({
        where: {
          clientProfileId: profile.clientProfileId,
          isActive: true,
          isDeleted: false,
          id: { not: id },
        },
      });
      if (activeProfile) {
        throw new ConflictException(
          `Another active workout profile for client profile ${profile.clientProfileId} already exists. Deactivate it first.`,
        );
      }
    }

    return this.prisma.workoutProfile.update({
      where: { id },
      data: {
        isActive: dto.isActive !== undefined ? dto.isActive : undefined,
        currentDayIndex:
          dto.currentDayIndex !== undefined ? dto.currentDayIndex : undefined,
      },
      include: {
        activeWeeklyPlan: {
          select: {
            id: true,
            name: true,
            status: true,
          },
        },
      },
    });
  }

  private checkAccess(profile: WorkoutProfile, ctx: RequestContext) {
    if (ctx.isAdmin) return;

    // Check if the user is the owning client or the assigned trainer
    const isOwnerClient =
      ctx.profileId && ctx.profileId === profile.clientProfileId;
    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;

    if (!isOwnerClient && !isAssignedTrainer) {
      throw new ForbiddenException(
        'You do not have permission to access this workout profile',
      );
    }
  }
}
