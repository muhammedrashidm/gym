import { Controller, Post, Get, Body, Param, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiCreatedResponse,
} from '@nestjs/swagger';
import { WorkoutSessionService } from '../services/workout-session.service';
import {
  CompleteWorkoutSessionDto,
  SkipWorkoutSessionDto,
  WorkoutSessionResponseDto,
} from '../dto/workout-session.dto';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';
import { PaginationQueryDto } from '../../common/dto/api-response.dto';
import type { IWorkoutSessionController } from '../interfaces/workout-session-controller.interface';

@ApiTags('workout-sessions')
@ApiBearerAuth()
@Controller('workout-profiles/:profileId/sessions')
export class WorkoutSessionController implements IWorkoutSessionController {
  constructor(private readonly sessionService: WorkoutSessionService) {}

  @ApiOperation({
    summary:
      "Log completion of today's workout session (by the client, or by their trainer on their behalf)",
  })
  @ApiCreatedResponse({ type: WorkoutSessionResponseDto })
  @Post('complete')
  async complete(
    @Param('profileId') profileId: string,
    @Body() dto: CompleteWorkoutSessionDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.sessionService.complete(profileId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({
    summary:
      "Log skip of today's workout session (by the client, or by their trainer on their behalf)",
  })
  @ApiCreatedResponse({ type: WorkoutSessionResponseDto })
  @Post('skip')
  async skip(
    @Param('profileId') profileId: string,
    @Body() dto: SkipWorkoutSessionDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.sessionService.skip(profileId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'List session logs for a workout profile' })
  @Get()
  async findAll(
    @Param('profileId') profileId: string,
    @Query() query: PaginationQueryDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const page = query.page ? Number(query.page) : 1;
    const pageSize = query.pageSize ? Number(query.pageSize) : 20;
    const result = await this.sessionService.findAll(
      profileId,
      page,
      pageSize,
      ctx,
    );
    return { success: true, ...result };
  }
}
