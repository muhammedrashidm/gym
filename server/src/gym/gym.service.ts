import { Injectable } from '@nestjs/common';
import type { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { RequestContext } from '../common/types/request-context.type';
import { CreateGymDto } from './dto/create-gym.dto';
import { GymListQueryDto } from './dto/gym-list-query.dto';
import { UpdateGymDto } from './dto/update-gym.dto';

@Injectable()
export class GymService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll({
    where,
    query,
    ctx,
  }: {
    where: Prisma.GymWhereInput;
    query: GymListQueryDto;
    ctx?: RequestContext;
  }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const filters: Prisma.GymWhereInput[] = [where];

    if (query.search) {
      filters.push({
        OR: [
          { name: { contains: query.search, mode: 'insensitive' } },
          { address: { contains: query.search, mode: 'insensitive' } },
        ],
      });
    }

    if (ctx?.isAdmin && query.approved !== undefined) {
      filters.push({ isApproved: query.approved });
    }

    const mergedWhere: Prisma.GymWhereInput =
      filters.length === 1 ? filters[0] : { AND: filters };

    const [data, total] = await Promise.all([
      this.prisma.gym.findMany({
        where: mergedWhere,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: this.listSelect(ctx),
      }),
      this.prisma.gym.count({ where: mergedWhere }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne({
    id,
    where,
    ctx,
  }: {
    id: string;
    where: Prisma.GymWhereInput;
    ctx?: RequestContext;
  }) {
    const mergedWhere: Prisma.GymWhereInput = { AND: [{ id }, where] };
    return this.prisma.gym.findFirstOrThrow({
      where: mergedWhere,
      select: this.detailSelect(ctx),
    });
  }

  async create(dto: CreateGymDto, ownerId: string) {
    return this.prisma.gym.create({
      data: {
        name: dto.name,
        address: dto.address,
        lat: dto.lat,
        lng: dto.lng,
        logoUrl: dto.logoUrl,
        ownerId,
        isApproved: false,
        tier: 3,
      },
    });
  }

  async update(id: string, dto: UpdateGymDto) {
    return this.prisma.gym.update({
      where: { id },
      data: dto,
    });
  }

  async approve(gymId: string, tier: number) {
    return this.prisma.gym.update({
      where: { id: gymId },
      data: { isApproved: true, tier },
    });
  }

  async setSessionRate(gymId: string, rate: number, adminId: string) {
    await this.prisma.gymSessionRate.updateMany({
      where: { gymId, isActive: true },
      data: { isActive: false },
    });

    return this.prisma.gymSessionRate.create({
      data: {
        gymId,
        ratePerSession: rate,
        effectiveFrom: new Date(),
        setByAdminId: adminId,
        isActive: true,
      },
    });
  }

  private listSelect(ctx?: RequestContext): Prisma.GymSelect {
    const base: Prisma.GymSelect = {
      id: true,
      name: true,
      address: true,
      logoUrl: true,
      tier: true,
      isApproved: true,
      createdAt: true,
      _count: { select: { gymSubscriptions: true } },
    };

    if (ctx?.isAdmin) {
      return {
        ...base,
        owner: {
          select: {
            profile: { select: { fullName: true, phoneNumber: true } },
          },
        },
        _count: {
          select: { gymSubscriptions: true, checkIns: true, userRoles: true },
        },
      };
    }

    return base;
  }

  private detailSelect(ctx?: RequestContext): Prisma.GymSelect {
    if (ctx?.isAdmin || ctx?.isOwner) {
      return {
        id: true,
        name: true,
        address: true,
        lat: true,
        lng: true,
        logoUrl: true,
        tier: true,
        isApproved: true,
        createdAt: true,
        owner: {
          select: {
            profile: {
              select: { fullName: true, phoneNumber: true, avatarUrl: true },
            },
          },
        },
        gymPlans: {
          where: { isActive: true },
          select: {
            id: true,
            name: true,
            price: true,
            planType: true,
            durationDays: true,
            sessionCount: true,
          },
        },
        sessionRates: {
          where: { isActive: true },
          select: { ratePerSession: true, effectiveFrom: true },
        },
        _count: {
          select: { gymSubscriptions: true, checkIns: true, userRoles: true },
        },
      };
    }

    if (ctx?.isStaff) {
      return {
        id: true,
        name: true,
        address: true,
        lat: true,
        lng: true,
        logoUrl: true,
        tier: true,
        isApproved: true,
        gymPlans: {
          where: { isActive: true },
          select: { id: true, name: true, planType: true },
        },
        _count: { select: { gymSubscriptions: true, checkIns: true } },
      };
    }

    return {
      id: true,
      name: true,
      address: true,
      lat: true,
      lng: true,
      logoUrl: true,
      tier: true,
      isApproved: true,
    };
  }
}
