import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { SYSTEM_ROLES } from '../auth/constants/roles';
import { ReqContext } from '../common/decorators/request-context.decorator';
import {
  CheckResource,
  ResourceAccessGuard,
} from '../common/guards/resource-access.guard';
import type { RequestContext } from '../common/types/request-context.type';
import { ApproveGymDto } from './dto/approve-gym.dto';
import { CreateGymDto } from './dto/create-gym.dto';
import { GymListQueryDto } from './dto/gym-list-query.dto';
import { SetSessionRateDto } from './dto/set-session-rate.dto';
import { UpdateGymDto } from './dto/update-gym.dto';
import { GymScopeResolver } from './gym.scope-resolver';
import { GymService } from './gym.service';

@ApiTags('gyms')
@Controller('gyms')
export class GymController {
  constructor(
    private readonly gymService: GymService,
    private readonly gymScopeResolver: GymScopeResolver,
  ) {}

  @Public()
  @Get()
  async findAll(
    @Query() query: GymListQueryDto,
    @ReqContext() ctx?: RequestContext,
  ) {
    const where = await this.gymScopeResolver.resolve(ctx);
    return this.gymService.findAll({ where, query, ctx });
  }

  @Public()
  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @ReqContext() ctx?: RequestContext,
  ) {
    const where = await this.gymScopeResolver.resolve(ctx);
    return this.gymService.findOne({ id, where, ctx });
  }

  @ApiBearerAuth()
  @Post()
  @Roles(SYSTEM_ROLES.OWNER)
  async create(@Body() dto: CreateGymDto, @ReqContext() ctx: RequestContext) {
    return this.gymService.create(dto, ctx.userId);
  }

  @ApiBearerAuth()
  @Patch(':id')
  @Roles(SYSTEM_ROLES.OWNER)
  @UseGuards(ResourceAccessGuard)
  @CheckResource('gym')
  async update(@Param('id') id: string, @Body() dto: UpdateGymDto) {
    return this.gymService.update(id, dto);
  }

  @ApiBearerAuth()
  @Patch(':id/approve')
  @Roles(SYSTEM_ROLES.ADMIN, SYSTEM_ROLES.ADMIN_STAFF)
  async approve(@Param('id') id: string, @Body() dto: ApproveGymDto) {
    return this.gymService.approve(id, dto.tier);
  }

  @ApiBearerAuth()
  @Patch(':id/session-rate')
  @Roles(SYSTEM_ROLES.ADMIN, SYSTEM_ROLES.ADMIN_STAFF)
  async setSessionRate(
    @Param('id') id: string,
    @Body() dto: SetSessionRateDto,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.gymService.setSessionRate(id, dto.rate, ctx.userId);
  }
}
