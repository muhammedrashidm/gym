import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CompleteWorkoutSessionDto,
  SkipWorkoutSessionDto,
  WorkoutSessionResponseDto,
  TaskCompletionEntryDto,
} from '../dto/workout-session.dto';
import type { RequestContext } from '../../common/types/request-context.type';
import type { PaginationMeta } from '../../common/dto/api-response.dto';
import type { IWorkoutSessionService } from '../interfaces/workout-session-service.interface';
import {
  SessionLogStatus,
  SessionLogActorRole,
  WorkoutProfile,
} from 'generated/prisma/client';

@Injectable()
export class WorkoutSessionService implements IWorkoutSessionService {
  constructor(private readonly prisma: PrismaService) {}

  async complete(
    profileId: string,
    dto: CompleteWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto> {
    // 1. Verify profile exists
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id: profileId },
    });
    if (!profile || profile.isDeleted) {
      throw new NotFoundException(
        `Workout profile with ID ${profileId} not found`,
      );
    }

    // 2. Access check
    this.checkProfileAccess(profile, ctx);
    const actorRole = this.resolveActorRole(profile, ctx);

    if (!profile.activeWeeklyPlanId) {
      throw new ConflictException(
        'No active weekly plan assigned to this profile',
      );
    }

    const currentDayIndex = profile.currentDayIndex;

    // 3. Find current DayPlan
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: {
        weeklyPlanId_dayIndex: {
          weeklyPlanId: profile.activeWeeklyPlanId,
          dayIndex: currentDayIndex,
        },
      },
    });

    if (!dayPlan) {
      throw new NotFoundException(
        `Day plan for weekly plan ${profile.activeWeeklyPlanId} and day index ${currentDayIndex} not found`,
      );
    }

    const now = new Date();
    const nextDayIndex = (currentDayIndex % 7) + 1;
    // A full week is only "completed" once the cursor wraps back to day 1.
    const cycleIncrement = nextDayIndex === 1 ? 1 : 0;
    const cycleNumberAtTime = profile.completedCycleCount + cycleIncrement;

    // 4. Run in transaction
    const sessionLog = await this.prisma.$transaction(async (tx) => {
      // Create session log
      const log = await tx.workoutSessionLog.create({
        data: {
          workoutProfileId: profileId,
          weeklyPlanId: profile.activeWeeklyPlanId!,
          dayPlanId: dayPlan.id,
          dayIndexAtTime: currentDayIndex,
          cycleNumberAtTime,
          status: SessionLogStatus.COMPLETED,
          completedDate: now,
          loggedByUserId: ctx.userId,
          loggedByRole: actorRole,
        },
      });

      // Create individual task logs if provided
      if (dto.taskCompletions && dto.taskCompletions.length > 0) {
        // Validate task IDs belong to the day plan
        const taskIds = dto.taskCompletions.map((tc) => tc.taskId);
        const tasks = await tx.task.findMany({
          where: {
            id: { in: taskIds },
            dayPlanId: dayPlan.id,
          },
          select: { id: true },
        });
        const validTaskIds = tasks.map((t) => t.id);

        const invalidTasks = taskIds.filter((id) => !validTaskIds.includes(id));
        if (invalidTasks.length > 0) {
          throw new ConflictException(
            `Task IDs do not belong to the current day plan: ${invalidTasks.join(', ')}`,
          );
        }

        await tx.taskCompletionLog.createMany({
          data: dto.taskCompletions.map((tc) => ({
            sessionLogId: log.id,
            taskId: tc.taskId,
            actualSets: tc.actualSets ?? null,
            actualReps: tc.actualReps ?? null,
            actualWeightKg: tc.actualWeightKg ?? null,
            notes: tc.notes ?? null,
          })),
        });
      }

      // Advance the profile cursor (and cycle counter, if a week just completed)
      await tx.workoutProfile.update({
        where: { id: profileId },
        data: {
          currentDayIndex: nextDayIndex,
          completedCycleCount: { increment: cycleIncrement },
        },
      });

      return log;
    });

    const weeklyPlan = await this.prisma.weeklyPlan.findUnique({
      where: { id: sessionLog.weeklyPlanId },
      select: { name: true },
    });

    return this.toResponseDto(sessionLog, weeklyPlan?.name ?? '', dayPlan.label, nextDayIndex);
  }

  async skip(
    profileId: string,
    dto: SkipWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto> {
    // 1. Verify profile exists
    const profile = await this.prisma.workoutProfile.findUnique({
      where: { id: profileId },
    });
    if (!profile || profile.isDeleted) {
      throw new NotFoundException(
        `Workout profile with ID ${profileId} not found`,
      );
    }

    // 2. Access check
    this.checkProfileAccess(profile, ctx);
    const actorRole = this.resolveActorRole(profile, ctx);

    if (!profile.activeWeeklyPlanId) {
      throw new ConflictException(
        'No active weekly plan assigned to this profile',
      );
    }

    const currentDayIndex = profile.currentDayIndex;

    // 3. Find current DayPlan
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: {
        weeklyPlanId_dayIndex: {
          weeklyPlanId: profile.activeWeeklyPlanId,
          dayIndex: currentDayIndex,
        },
      },
    });

    if (!dayPlan) {
      throw new NotFoundException(
        `Day plan for weekly plan ${profile.activeWeeklyPlanId} and day index ${currentDayIndex} not found`,
      );
    }

    const now = new Date();

    // 4. Create session log without advancing cursor or cycle counter
    const sessionLog = await this.prisma.workoutSessionLog.create({
      data: {
        workoutProfileId: profileId,
        weeklyPlanId: profile.activeWeeklyPlanId,
        dayPlanId: dayPlan.id,
        dayIndexAtTime: currentDayIndex,
        cycleNumberAtTime: profile.completedCycleCount,
        status: SessionLogStatus.SKIPPED,
        completedDate: now,
        loggedByUserId: ctx.userId,
        loggedByRole: actorRole,
      },
    });

    const weeklyPlan = await this.prisma.weeklyPlan.findUnique({
      where: { id: sessionLog.weeklyPlanId },
      select: { name: true },
    });

    return this.toResponseDto(
      sessionLog,
      weeklyPlan?.name ?? '',
      dayPlan.label,
      currentDayIndex, // remains the same
    );
  }

  async findAll(
    profileId: string,
    page = 1,
    pageSize = 20,
    ctx: RequestContext,
  ): Promise<{ data: WorkoutSessionResponseDto[]; meta: PaginationMeta }> {
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

    const [total, logs] = await Promise.all([
      this.prisma.workoutSessionLog.count({
        where: { workoutProfileId: profileId },
      }),
      this.prisma.workoutSessionLog.findMany({
        where: { workoutProfileId: profileId },
        orderBy: { completedDate: 'desc' },
        skip,
        take: pageSize,
        include: {
          weeklyPlan: { select: { name: true } },
          dayPlan: { select: { label: true } },
          taskCompletionLogs: {
            select: {
              taskId: true,
              actualSets: true,
              actualReps: true,
              actualWeightKg: true,
              notes: true,
            },
          },
        },
      }),
    ]);

    return {
      data: logs.map((l) =>
        this.toResponseDto(
          l,
          l.weeklyPlan?.name ?? '',
          l.dayPlan?.label ?? null,
          undefined,
          l.taskCompletionLogs,
        ),
      ),
      meta: {
        total,
        page,
        pageSize,
      },
    };
  }

  private resolveActorRole(
    profile: WorkoutProfile,
    ctx: RequestContext,
  ): SessionLogActorRole {
    const isOwnerClient =
      ctx.profileId && ctx.profileId === profile.clientProfileId;
    if (isOwnerClient) return SessionLogActorRole.MEMBER;

    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;
    if (isAssignedTrainer) return SessionLogActorRole.TRAINER;

    // Reaches here only for admins — checkProfileAccess already rejected
    // anyone else before this is called.
    return SessionLogActorRole.STAFF;
  }

  private toResponseDto(
    log: {
      id: string;
      workoutProfileId: string;
      weeklyPlanId: string;
      dayPlanId: string | null;
      dayIndexAtTime: number;
      cycleNumberAtTime: number;
      status: SessionLogStatus;
      scheduledDate: Date | null;
      completedDate: Date | null;
      loggedByUserId: string | null;
      loggedByRole: SessionLogActorRole | null;
    },
    weeklyPlanName: string,
    dayPlanLabel: string | null,
    currentDayIndexAfter?: number,
    taskCompletionLogs: TaskCompletionEntryDto[] = [],
  ): WorkoutSessionResponseDto {
    return {
      id: log.id,
      workoutProfileId: log.workoutProfileId,
      weeklyPlanId: log.weeklyPlanId,
      weeklyPlanName,
      dayPlanId: log.dayPlanId,
      dayPlanLabel,
      dayIndexAtTime: log.dayIndexAtTime,
      cycleNumberAtTime: log.cycleNumberAtTime,
      status: log.status,
      scheduledDate: log.scheduledDate,
      completedDate: log.completedDate,
      loggedByRole: log.loggedByRole,
      loggedByUserId: log.loggedByUserId,
      taskCompletionLogs,
      ...(currentDayIndexAfter !== undefined ? { currentDayIndexAfter } : {}),
    };
  }

  private checkProfileAccess(profile: WorkoutProfile, ctx: RequestContext) {
    if (ctx.isAdmin) return;

    const isOwnerClient =
      ctx.profileId && ctx.profileId === profile.clientProfileId;
    const isAssignedTrainer =
      ctx.staffProfileId && ctx.staffProfileId === profile.trainerProfileId;

    if (!isOwnerClient && !isAssignedTrainer) {
      throw new ForbiddenException(
        'You do not have permission to access session logs for this profile',
      );
    }
  }
}
