import { Controller, Get, Patch, Body, Param } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiTags,
  ApiOperation,
  ApiOkResponse,
} from '@nestjs/swagger';
import { DayPlanService } from '../services/day-plan.service';
import { UpdateDayPlanDto, DayPlanResponseDto } from '../dto/day-plan.dto';
import { Roles } from '../../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import { ReqContext } from '../../common/decorators/request-context.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

@ApiTags('day-plans')
@ApiBearerAuth()
@Controller('day-plans')
export class DayPlanController {
  constructor(private readonly dayPlanService: DayPlanService) {}

  @ApiOperation({ summary: 'Get details of a day plan' })
  @ApiOkResponse({ type: DayPlanResponseDto })
  @Get(':id')
  async findOne(@Param('id') id: string, @ReqContext() ctx: RequestContext) {
    const data = await this.dayPlanService.findOne(id, ctx);
    return { success: true, data };
  }

  @ApiOperation({
    summary: 'Update day plan configurations (e.g. label or isRestDay)',
  })
  @ApiOkResponse({ type: DayPlanResponseDto })
  @Patch(':id')
  @Roles(
    SYSTEM_ROLES.TRAINER,
    SYSTEM_ROLES.STAFF,
    SYSTEM_ROLES.MANAGER,
    SYSTEM_ROLES.OWNER,
    SYSTEM_ROLES.ADMIN,
  )
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateDayPlanDto,
    @ReqContext() ctx: RequestContext,
  ) {
    const data = await this.dayPlanService.update(id, dto, ctx);
    return { success: true, data };
  }
}
