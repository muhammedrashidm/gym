import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiConsumes,
} from '@nestjs/swagger';
import { TaskMediaService } from '../services/task-media.service';
import {
  CreateTaskMediaDto,
  UpdateTaskMediaDto,
  SearchTaskMediaQueryDto,
  TaskMediaResponseDto,
} from '../dto/task-media.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

const MAX_UPLOAD_BYTES = 25 * 1024 * 1024; // 25MB

const TRAINER_ROLES = [
  SYSTEM_ROLES.TRAINER,
  SYSTEM_ROLES.STAFF,
  SYSTEM_ROLES.MANAGER,
  SYSTEM_ROLES.OWNER,
  SYSTEM_ROLES.ADMIN,
] as const;

@ApiTags('task-media')
@ApiBearerAuth()
@Controller('task-media')
export class TaskMediaController {
  constructor(private readonly taskMediaService: TaskMediaService) {}

  @ApiOperation({ summary: 'Upload a new reusable media library item' })
  @ApiConsumes('multipart/form-data')
  @ApiCreatedResponse({ type: TaskMediaResponseDto })
  @Post()
  @Roles(...TRAINER_ROLES)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: MAX_UPLOAD_BYTES },
    }),
  )
  async create(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: CreateTaskMediaDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskMediaService.create(dto, file, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Search the reusable media library' })
  @ApiOkResponse({ type: [TaskMediaResponseDto] })
  @Get()
  @Roles(...TRAINER_ROLES)
  async search(
    @Query() query: SearchTaskMediaQueryDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const result = await this.taskMediaService.search(query, ctx);
    return { success: true, ...result };
  }

  @ApiOperation({ summary: 'Edit a media library item (creator/admin only)' })
  @ApiOkResponse({ type: TaskMediaResponseDto })
  @Patch(':id')
  @Roles(...TRAINER_ROLES)
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateTaskMediaDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.taskMediaService.update(id, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Delete a media library item (creator/admin only)' })
  @Delete(':id')
  @Roles(...TRAINER_ROLES)
  async remove(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    return this.taskMediaService.remove(id, ctx);
  }
}
