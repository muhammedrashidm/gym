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
import { ExerciseConfigService } from '../services/exercise-config.service';
import {
  CreateExerciseConfigDto,
  UpdateExerciseConfigDto,
  SearchExerciseConfigQueryDto,
  ExerciseConfigResponseDto,
} from '../dto/exercise-config.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

const MAX_UPLOAD_BYTES = 25 * 1024 * 1024; // 25MB

// Config authoring is admin-side only — deliberately narrower than the
// TRAINER_ROLES set used for mutating endpoints everywhere else in workout/.
const ADMIN_ROLES = [SYSTEM_ROLES.ADMIN, SYSTEM_ROLES.OWNER] as const;

const TRAINER_ROLES = [
  SYSTEM_ROLES.TRAINER,
  SYSTEM_ROLES.STAFF,
  SYSTEM_ROLES.MANAGER,
  SYSTEM_ROLES.OWNER,
  SYSTEM_ROLES.ADMIN,
] as const;

@ApiTags('exercise-config')
@ApiBearerAuth()
@Controller('exercise-configs')
export class ExerciseConfigController {
  constructor(private readonly exerciseConfigService: ExerciseConfigService) {}

  @ApiOperation({ summary: 'Create a new AI exercise config (admin only)' })
  @ApiConsumes('multipart/form-data')
  @ApiCreatedResponse({ type: ExerciseConfigResponseDto })
  @Post()
  @Roles(...ADMIN_ROLES)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: MAX_UPLOAD_BYTES },
    }),
  )
  async create(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: CreateExerciseConfigDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.exerciseConfigService.create(dto, file, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Search the exercise config library' })
  @ApiOkResponse({ type: [ExerciseConfigResponseDto] })
  @Get()
  @Roles(...TRAINER_ROLES)
  async search(@Query() query: SearchExerciseConfigQueryDto) {
    const result = await this.exerciseConfigService.search(query);
    return { success: true, ...result };
  }

  @ApiOperation({
    summary:
      'Fetch one config with its full AI JSON payload (client, right before opening the camera)',
  })
  @ApiOkResponse({ type: ExerciseConfigResponseDto })
  @Get(':id')
  @Roles(...TRAINER_ROLES)
  async findOne(@Param('id') id: string) {
    const data = await this.exerciseConfigService.findOne(id);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Edit a config (admin only)' })
  @ApiOkResponse({ type: ExerciseConfigResponseDto })
  @Patch(':id')
  @Roles(...ADMIN_ROLES)
  async update(@Param('id') id: string, @Body() dto: UpdateExerciseConfigDto) {
    const data = await this.exerciseConfigService.update(id, dto);
    return { success: true, data };
  }

  @ApiOperation({
    summary:
      'Hard-delete a config (admin only) — prefer PATCH { isActive: false } to retire without deleting',
  })
  @Delete(':id')
  @Roles(...ADMIN_ROLES)
  async remove(@Param('id') id: string) {
    return this.exerciseConfigService.remove(id);
  }
}
