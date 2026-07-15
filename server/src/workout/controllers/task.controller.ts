import { Controller, Post, Patch, Delete, Body, Param } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
} from '@nestjs/swagger';
import { TaskService } from '../services/task.service';
import {
  CreateTaskDto,
  UpdateTaskDto,
  TaskResponseDto,
  ReorderTasksDto,
} from '../dto/task.dto';
import {
  AttachTaskMediaDto,
  TaskAttachmentResponseDto,
} from '../dto/task-media.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

@ApiTags('tasks')
@ApiBearerAuth()
@Controller()
export class TaskController {
  constructor(private readonly taskService: TaskService) {}

  @ApiOperation({ summary: 'Create a new task inside a day plan' })
  @ApiCreatedResponse({ type: TaskResponseDto })
  @Post('day-plans/:dayPlanId/tasks')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async create(
    @Param('dayPlanId') dayPlanId: string,
    @Body() dto: CreateTaskDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskService.create(dayPlanId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Update details of a task' })
  @ApiOkResponse({ type: TaskResponseDto })
  @Patch('tasks/:id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateTaskDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskService.update(id, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Delete a task from a day plan' })
  @Delete('tasks/:id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async remove(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    return this.taskService.remove(id, ctx);
  }

  @ApiOperation({ summary: 'Reorder tasks in a day plan' })
  @ApiOkResponse({ type: [TaskResponseDto] })
  @Patch('day-plans/:dayPlanId/tasks/reorder')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async reorder(
    @Param('dayPlanId') dayPlanId: string,
    @Body() dto: ReorderTasksDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskService.reorder(dayPlanId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Attach a library media item to a task' })
  @ApiCreatedResponse({ type: TaskAttachmentResponseDto })
  @Post('tasks/:taskId/attachments')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async addAttachment(
    @Param('taskId') taskId: string,
    @Body() dto: AttachTaskMediaDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskService.addAttachment(taskId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Detach a media item from a task (library item survives)' })
  @Delete('task-attachments/:id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async removeAttachment(
    @Param('id') id: string,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.taskService.removeAttachment(id, ctx);
  }
}
