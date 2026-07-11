import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
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
import { WeeklyPlanService } from '../services/weekly-plan.service';
import {
  CreateWeeklyPlanDto,
  UpdateWeeklyPlanDto,
  WeeklyPlanResponseDto,
} from '../dto/weekly-plan.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';
import { PaginationQueryDto } from '../../common/dto/api-response.dto';

@ApiTags('weekly-plans')
@ApiBearerAuth()
@Controller()
export class WeeklyPlanController {
  constructor(private readonly planService: WeeklyPlanService) {}

  @ApiOperation({ summary: 'Create a weekly plan for a workout profile' })
  @ApiCreatedResponse({ type: WeeklyPlanResponseDto })
  @Post('workout-profiles/:profileId/weekly-plans')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async create(
    @Param('profileId') profileId: string,
    @Body() dto: CreateWeeklyPlanDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.planService.create(profileId, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'List all weekly plans for a workout profile' })
  @Get('workout-profiles/:profileId/weekly-plans')
  async findAll(
    @Param('profileId') profileId: string,
    @Query() query: PaginationQueryDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const page = query.page ? Number(query.page) : 1;
    const pageSize = query.pageSize ? Number(query.pageSize) : 20;
    const result = await this.planService.findAll(
      profileId,
      page,
      pageSize,
      ctx,
    );
    return { success: true, ...result };
  }

  @ApiOperation({ summary: 'Get full weekly plan details by plan ID' })
  @ApiOkResponse({ type: WeeklyPlanResponseDto })
  @Get('weekly-plans/:id')
  async findOne(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    const data = await this.planService.findOne(id, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Update weekly plan metadata' })
  @ApiOkResponse({ type: WeeklyPlanResponseDto })
  @Patch('weekly-plans/:id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateWeeklyPlanDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.planService.update(id, dto, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Promote an UPCOMING plan to ACTIVE' })
  @ApiOkResponse({ type: WeeklyPlanResponseDto })
  @Post('weekly-plans/:id/activate')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async activate(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    const data = await this.planService.activate(id, ctx);
    return { success: true, data };
  }

  @ApiOperation({ summary: 'Delete an UPCOMING plan' })
  @Delete('weekly-plans/:id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async remove(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    return this.planService.remove(id, ctx);
  }
}
