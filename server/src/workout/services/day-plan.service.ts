import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateDayPlanDto } from '../dto/day-plan.dto';
import { TaskMediaService } from './task-media.service';
import { ExerciseConfigService } from '../../exercise-config/services/exercise-config.service';
import type { RequestContext } from '../../common/types/request-context.type';
import type {
  WorkoutProfile,
  DayPlan,
  Task,
  TaskAttachment,
  TaskMedia,
  Media,
  ExerciseConfig,
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

const taskInclude = {
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
};

@Injectable()
export class DayPlanService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskMediaService: TaskMediaService,
    private readonly exerciseConfigService: ExerciseConfigService,
  ) {}

  async findOne(id: string, ctx: RequestContext) {
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: { id },
      include: {
        weeklyPlan: {
          include: { workoutProfile: true },
        },
        ...taskInclude,
      },
    });

    if (!dayPlan || dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Day plan with ID ${id} not found`);
    }

    this.checkProfileAccess(dayPlan.weeklyPlan.workoutProfile, ctx);

    return this.mapToResponse(dayPlan as unknown as FullDayPlan);
  }

  async update(id: string, dto: UpdateDayPlanDto, ctx: RequestContext) {
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: { id },
      include: {
        weeklyPlan: {
          include: { workoutProfile: true },
        },
      },
    });

    if (!dayPlan || dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Day plan with ID ${id} not found`);
    }

    this.checkTrainerOrAdminAccess(dayPlan.weeklyPlan.workoutProfile, ctx);

    const updated = await this.prisma.dayPlan.update({
      where: { id },
      data: {
        label: dto.label,
        isRestDay: dto.isRestDay,
      },
      include: taskInclude,
    });

    return this.mapToResponse(updated as unknown as FullDayPlan);
  }

  private checkProfileAccess(profile: WorkoutProfile, ctx: RequestContext) {
    if (ctx.isAdmin) return;

    const isOwnerClient =
      ctx.profileId && ctx.profileId === profile.clientProfileId;
    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;

    if (!isOwnerClient && !isAssignedTrainer) {
      throw new ForbiddenException(
        'You do not have permission to access this day plan',
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
        'Only the assigned trainer can manage day plans for this profile',
      );
    }
  }

  private async mapToResponse(d: FullDayPlan) {
    const tasks = await Promise.all(
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
            taskMedia: await this.taskMediaService.mapToResponse(a.taskMedia),
          })),
        ),
        exerciseConfig: t.exerciseConfig
          ? await this.exerciseConfigService.mapToSummary(t.exerciseConfig)
          : null,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      })),
    );

    return {
      id: d.id,
      weeklyPlanId: d.weeklyPlanId,
      dayIndex: d.dayIndex,
      label: d.label,
      isRestDay: d.isRestDay,
      tasks,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    };
  }
}
