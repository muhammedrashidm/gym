import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
} from '@nestjs/swagger';
import { WorkoutProfileService } from '../services/workout-profile.service';
import {
  CreateWorkoutProfileDto,
  WorkoutProfileQueryDto,
  UpdateWorkoutProfileDto,
  WorkoutProfileResponseDto,
} from '../dto/workout-profile.dto';
import { DayPlanResponseDto } from '../dto/day-plan.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

@ApiTags('workout-profiles')
@ApiBearerAuth()
@Controller('workout-profiles')
export class WorkoutProfileController {
  constructor(private readonly profileService: WorkoutProfileService) {}

  @ApiOperation({ summary: 'Create a workout profile for a client' })
  @ApiCreatedResponse({ type: WorkoutProfileResponseDto })
  @Post()
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async create(
    @Body() dto: CreateWorkoutProfileDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.profileService.create(dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'List workout profiles' })
  @Get()
  async findAll(
    @Query() query: WorkoutProfileQueryDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const result = await this.profileService.findAll(query, ctx);
    return { success: true, ...result };
  }

  @ApiOperation({ summary: 'Get a workout profile by ID' })
  @ApiOkResponse({ type: WorkoutProfileResponseDto })
  @Get(':id')
  async findOne(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    const data = await this.profileService.findOne(id, ctx);
    return { success: true, data };
  }

  @ApiOperation({
    summary:
      "Get today's DayPlan for a workout profile based on current cursor",
  })
  @ApiOkResponse({
    type: DayPlanResponseDto,
    description: 'Returns null if no active plan exists',
  })
  @Get(':id/today')
  async findTodayPlan(
    @Param('id') id: string,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.profileService.findTodayPlan(id, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Update a workout profile' })
  @ApiOkResponse({ type: WorkoutProfileResponseDto })
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateWorkoutProfileDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.profileService.update(id, dto, ctx);
    return { success: true, data };
  }
}
