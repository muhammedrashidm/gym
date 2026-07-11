import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateDayPlanDto } from '../dto/day-plan.dto';
import type { RequestContext } from '../../common/types/request-context.type';
import type {
  WorkoutProfile,
  DayPlan,
  Task,
  TaskMedia,
} from 'generated/prisma/client';

export interface FullTask extends Task {
  media: TaskMedia[];
}

export interface FullDayPlan extends DayPlan {
  tasks: FullTask[];
}

@Injectable()
export class DayPlanService {
  constructor(private readonly prisma: PrismaService) {}

  async findOne(id: string, ctx: RequestContext) {
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: { id },
      include: {
        weeklyPlan: {
          include: { workoutProfile: true },
        },
        tasks: {
          orderBy: { sequenceIndex: 'asc' },
          include: {
            media: {
              orderBy: { sequenceIndex: 'asc' },
            },
          },
        },
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
      include: {
        tasks: {
          orderBy: { sequenceIndex: 'asc' },
          include: {
            media: {
              orderBy: { sequenceIndex: 'asc' },
            },
          },
        },
      },
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

  private mapToResponse(d: FullDayPlan) {
    return {
      id: d.id,
      weeklyPlanId: d.weeklyPlanId,
      dayIndex: d.dayIndex,
      label: d.label,
      isRestDay: d.isRestDay,
      tasks: d.tasks.map((t) => ({
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
        media: t.media.map((m) => ({
          id: m.id,
          taskId: m.taskId,
          type: m.type,
          url: m.url,
          caption: m.caption,
          sequenceIndex: m.sequenceIndex,
          createdAt: m.createdAt,
        })),
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      })),
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    };
  }
}
