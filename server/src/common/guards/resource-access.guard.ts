import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  NotFoundException,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PrismaService } from '../../prisma/prisma.service';
import { SYSTEM_ROLES } from '../../auth/constants/roles';
import type { RequestContext } from '../types/request-context.type';

export const RESOURCE_KEY = 'resource';
export type ResourceType = 'gym' | 'profile';

export const CheckResource = (resource: ResourceType) =>
  SetMetadata(RESOURCE_KEY, resource);

@Injectable()
export class ResourceAccessGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const resource = this.reflector.getAllAndOverride<ResourceType>(
      RESOURCE_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!resource) return true;

    const request = context.switchToHttp().getRequest();
    const ctx = request.context as RequestContext | undefined;
    if (!ctx) throw new ForbiddenException('Authentication required');
    if (ctx.isAdmin) return true;

    const resourceId = this.getResourceId(request, resource);
    if (!resourceId) throw new ForbiddenException('Missing resource id');

    if (resource === 'gym') return this.checkGymAccess(resourceId, ctx);
    if (resource === 'profile') return this.checkProfileAccess(resourceId, ctx);

    return false;
  }

  private getResourceId(request: any, resource: ResourceType): string | undefined {
    if (resource === 'gym') {
      return request.params?.id ?? request.params?.gymId;
    }
    return request.params?.id ?? request.params?.profileId;
  }

  private async checkGymAccess(
    gymId: string,
    ctx: RequestContext,
  ): Promise<boolean> {
    const gym = await this.prisma.gym.findUnique({
      where: { id: gymId },
      select: { id: true, ownerId: true, tier: true, isApproved: true },
    });
    if (!gym) throw new NotFoundException('Gym not found');

    if (ctx.isOwner && gym.ownerId === ctx.userId) return true;

    const hasScopedStaffRole = ctx.roleAssignments.some(
      (role) =>
        role.gymId === gym.id &&
        [SYSTEM_ROLES.STAFF, SYSTEM_ROLES.MANAGER, SYSTEM_ROLES.TRAINER]
          .includes(role.roleName as any),
    );
    if (ctx.isStaff && hasScopedStaffRole) return true;

    if (ctx.isMember && ctx.profileId && gym.isApproved) {
      const membership = await this.prisma.membership.findFirst({
        where: {
          profileId: ctx.profileId,
          status: { in: ['PAID', 'ACTIVE_KINETIC'] },
          platformPlan: { isActive: true },
        },
        select: { platformPlan: { select: { tier: true } } },
        orderBy: { createdAt: 'desc' },
      });

      if (membership && gym.tier >= membership.platformPlan.tier) return true;
    }

    throw new ForbiddenException('You do not have access to this gym');
  }

  private async checkProfileAccess(
    profileId: string,
    ctx: RequestContext,
  ): Promise<boolean> {
    const profile = await this.prisma.profile.findUnique({
      where: { id: profileId },
      select: {
        id: true,
        userId: true,
        createdAtGymId: true,
        gymSubscriptions: { select: { gymId: true } },
      },
    });
    if (!profile) throw new NotFoundException('Profile not found');

    if (ctx.profileId === profile.id || profile.userId === ctx.userId) {
      return true;
    }

    const accessibleGymIds = new Set(
      ctx.roleAssignments
        .filter((role) => role.gymId)
        .map((role) => role.gymId as string),
    );

    if (
      profile.createdAtGymId &&
      accessibleGymIds.has(profile.createdAtGymId)
    ) {
      return true;
    }

    if (
      profile.gymSubscriptions.some((subscription) =>
        accessibleGymIds.has(subscription.gymId),
      )
    ) {
      return true;
    }

    throw new ForbiddenException('You do not have access to this profile');
  }
}
