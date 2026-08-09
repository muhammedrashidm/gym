import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateTaskDto,
  UpdateTaskDto,
  ReorderTasksDto,
} from '../dto/task.dto';
import { AttachTaskMediaDto } from '../dto/task-media.dto';
import { TaskMediaService } from './task-media.service';
import { ExerciseConfigService } from '../../exercise-config/services/exercise-config.service';
import type { RequestContext } from '../../common/types/request-context.type';
import type {
  WorkoutProfile,
  Task,
  TaskAttachment,
  TaskMedia,
  Media,
  ExerciseConfig,
} from '@prisma/client';

type FullTaskAttachment = TaskAttachment & {
  taskMedia: TaskMedia & { media: Media };
};

export interface FullTask extends Task {
  attachments: FullTaskAttachment[];
  exerciseConfig: (ExerciseConfig & { media: Media }) | null;
}

const attachmentInclude = {
  attachments: {
    orderBy: { sequenceIndex: 'asc' as const },
    include: { taskMedia: { include: { media: true } } },
  },
  exerciseConfig: {
    include: { media: true },
  },
};

@Injectable()
export class TaskService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskMediaService: TaskMediaService,
    private readonly exerciseConfigService: ExerciseConfigService,
  ) {}

  async create(dayPlanId: string, dto: CreateTaskDto, ctx: RequestContext) {
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: { id: dayPlanId },
      include: {
        weeklyPlan: { include: { workoutProfile: true } },
      },
    });

    if (!dayPlan || dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Day plan with ID ${dayPlanId} not found`);
    }

    this.checkTrainerOrAdminAccess(dayPlan.weeklyPlan.workoutProfile, ctx);

    // Ensure every referenced library item exists and is usable by the caller.
    await this.taskMediaService.assertUsable(
      (dto.attachments || []).map((a) => a.taskMediaId),
      ctx,
    );
    if (dto.exerciseConfigId) {
      await this.exerciseConfigService.assertUsable(dto.exerciseConfigId);
    }

    const createdTask = await this.prisma.$transaction(async (tx) => {
      // 1. Shift existing tasks with index >= dto.sequenceIndex in DESC order
      const tasksToShift = await tx.task.findMany({
        where: {
          dayPlanId,
          sequenceIndex: { gte: dto.sequenceIndex },
        },
        orderBy: { sequenceIndex: 'desc' },
      });

      for (const task of tasksToShift) {
        await tx.task.update({
          where: { id: task.id },
          data: { sequenceIndex: task.sequenceIndex + 1 },
        });
      }

      // 2. Create the task with its attachments (references to library media)
      return tx.task.create({
        data: {
          dayPlanId,
          sequenceIndex: dto.sequenceIndex,
          name: dto.name,
          description: dto.description || null,
          machineDetails: dto.machineDetails || null,
          notes: dto.notes || null,
          sets: dto.sets,
          reps: dto.reps,
          restSeconds: dto.restSeconds || null,
          tempo: dto.tempo || null,
          exerciseConfigId: dto.exerciseConfigId || null,
          attachments: {
            create: (dto.attachments || []).map((a) => ({
              taskMediaId: a.taskMediaId,
              caption: a.caption || null,
              sequenceIndex: a.sequenceIndex,
              createdById: ctx.userId,
            })),
          },
        },
        include: attachmentInclude,
      });
    });

    return this.mapTaskToResponse(createdTask as unknown as FullTask);
  }

  async update(id: string, dto: UpdateTaskDto, ctx: RequestContext) {
    const task = await this.prisma.task.findUnique({
      where: { id },
      include: {
        dayPlan: {
          include: {
            weeklyPlan: { include: { workoutProfile: true } },
          },
        },
      },
    });

    if (!task || task.dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }

    this.checkTrainerOrAdminAccess(task.dayPlan.weeklyPlan.workoutProfile, ctx);

    if (dto.exerciseConfigId) {
      await this.exerciseConfigService.assertUsable(dto.exerciseConfigId);
    }

    const updatedTask = await this.prisma.task.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        machineDetails: dto.machineDetails,
        notes: dto.notes,
        sets: dto.sets,
        reps: dto.reps,
        restSeconds: dto.restSeconds,
        tempo: dto.tempo,
        // undefined (not provided) leaves the column unchanged; null clears it.
        exerciseConfigId: dto.exerciseConfigId,
      },
      include: attachmentInclude,
    });

    return this.mapTaskToResponse(updatedTask as unknown as FullTask);
  }

  async remove(id: string, ctx: RequestContext) {
    const task = await this.prisma.task.findUnique({
      where: { id },
      include: {
        dayPlan: {
          include: {
            weeklyPlan: { include: { workoutProfile: true } },
          },
        },
      },
    });

    if (!task || task.dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }

    this.checkTrainerOrAdminAccess(task.dayPlan.weeklyPlan.workoutProfile, ctx);

    await this.prisma.$transaction(async (tx) => {
      // 1. Delete the task
      await tx.task.delete({ where: { id } });

      // 2. Shift subsequent tasks in ASC order
      const tasksToShift = await tx.task.findMany({
        where: {
          dayPlanId: task.dayPlanId,
          sequenceIndex: { gt: task.sequenceIndex },
        },
        orderBy: { sequenceIndex: 'asc' },
      });

      for (const t of tasksToShift) {
        await tx.task.update({
          where: { id: t.id },
          data: { sequenceIndex: t.sequenceIndex - 1 },
        });
      }
    });

    return { success: true };
  }

  async reorder(dayPlanId: string, dto: ReorderTasksDto, ctx: RequestContext) {
    const dayPlan = await this.prisma.dayPlan.findUnique({
      where: { id: dayPlanId },
      include: {
        weeklyPlan: { include: { workoutProfile: true } },
        tasks: true,
      },
    });

    if (!dayPlan || dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Day plan with ID ${dayPlanId} not found`);
    }

    this.checkTrainerOrAdminAccess(dayPlan.weeklyPlan.workoutProfile, ctx);

    // Validate that the request contains exactly all and only the tasks of the day plan
    const existingTaskIds = dayPlan.tasks.map((t) => t.id);
    if (
      existingTaskIds.length !== dto.orderedTaskIds.length ||
      !dto.orderedTaskIds.every((id) => existingTaskIds.includes(id))
    ) {
      throw new BadRequestException(
        'The list of ordered task IDs must match the tasks of the day plan',
      );
    }

    await this.prisma.$transaction(async (tx) => {
      // Step 1: Set temporary negative indices to avoid uniqueness collision
      for (let i = 0; i < dto.orderedTaskIds.length; i++) {
        const taskId = dto.orderedTaskIds[i];
        await tx.task.update({
          where: { id: taskId },
          data: { sequenceIndex: -(i + 1) },
        });
      }

      // Step 2: Set final positive indices (1-based)
      for (let i = 0; i < dto.orderedTaskIds.length; i++) {
        const taskId = dto.orderedTaskIds[i];
        await tx.task.update({
          where: { id: taskId },
          data: { sequenceIndex: i + 1 },
        });
      }
    });

    // Return the updated task list
    const updatedTasks = await this.prisma.task.findMany({
      where: { dayPlanId },
      orderBy: { sequenceIndex: 'asc' },
      include: attachmentInclude,
    });

    return Promise.all(
      updatedTasks.map((t) => this.mapTaskToResponse(t as unknown as FullTask)),
    );
  }

  /** Attach an existing library TaskMedia to a task (sequenceIndex appended). */
  async addAttachment(
    taskId: string,
    dto: AttachTaskMediaDto,
    ctx: RequestContext,
  ) {
    const task = await this.prisma.task.findUnique({
      where: { id: taskId },
      include: {
        dayPlan: {
          include: {
            weeklyPlan: { include: { workoutProfile: true } },
          },
        },
      },
    });

    if (!task || task.dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }

    this.checkTrainerOrAdminAccess(task.dayPlan.weeklyPlan.workoutProfile, ctx);
    await this.taskMediaService.assertUsable([dto.taskMediaId], ctx);

    const last = await this.prisma.taskAttachment.findFirst({
      where: { taskId },
      orderBy: { sequenceIndex: 'desc' },
      select: { sequenceIndex: true },
    });
    const nextIndex = (last?.sequenceIndex ?? 0) + 1;

    const created = await this.prisma.taskAttachment.create({
      data: {
        taskId,
        taskMediaId: dto.taskMediaId,
        caption: dto.caption || null,
        sequenceIndex: nextIndex,
        createdById: ctx.userId,
      },
      include: { taskMedia: { include: { media: true } } },
    });

    return this.mapAttachmentToResponse(created as FullTaskAttachment);
  }

  /** Unlink an attachment (the library TaskMedia + its Media survive). */
  async removeAttachment(attachmentId: string, ctx: RequestContext) {
    const attachment = await this.prisma.taskAttachment.findUnique({
      where: { id: attachmentId },
      include: {
        task: {
          include: {
            dayPlan: {
              include: {
                weeklyPlan: { include: { workoutProfile: true } },
              },
            },
          },
        },
      },
    });

    if (
      !attachment ||
      attachment.task.dayPlan.weeklyPlan.workoutProfile.isDeleted
    ) {
      throw new NotFoundException(
        `Task attachment with ID ${attachmentId} not found`,
      );
    }

    this.checkTrainerOrAdminAccess(
      attachment.task.dayPlan.weeklyPlan.workoutProfile,
      ctx,
    );

    await this.prisma.$transaction(async (tx) => {
      await tx.taskAttachment.delete({ where: { id: attachmentId } });

      // Shift subsequent attachments in ASC order to keep indices contiguous.
      const toShift = await tx.taskAttachment.findMany({
        where: {
          taskId: attachment.taskId,
          sequenceIndex: { gt: attachment.sequenceIndex },
        },
        orderBy: { sequenceIndex: 'asc' },
      });

      for (const a of toShift) {
        await tx.taskAttachment.update({
          where: { id: a.id },
          data: { sequenceIndex: a.sequenceIndex - 1 },
        });
      }
    });

    return { success: true };
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
        'Only the assigned trainer can manage tasks for this profile',
      );
    }
  }

  private async mapAttachmentToResponse(a: FullTaskAttachment) {
    return {
      id: a.id,
      taskId: a.taskId,
      taskMediaId: a.taskMediaId,
      caption: a.caption,
      sequenceIndex: a.sequenceIndex,
      createdAt: a.createdAt,
      taskMedia: await this.taskMediaService.mapToResponse(a.taskMedia),
    };
  }

  private async mapTaskToResponse(t: FullTask) {
    const attachments = await Promise.all(
      (t.attachments || []).map((a) => this.mapAttachmentToResponse(a)),
    );
    const exerciseConfig = t.exerciseConfig
      ? await this.exerciseConfigService.mapToSummary(t.exerciseConfig)
      : null;
    return {
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
      attachments,
      exerciseConfig,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    };
  }
}
