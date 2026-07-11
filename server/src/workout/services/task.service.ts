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
  TaskMediaInputDto,
} from '../dto/task.dto';
import type { RequestContext } from '../../common/types/request-context.type';
import type { WorkoutProfile, Task, TaskMedia } from 'generated/prisma/client';

export interface FullTask extends Task {
  media: TaskMedia[];
}

@Injectable()
export class TaskService {
  constructor(private readonly prisma: PrismaService) {}

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

      // 2. Create the task with its nested media
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
          media: {
            create: (dto.media || []).map((m) => ({
              type: m.type,
              url: m.url,
              caption: m.caption || null,
              sequenceIndex: m.sequenceIndex,
            })),
          },
        },
        include: {
          media: { orderBy: { sequenceIndex: 'asc' } },
        },
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
      },
      include: {
        media: { orderBy: { sequenceIndex: 'asc' } },
      },
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
      include: {
        media: { orderBy: { sequenceIndex: 'asc' } },
      },
    });

    return updatedTasks.map((t) =>
      this.mapTaskToResponse(t as unknown as FullTask),
    );
  }

  async addMedia(taskId: string, dto: TaskMediaInputDto, ctx: RequestContext) {
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

    const createdMedia = await this.prisma.$transaction(async (tx) => {
      // Shift existing media with index >= sequenceIndex in DESC order
      const mediaToShift = await tx.taskMedia.findMany({
        where: {
          taskId,
          sequenceIndex: { gte: dto.sequenceIndex },
        },
        orderBy: { sequenceIndex: 'desc' },
      });

      for (const m of mediaToShift) {
        await tx.taskMedia.update({
          where: { id: m.id },
          data: { sequenceIndex: m.sequenceIndex + 1 },
        });
      }

      // Create new media
      return tx.taskMedia.create({
        data: {
          taskId,
          type: dto.type,
          url: dto.url,
          caption: dto.caption || null,
          sequenceIndex: dto.sequenceIndex,
        },
      });
    });

    return createdMedia;
  }

  async removeMedia(mediaId: string, ctx: RequestContext) {
    const media = await this.prisma.taskMedia.findUnique({
      where: { id: mediaId },
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

    if (!media || media.task.dayPlan.weeklyPlan.workoutProfile.isDeleted) {
      throw new NotFoundException(`Task media with ID ${mediaId} not found`);
    }

    this.checkTrainerOrAdminAccess(
      media.task.dayPlan.weeklyPlan.workoutProfile,
      ctx,
    );

    await this.prisma.$transaction(async (tx) => {
      // 1. Delete the media
      await tx.taskMedia.delete({ where: { id: mediaId } });

      // 2. Shift subsequent media in ASC order
      const mediaToShift = await tx.taskMedia.findMany({
        where: {
          taskId: media.taskId,
          sequenceIndex: { gt: media.sequenceIndex },
        },
        orderBy: { sequenceIndex: 'asc' },
      });

      for (const m of mediaToShift) {
        await tx.taskMedia.update({
          where: { id: m.id },
          data: { sequenceIndex: m.sequenceIndex - 1 },
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

  private mapTaskToResponse(t: FullTask) {
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
      media: (t.media || []).map((m) => ({
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
    };
  }
}
