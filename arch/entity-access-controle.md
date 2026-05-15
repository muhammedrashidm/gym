# GymOS — NestJS API Architecture: Role-Based Data Scoping

> The core problem: the same HTTP endpoint must return **different data subsets** based on who is calling it — not just whether they are allowed to call it. This document defines the complete architecture for solving this across every entity in the system.

---

## Table of Contents

1. [The Core Problem, Named Precisely](#1-the-core-problem-named-precisely)
2. [Architecture Layers](#2-architecture-layers)
3. [JWT Design and RequestContext](#3-jwt-design-and-requestcontext)
4. [Role Definitions](#4-role-definitions)
5. [Guards: Who Can Enter](#5-guards-who-can-enter)
6. [Scope Resolvers: What They See](#6-scope-resolvers-what-they-see)
7. [Resource Ownership Guard](#7-resource-ownership-guard)
8. [Gym Module — Full Implementation](#8-gym-module--full-implementation)
9. [Profile Module — Full Implementation](#9-profile-module--full-implementation)
10. [Individual Resource Access Pattern](#10-individual-resource-access-pattern)
11. [Remix to NestJS Contract](#11-remix-to-nestjs-contract)
12. [Folder Structure](#12-folder-structure)

---

## 1. The Core Problem, Named Precisely

There are **two separate concerns** that look like one:

```
CONCERN A — Authentication + Authorization
           Can this user reach this endpoint at all?
           → Solved by Guards

CONCERN B — Data Scoping
           Given they CAN reach it, what subset of data do they see?
           → Solved by Scope Resolvers
```

Most implementations only cover Concern A. The hard part in GymOS is Concern B.

### The Scoping Matrix

This is the ground truth. Everything else derives from this table.

```
Entity      | SUPER_ADMIN  | ADMIN_STAFF  | GYM_OWNER              | STAFF                  | MEMBER
------------+--------------+--------------+------------------------+------------------------+----------------------
Gyms list   | ALL          | ALL          | own gyms only          | assigned gym only      | accessible (tier ≥)
            |              |              | Gym.ownerId = me       | UserRole.gymId         | gym.tier >= plan.tier
------------+--------------+--------------+------------------------+------------------------+----------------------
Single gym  | any gym      | any gym      | only if ownerId = me   | only if gymId matches  | only if tier check
------------+--------------+--------------+------------------------+------------------------+----------------------
Profiles    | ALL roles    | ALL roles    | MEMBER profiles        | MEMBER profiles        | own profile only
            |              |              | across own gyms        | in assigned gym only   |
------------+--------------+--------------+------------------------+------------------------+----------------------
Membership  | ALL          | ALL          | own gym members        | own gym members        | own membership only
------------+--------------+--------------+------------------------+------------------------+----------------------
Transactions| ALL          | ALL          | own gym txns           | own gym txns           | own txns only
```

The architecture must make it **impossible** to return wrong-scope data — not just rely on if/else scattered across every service.

---

## 2. Architecture Layers

```
HTTP Request
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  JwtAuthGuard                                        │
│  Validates token, builds RequestContext on req       │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  RolesGuard                                          │
│  Checks if user roles satisfy @Roles() decorator    │
│  Returns 403 if not — endpoint handler never runs   │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  ResourceAccessGuard  (optional, per endpoint)       │
│  For individual routes like GET /gyms/:id           │
│  Checks if user has access to THIS specific record  │
│  Returns 403 if not — handler never runs            │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  Controller                                          │
│  Calls ScopeResolver to get the data filter         │
│  Passes filter to Service — nothing else            │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  ScopeResolver (one per entity)                      │
│  Reads RequestContext, returns a Prisma WHERE clause │
│  Single place where all scoping logic lives         │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  Service                                             │
│  Executes Prisma query using the WHERE clause       │
│  Has zero knowledge of roles or users               │
└──────────────────────┬──────────────────────────────┘
                       │
    PrismaService → PostgreSQL
```

**The golden rule:** Services never read `req.user` or `RequestContext`. They receive an already-resolved filter. This makes every service fully testable without any auth context.

---

## 3. JWT Design and RequestContext

### JWT Payload

```typescript
// src/auth/types/jwt-payload.type.ts

export interface JwtPayload {
  sub:    string;        // User.id (UUID)
  phone:  string;        // User.phoneNumber
  roles:  RoleName[];    // e.g. ['OWNER', 'MEMBER']
  gymId?: string;        // Set for STAFF: their assigned gym
  iat:    number;
  exp:    number;
}
```

### RequestContext

Attached to `req` after JWT validation. This is the canonical resolved identity object that every downstream layer reads.

```typescript
// src/common/types/request-context.type.ts

export type RoleName =
  | 'SUPER_ADMIN'
  | 'ADMIN_STAFF'
  | 'GYM_OWNER'
  | 'STAFF'
  | 'MEMBER';

export interface GymContext {
  gymId:   string;
  gymTier: number;
  isOwner: boolean;  // this user owns this gym
  isStaff: boolean;  // this user is staff at this gym
}

export interface RequestContext {
  userId:      string;
  phoneNumber: string;
  roles:       RoleName[];
  profileId?:  string;      // resolved after profile creation
  gymContext?: GymContext;   // set when operating within a gym scope

  // Computed convenience booleans — resolved once, used everywhere
  isSuperAdmin: boolean;
  isAdminStaff: boolean;
  isAdmin:      boolean;    // isSuperAdmin || isAdminStaff
  isOwner:      boolean;
  isStaff:      boolean;
  isMember:     boolean;
}
```

### Decorator to Inject Context into Controllers

```typescript
// src/common/decorators/request-context.decorator.ts

import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { RequestContext } from '../types/request-context.type';

export const ReqContext = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestContext => {
    const request = ctx.switchToHttp().getRequest();
    return request.context as RequestContext;
  },
);
```

Usage in any controller:

```typescript
@Get()
async findAll(@ReqContext() ctx: RequestContext) {
  // ctx is fully typed — no casting
}
```

---

## 4. Role Definitions

```typescript
// src/common/constants/roles.constant.ts

export enum RoleName {
  SUPER_ADMIN = 'SUPER_ADMIN',
  ADMIN_STAFF = 'ADMIN_STAFF',
  GYM_OWNER   = 'GYM_OWNER',
  STAFF       = 'STAFF',
  MEMBER      = 'MEMBER',
}

// Matches the seeded id values in your Role table
export const ROLE_IDS: Record<RoleName, number> = {
  SUPER_ADMIN: 1,
  ADMIN_STAFF: 2,
  GYM_OWNER:   3,
  STAFF:       4,
  MEMBER:      5,
};
```

### The `@Roles()` Decorator

```typescript
// src/common/decorators/roles.decorator.ts

import { SetMetadata } from '@nestjs/common';
import type { RoleName } from '../constants/roles.constant';

export const ROLES_KEY = 'roles';

// User must have AT LEAST ONE of the listed roles
export const Roles = (...roles: RoleName[]) => SetMetadata(ROLES_KEY, roles);
```

---

## 5. Guards: Who Can Enter

### JwtAuthGuard

```typescript
// src/auth/guards/jwt-auth.guard.ts

import {
  Injectable, CanActivate, ExecutionContext, UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from 'src/prisma/prisma.service';
import type { JwtPayload } from '../types/jwt-payload.type';
import type { RequestContext } from 'src/common/types/request-context.type';
import { RoleName } from 'src/common/constants/roles.constant';
import { IS_PUBLIC_KEY } from 'src/common/decorators/public.decorator';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Skip auth for @Public() endpoints (e.g. /auth/request-otp)
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) throw new UnauthorizedException('No token provided');

    let payload: JwtPayload;
    try {
      payload = this.jwtService.verify<JwtPayload>(token);
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }

    request.context = await this.buildContext(payload, request);
    return true;
  }

  private extractToken(request: any): string | undefined {
    const auth = request.headers?.['authorization'];
    if (!auth?.startsWith('Bearer ')) return undefined;
    return auth.slice(7);
  }

  private async buildContext(
    payload: JwtPayload,
    request: any,
  ): Promise<RequestContext> {
    const roles = payload.roles as RoleName[];

    // Resolve profileId — needed for member scoping
    const profile = await this.prisma.profile.findUnique({
      where:  { userId: payload.sub },
      select: { id: true },
    });

    // Gym context — read from X-Gym-Id header (preferred) or JWT payload
    // The header lets Remix pass gym context without re-issuing tokens
    const gymId = request.headers['x-gym-id'] ?? payload.gymId;
    let gymContext: RequestContext['gymContext'] = undefined;

    if (gymId) {
      const gym = await this.prisma.gym.findUnique({
        where:  { id: gymId },
        select: { id: true, tier: true, ownerId: true },
      });
      if (gym) {
        gymContext = {
          gymId:   gym.id,
          gymTier: gym.tier,
          isOwner: gym.ownerId === payload.sub,
          isStaff: roles.includes(RoleName.STAFF),
        };
      }
    }

    return {
      userId:      payload.sub,
      phoneNumber: payload.phone,
      roles,
      profileId:   profile?.id,
      gymContext,
      isSuperAdmin: roles.includes(RoleName.SUPER_ADMIN),
      isAdminStaff: roles.includes(RoleName.ADMIN_STAFF),
      isAdmin:
        roles.includes(RoleName.SUPER_ADMIN) ||
        roles.includes(RoleName.ADMIN_STAFF),
      isOwner:  roles.includes(RoleName.GYM_OWNER),
      isStaff:  roles.includes(RoleName.STAFF),
      isMember: roles.includes(RoleName.MEMBER),
    };
  }
}
```

### RolesGuard

```typescript
// src/auth/guards/roles.guard.ts

import {
  Injectable, CanActivate, ExecutionContext, ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from 'src/common/decorators/roles.decorator';
import type { RoleName } from 'src/common/constants/roles.constant';
import type { RequestContext } from 'src/common/types/request-context.type';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<RoleName[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // No @Roles() on endpoint — JWT alone is sufficient
    if (!required || required.length === 0) return true;

    const ctx: RequestContext = context
      .switchToHttp()
      .getRequest().context;

    const hasRole = required.some(role => ctx.roles.includes(role));

    if (!hasRole) {
      throw new ForbiddenException(
        `Requires one of: [${required.join(', ')}]. ` +
        `You have: [${ctx.roles.join(', ')}]`,
      );
    }

    return true;
  }
}
```

### Register Both Guards Globally

```typescript
// src/app.module.ts

import { APP_GUARD } from '@nestjs/core';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';

@Module({
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },  // runs first — always
    { provide: APP_GUARD, useClass: RolesGuard },    // runs second — checks roles
  ],
})
export class AppModule {}
```

Every endpoint is JWT-protected by default. To open one up:

```typescript
// src/common/decorators/public.decorator.ts
import { SetMetadata } from '@nestjs/common';
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

// Usage
@Public()
@Post('request-otp')
requestOtp() { ... }
```

---

## 6. Scope Resolvers: What They See

A `ScopeResolver` is a per-entity injectable that takes a `RequestContext` and returns a **Prisma `where` clause**. The controller calls it, gets the filter, and passes it to the service. The service knows nothing about roles.

### GymScopeResolver

```typescript
// src/gym/gym.scope-resolver.ts

import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import type { Prisma } from '@prisma/client';
import type { RequestContext } from 'src/common/types/request-context.type';

@Injectable()
export class GymScopeResolver {

  constructor(private readonly prisma: PrismaService) {}

  async resolve(ctx: RequestContext): Promise<Prisma.GymWhereInput> {

    // Platform admins see every gym — approved or pending
    if (ctx.isAdmin) {
      return {};
    }

    // Owner sees only gyms they own
    if (ctx.isOwner) {
      return { ownerId: ctx.userId };
    }

    // Staff sees only their assigned gym
    if (ctx.isStaff) {
      const gymId = ctx.gymContext?.gymId;
      if (!gymId) return { id: '__NO_MATCH__' };
      return { id: gymId };
    }

    // Platform member sees gyms accessible by their tier
    if (ctx.isMember && ctx.profileId) {
      const membership = await this.prisma.membership.findFirst({
        where:   { profileId: ctx.profileId, status: 'PAID' },
        include: { platformPlan: { select: { tier: true } } },
      });

      const memberTier = membership?.platformPlan?.tier;

      if (!memberTier) {
        // No platform plan — only gyms where they have a gym plan
        const gymSubs = await this.prisma.gymSubscription.findMany({
          where:  { profileId: ctx.profileId, status: 'ACTIVE' },
          select: { gymId: true },
        });
        return { id: { in: gymSubs.map(s => s.gymId) } };
      }

      // Access rule: gym.tier >= member.plan.tier
      return {
        tier:       { gte: memberTier },
        isApproved: true,
      };
    }

    return { id: '__NO_MATCH__' };
  }
}
```

### ProfileScopeResolver

```typescript
// src/profile/profile.scope-resolver.ts

import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import type { Prisma } from '@prisma/client';
import type { RequestContext } from 'src/common/types/request-context.type';

@Injectable()
export class ProfileScopeResolver {

  constructor(private readonly prisma: PrismaService) {}

  async resolve(ctx: RequestContext): Promise<Prisma.ProfileWhereInput> {

    // Admins see ALL profiles — members, staff, owners
    if (ctx.isAdmin) {
      return {};
    }

    // Owner sees MEMBER profiles across all gyms they own
    if (ctx.isOwner) {
      const ownedGyms = await this.prisma.gym.findMany({
        where:  { ownerId: ctx.userId },
        select: { id: true },
      });
      const gymIds = ownedGyms.map(g => g.id);

      return {
        OR: [
          {
            // Members enrolled in gym plans at owner's gyms
            gymSubscriptions: {
              some: { gymId: { in: gymIds } },
            },
          },
          {
            // Platform members who have checked in at owner's gyms
            checkIns: {
              some: { gymId: { in: gymIds } },
            },
          },
        ],
      };
    }

    // Staff sees MEMBER profiles in their assigned gym only
    if (ctx.isStaff) {
      const gymId = ctx.gymContext?.gymId;
      if (!gymId) return { id: '__NO_MATCH__' };

      return {
        OR: [
          {
            gymSubscriptions: {
              some: { gymId },
            },
          },
          {
            // Members currently checked in today
            checkIns: {
              some: {
                gymId,
                checkInAt: {
                  gte: new Date(new Date().setHours(0, 0, 0, 0)),
                },
              },
            },
          },
        ],
      };
    }

    // Member sees only their own profile — they should use /me instead
    if (ctx.isMember && ctx.profileId) {
      return { id: ctx.profileId };
    }

    return { id: '__NO_MATCH__' };
  }
}
```

---

## 7. Resource Ownership Guard

For routes like `GET /gyms/:id` — a specific resource ID is in the URL. We need to verify that this user has access to **that particular record** before the handler runs.

```typescript
// src/common/guards/resource-access.guard.ts

import {
  Injectable, CanActivate, ExecutionContext,
  ForbiddenException, NotFoundException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { SetMetadata } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import type { RequestContext } from '../types/request-context.type';

export const RESOURCE_KEY = 'resource_check';
export type ResourceType = 'gym' | 'profile';

export const CheckResource = (type: ResourceType) =>
  SetMetadata(RESOURCE_KEY, type);

@Injectable()
export class ResourceAccessGuard implements CanActivate {

  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const resourceType = this.reflector.get<ResourceType>(
      RESOURCE_KEY,
      context.getHandler(),
    );

    // Guard only activates when @CheckResource() is on the handler
    if (!resourceType) return true;

    const request = context.switchToHttp().getRequest();
    const ctx: RequestContext = request.context;
    const id: string = request.params.id ?? request.params.gymId;

    if (!id) return true;

    if (resourceType === 'gym')     return this.checkGymAccess(ctx, id);
    if (resourceType === 'profile') return this.checkProfileAccess(ctx, id);

    return true;
  }

  // ── GYM ACCESS ───────────────────────────────────────────────────

  async checkGymAccess(ctx: RequestContext, gymId: string): Promise<boolean> {
    // Admins pass unconditionally
    if (ctx.isAdmin) return true;

    const gym = await this.prisma.gym.findUnique({
      where:  { id: gymId },
      select: { id: true, ownerId: true, tier: true, isApproved: true },
    });

    if (!gym) throw new NotFoundException(`Gym not found`);

    if (ctx.isOwner) {
      if (gym.ownerId !== ctx.userId) {
        throw new ForbiddenException('You do not own this gym');
      }
      return true;
    }

    if (ctx.isStaff) {
      if (ctx.gymContext?.gymId !== gymId) {
        throw new ForbiddenException('You are not assigned to this gym');
      }
      return true;
    }

    if (ctx.isMember && ctx.profileId) {
      const ok = await this.isGymAccessibleToMember(ctx.profileId, gymId, gym.tier);
      if (!ok) throw new ForbiddenException('Your plan does not include this gym');
      return true;
    }

    throw new ForbiddenException('Access denied');
  }

  // ── PROFILE ACCESS ────────────────────────────────────────────────

  async checkProfileAccess(
    ctx: RequestContext,
    profileId: string,
  ): Promise<boolean> {
    if (ctx.isAdmin) return true;

    // Members can only view their own profile
    if (ctx.isMember) {
      if (ctx.profileId !== profileId) throw new ForbiddenException('Access denied');
      return true;
    }

    // Owner: profile must be in one of their gyms
    if (ctx.isOwner) {
      const inOwnedGym = await this.prisma.gymSubscription.findFirst({
        where: {
          profileId,
          gym: { ownerId: ctx.userId },
        },
      });
      if (!inOwnedGym) throw new ForbiddenException('This member is not in your gym');
      return true;
    }

    // Staff: profile must be in their assigned gym
    if (ctx.isStaff && ctx.gymContext?.gymId) {
      const inGym = await this.prisma.gymSubscription.findFirst({
        where: { profileId, gymId: ctx.gymContext.gymId },
      });
      if (!inGym) throw new ForbiddenException('This member is not in your gym');
      return true;
    }

    throw new ForbiddenException('Access denied');
  }

  // ── HELPERS ───────────────────────────────────────────────────────

  private async isGymAccessibleToMember(
    profileId: string,
    gymId: string,
    gymTier: number,
  ): Promise<boolean> {
    const [membership, gymSub] = await Promise.all([
      this.prisma.membership.findFirst({
        where:   { profileId, status: 'PAID' },
        include: { platformPlan: { select: { tier: true } } },
      }),
      this.prisma.gymSubscription.findFirst({
        where: { profileId, gymId, status: 'ACTIVE' },
      }),
    ]);

    // Direct gym plan — always accessible
    if (gymSub) return true;

    // Platform plan tier check: gym.tier >= member.plan.tier
    const memberTier = membership?.platformPlan?.tier;
    if (memberTier) return gymTier >= memberTier;

    return false;
  }
}
```

---

## 8. Gym Module — Full Implementation

### Controller

```typescript
// src/gym/gym.controller.ts

import {
  Controller, Get, Post, Patch, Param, Body, Query, UseGuards,
} from '@nestjs/common';
import { GymService } from './gym.service';
import { GymScopeResolver } from './gym.scope-resolver';
import { ReqContext } from 'src/common/decorators/request-context.decorator';
import { Roles } from 'src/common/decorators/roles.decorator';
import { CheckResource, ResourceAccessGuard } from 'src/common/guards/resource-access.guard';
import { RoleName } from 'src/common/constants/roles.constant';
import type { RequestContext } from 'src/common/types/request-context.type';
import type { CreateGymDto } from './dto/create-gym.dto';
import type { GymListQueryDto } from './dto/gym-list-query.dto';

@Controller('gyms')
export class GymController {
  constructor(
    private readonly gymService: GymService,
    private readonly gymScopeResolver: GymScopeResolver,
  ) {}

  // ── LIST ─────────────────────────────────────────────────────────
  // Admin  → all gyms
  // Owner  → their gyms only
  // Staff  → their assigned gym only
  // Member → tier-accessible gyms
  @Get()
  @Roles(
    RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF,
    RoleName.GYM_OWNER, RoleName.STAFF, RoleName.MEMBER,
  )
  async findAll(
    @ReqContext() ctx: RequestContext,
    @Query() query: GymListQueryDto,
  ) {
    const where = await this.gymScopeResolver.resolve(ctx);
    return this.gymService.findAll({ where, query, ctx });
  }

  // ── SINGLE GYM ───────────────────────────────────────────────────
  // ResourceAccessGuard checks ownership/assignment BEFORE handler runs.
  // If it passes, we know the user is allowed — service just fetches.
  @Get(':id')
  @UseGuards(ResourceAccessGuard)
  @CheckResource('gym')
  @Roles(
    RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF,
    RoleName.GYM_OWNER, RoleName.STAFF, RoleName.MEMBER,
  )
  async findOne(
    @Param('id') id: string,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.gymService.findOne(id, ctx);
  }

  // ── CREATE ───────────────────────────────────────────────────────
  @Post()
  @Roles(RoleName.GYM_OWNER)
  async create(
    @Body() dto: CreateGymDto,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.gymService.create(dto, ctx.userId);
  }

  // ── APPROVE (admin only) ─────────────────────────────────────────
  @Patch(':id/approve')
  @Roles(RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF)
  async approve(
    @Param('id') id: string,
    @Body('tier') tier: number,
  ) {
    return this.gymService.approve(id, tier);
  }

  // ── SET SESSION RATE (admin only) ────────────────────────────────
  @Post(':id/session-rate')
  @Roles(RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF)
  async setSessionRate(
    @Param('id') id: string,
    @Body('ratePerSession') rate: number,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.gymService.setSessionRate(id, rate, ctx.userId);
  }
}
```

### Service

```typescript
// src/gym/gym.service.ts

import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import type { Prisma } from '@prisma/client';
import type { RequestContext } from 'src/common/types/request-context.type';
import type { GymListQueryDto } from './dto/gym-list-query.dto';
import type { CreateGymDto } from './dto/create-gym.dto';

// Services NEVER read RequestContext for filtering.
// They receive the resolved Prisma WHERE clause from the controller.
// They DO read ctx to decide the SELECT shape (what fields to return).

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
    ctx:   RequestContext;
  }) {
    const { page = 1, limit = 20, search, isApproved } = query;

    // Merge scope filter with user-supplied query filters
    const mergedWhere: Prisma.GymWhereInput = {
      ...where,
      ...(search && {
        name: { contains: search, mode: 'insensitive' },
      }),
      // Only admins can request isApproved=false (pending gyms)
      ...(isApproved !== undefined && ctx.isAdmin && { isApproved }),
    };

    const [data, total] = await Promise.all([
      this.prisma.gym.findMany({
        where:   mergedWhere,
        skip:    (page - 1) * limit,
        take:    limit,
        orderBy: { createdAt: 'desc' },
        select:  this.listSelect(ctx),
      }),
      this.prisma.gym.count({ where: mergedWhere }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string, ctx: RequestContext) {
    return this.prisma.gym.findUniqueOrThrow({
      where:  { id },
      select: this.detailSelect(ctx),
    });
  }

  // ── SELECT SHAPES ─────────────────────────────────────────────────

  // List view — lighter payload
  private listSelect(ctx: RequestContext): Prisma.GymSelect {
    const base: Prisma.GymSelect = {
      id: true, name: true, address: true, logoUrl: true,
      tier: true, isApproved: true, createdAt: true,
      _count: { select: { gymSubscriptions: true } },
    };

    if (ctx.isAdmin) {
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

  // Detail view — richer payload
  private detailSelect(ctx: RequestContext): Prisma.GymSelect {
    // Admin and Owner see financial + operational detail
    if (ctx.isAdmin || ctx.isOwner) {
      return {
        id: true, name: true, address: true, lat: true, lng: true,
        logoUrl: true, tier: true, isApproved: true, createdAt: true,
        owner: {
          select: {
            profile: { select: { fullName: true, phoneNumber: true, avatarUrl: true } },
          },
        },
        gymPlans: {
          where:  { isActive: true },
          select: { id: true, name: true, price: true, planType: true, durationDays: true },
        },
        sessionRates: {
          where:  { isActive: true },
          select: { ratePerSession: true, effectiveFrom: true },
        },
        _count: {
          select: { gymSubscriptions: true, checkIns: true, userRoles: true },
        },
      };
    }

    // Staff — operational data, no financial
    if (ctx.isStaff) {
      return {
        id: true, name: true, address: true, lat: true, lng: true,
        logoUrl: true, tier: true, isApproved: true,
        gymPlans: {
          where:  { isActive: true },
          select: { id: true, name: true, planType: true },
        },
        _count: { select: { gymSubscriptions: true, checkIns: true } },
      };
    }

    // Member — public info only
    return {
      id: true, name: true, address: true, lat: true, lng: true,
      logoUrl: true, tier: true, isApproved: true,
    };
  }

  async create(dto: CreateGymDto, ownerId: string) {
    return this.prisma.gym.create({
      data: {
        name:       dto.name,
        address:    dto.address,
        lat:        dto.lat,
        lng:        dto.lng,
        logoUrl:    dto.logoUrl,
        isApproved: false,
        tier:       3,
        ownerId,
      },
    });
  }

  async approve(gymId: string, tier: number) {
    return this.prisma.gym.update({
      where: { id: gymId },
      data:  { isApproved: true, tier },
    });
  }

  async setSessionRate(gymId: string, rate: number, adminId: string) {
    // Deactivate existing rate
    await this.prisma.gymSessionRate.updateMany({
      where: { gymId, isActive: true },
      data:  { isActive: false },
    });
    // Create new active rate
    return this.prisma.gymSessionRate.create({
      data: {
        gymId,
        ratePerSession:  rate,
        effectiveFrom:   new Date(),
        setByAdminId:    adminId,
        isActive:        true,
      },
    });
  }
}
```

---

## 9. Profile Module — Full Implementation

### Controller

```typescript
// src/profile/profile.controller.ts

import { Controller, Get, Patch, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { ProfileScopeResolver } from './profile.scope-resolver';
import { ReqContext } from 'src/common/decorators/request-context.decorator';
import { Roles } from 'src/common/decorators/roles.decorator';
import { CheckResource, ResourceAccessGuard } from 'src/common/guards/resource-access.guard';
import { RoleName } from 'src/common/constants/roles.constant';
import type { RequestContext } from 'src/common/types/request-context.type';
import type { ProfileListQueryDto } from './dto/profile-list-query.dto';

@Controller('profiles')
export class ProfileController {
  constructor(
    private readonly profileService: ProfileService,
    private readonly profileScopeResolver: ProfileScopeResolver,
  ) {}

  // ── LIST ─────────────────────────────────────────────────────────
  // Admin     → all profiles (any role)
  // Owner     → member profiles across their gyms
  // Staff     → member profiles in their gym
  // Member    → this endpoint is blocked for members; they use /me
  @Get()
  @Roles(
    RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF,
    RoleName.GYM_OWNER, RoleName.STAFF,
  )
  async findAll(
    @ReqContext() ctx: RequestContext,
    @Query() query: ProfileListQueryDto,
  ) {
    const where = await this.profileScopeResolver.resolve(ctx);
    return this.profileService.findAll({ where, query, ctx });
  }

  // ── SINGLE PROFILE ────────────────────────────────────────────────
  @Get(':id')
  @UseGuards(ResourceAccessGuard)
  @CheckResource('profile')
  @Roles(
    RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF,
    RoleName.GYM_OWNER, RoleName.STAFF, RoleName.MEMBER,
  )
  async findOne(
    @Param('id') id: string,
    @ReqContext() ctx: RequestContext,
  ) {
    return this.profileService.findOne(id, ctx);
  }
}
```

### Service

```typescript
// src/profile/profile.service.ts

import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import type { Prisma } from '@prisma/client';
import type { RequestContext } from 'src/common/types/request-context.type';
import type { ProfileListQueryDto } from './dto/profile-list-query.dto';

@Injectable()
export class ProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll({
    where,
    query,
    ctx,
  }: {
    where: Prisma.ProfileWhereInput;
    query: ProfileListQueryDto;
    ctx:   RequestContext;
  }) {
    const { page = 1, limit = 20, search, role } = query;

    const mergedWhere: Prisma.ProfileWhereInput = {
      ...where,
      isActive: true,
      ...(search && {
        OR: [
          { fullName:    { contains: search, mode: 'insensitive' } },
          { phoneNumber: { contains: search } },
        ],
      }),
      // Admin only: filter profiles by the role their User has
      ...(ctx.isAdmin && role && {
        user: {
          userRoles: { some: { role: { name: role } } },
        },
      }),
    };

    // Ordering:
    // Admin     → newest first
    // Owner/Staff → unclaimed gym-managed members first (need action),
    //              then claimed members, then by date
    const orderBy: Prisma.ProfileOrderByWithRelationInput[] = ctx.isAdmin
      ? [{ createdAt: 'desc' }]
      : [{ isClaimed: 'asc' }, { createdAt: 'desc' }];

    const [data, total] = await Promise.all([
      this.prisma.profile.findMany({
        where:   mergedWhere,
        skip:    (page - 1) * limit,
        take:    limit,
        orderBy,
        select:  this.buildSelect(ctx),
      }),
      this.prisma.profile.count({ where: mergedWhere }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(profileId: string, ctx: RequestContext) {
    return this.prisma.profile.findUniqueOrThrow({
      where:  { id: profileId },
      select: this.buildSelect(ctx, true),
    });
  }

  private buildSelect(
    ctx: RequestContext,
    full = false,
  ): Prisma.ProfileSelect {
    const base: Prisma.ProfileSelect = {
      id: true, fullName: true, phoneNumber: true, avatarUrl: true,
      sex: true, expLevel: true, isKinetic: true, isClaimed: true,
      createdAt: true,
    };

    if (!full) return base;

    const withDetail: Prisma.ProfileSelect = {
      ...base,
      age: true,
      gymSubscriptions: {
        where:  { status: 'ACTIVE' },
        select: {
          id: true, status: true, autoDebit: true,
          startDate: true, expiryDate: true,
          gymPlan: { select: { name: true, price: true, planType: true } },
          gym:     { select: { id: true, name: true } },
        },
      },
      memberships: {
        where:  { status: 'PAID' },
        select: {
          id: true, status: true, expiryDate: true,
          platformPlan: { select: { name: true, tier: true } },
        },
      },
      bodyMetrics: {
        orderBy: { recordedAt: 'desc' },
        take:    5,
        select:  { weight: true, height: true, bodyFatPct: true, recordedAt: true },
      },
    };

    // Admins additionally see the User record + all UserRoles
    if (ctx.isAdmin) {
      return {
        ...withDetail,
        user: {
          select: {
            id: true, isActive: true, createdAt: true,
            userRoles: {
              select: {
                role:       { select: { name: true } },
                gym:        { select: { id: true, name: true } },
                assignedAt: true,
              },
            },
          },
        },
      };
    }

    return withDetail;
  }
}
```

---

## 10. Individual Resource Access Pattern

### The Exact Scenario from the Problem Statement

A Remix page renders at `/gyms/:gymId`. An owner opens it — should see their gym data. An admin opens it — should see the same page with the same URL but full platform data. A staff member opens a gym they are not assigned to — should get a 403.

This is solved by layering three things that each have a single responsibility:

```
1. RolesGuard         → Is this role allowed to view a gym detail page at all?
2. ResourceAccessGuard → Does THIS specific user have access to THIS specific gym?
3. detailSelect()      → What FIELDS do they see given their role?
```

The full request flow for `GET /gyms/gym_abc123`:

```
JwtAuthGuard
  ├─ Validates token
  ├─ Reads X-Gym-Id: gym_abc123 header from Remix loader
  ├─ Looks up gym_abc123 in DB
  └─ Builds RequestContext:
       gymContext = { gymId: 'gym_abc123', isOwner: true/false, isStaff: true/false }

RolesGuard
  └─ @Roles(SUPER_ADMIN, ADMIN_STAFF, GYM_OWNER, STAFF, MEMBER) → passes

ResourceAccessGuard  (@CheckResource('gym'))
  ├─ ctx.isAdmin?  → passes immediately
  ├─ ctx.isOwner?  → gym.ownerId === ctx.userId? → pass or 403
  ├─ ctx.isStaff?  → ctx.gymContext.gymId === 'gym_abc123'? → pass or 403
  └─ ctx.isMember? → tier check → pass or 403

GymController.findOne('gym_abc123', ctx)
  └─ gymService.findOne('gym_abc123', ctx)
       └─ detailSelect(ctx) → admin sees financials, staff sees operational data
```

### Handling gym slug in URL

If the route uses `/gyms/iron-temple-calicut` (slug) instead of UUID, add a `slug` field to the `Gym` model and resolve it in the guard:

```typescript
// In ResourceAccessGuard.checkGymAccess — resolve either UUID or slug
const gym = await this.prisma.gym.findFirst({
  where:  { OR: [{ id: gymId }, { slug: gymId }] },
  select: { id: true, ownerId: true, tier: true, isApproved: true },
});
```

The rest of the logic is identical.

---

## 11. Remix to NestJS Contract

### How Remix loaders pass gym context

```typescript
// app/features/gym/pages/gym-detail.tsx

export async function loader({ params, request }: LoaderFunctionArgs) {
  const gymId = params.gymId;
  const token = await getSessionToken(request);  // from session cookie

  const res = await fetch(`${process.env.API_URL}/gyms/${gymId}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'X-Gym-Id':      gymId,  // tells NestJS which gym context to resolve
    },
  });

  // Let NestJS errors become Remix errors — no logic duplication
  if (res.status === 403) throw new Response('Forbidden', { status: 403 });
  if (res.status === 404) throw new Response('Not Found', { status: 404 });

  return res.json();
}
```

The Remix page receives the data already scoped correctly. The component does not need to know what role the user has — it just renders what the API returned.

### Why `X-Gym-Id` header

The guard could read `req.params.id` directly instead. The header approach is cleaner because:

- `JwtAuthGuard` runs before the route handler even parses params in some setups.
- Owners switching between multiple gyms in the same session can change gym context without a token refresh.
- A single pattern works for both list endpoints (no `:id` in path) and detail endpoints.

### Multi-gym owner context switching

When an owner clicks into Gym B after viewing Gym A:

```typescript
// Option A — header only (recommended for Phase 1)
// Remix just passes the new gymId as X-Gym-Id on every request.
// No token refresh. JwtAuthGuard resolves it from the header.
headers['X-Gym-Id'] = selectedGymId;

// Option B — embedded in token (if gymId must be in the JWT for mobile)
const res = await fetch('/auth/switch-gym', {
  method:  'POST',
  headers: { Authorization: `Bearer ${currentToken}` },
  body:    JSON.stringify({ gymId: newGymId }),
});
const { accessToken } = await res.json();
// New token has gymId in payload
```

Option A is recommended. No token rotation, no extra roundtrip.

---

## Decision Tree — Quick Reference

Every request follows this exact sequence:

```
Request
  │
  ├─ @Public() on endpoint? ──YES──→ handler (no auth)
  │
  ├─ [JwtAuthGuard] valid token? ──NO──→ 401
  │   YES → build RequestContext (roles, gymContext, profileId)
  │
  ├─ [RolesGuard] @Roles() decorator present?
  │   NO  → pass (JWT sufficient)
  │   YES → user has a required role? ──NO──→ 403
  │
  ├─ [ResourceAccessGuard] @CheckResource() present?
  │   NO  → pass
  │   YES → isAdmin? → pass
  │          isOwner? → owns this record? ──NO──→ 403
  │          isStaff? → assigned here?    ──NO──→ 403
  │          isMember? → tier/own check   ──NO──→ 403
  │
  ├─ Controller: calls ScopeResolver.resolve(ctx) → Prisma WHERE clause
  │
  ├─ Service: merges scope WHERE + query filters + role-appropriate SELECT
  │
  └─ Response: correct data subset, correct fields, for this exact user
```

### The rule that prevents every future bug

> **Services never receive `RequestContext`.** They receive a `Prisma.XWhereInput` that has already been resolved. The only exception is `ctx` being passed for `SELECT` shaping (which fields to return) — never for filtering (which rows to return).

Adding a new role means updating one `ScopeResolver` and one `ResourceAccessGuard` check. Zero changes to services.



Two changes to the architecture:
1. GymScopeResolver — list endpoint becomes public, no role filter needed
typescriptasync resolve(ctx: RequestContext): Promise<Prisma.GymWhereInput> {
  // Anyone can see gyms — only show approved ones to public
  if (!ctx || ctx.isAdmin) return {};
  if (ctx.isOwner) return { ownerId: ctx.userId }; // owner dashboard still scoped
  return { isApproved: true }; // public + staff + member see approved only
}
2. GymController — split read vs write permissions
typescript// ── READ (public — no auth required) ─────────────
@Get()
@Public()
async findAll(@Query() query: GymListQueryDto, @ReqContext() ctx?: RequestContext) {
  const where = await this.gymScopeResolver.resolve(ctx);
  return this.gymService.findAll({ where, query, ctx });
}

@Get(':id')
@Public()
async findOne(@Param('id') id: string, @ReqContext() ctx?: RequestContext) {
  return this.gymService.findOne(id, ctx);
}

// ── WRITE (owner only) ────────────────────────────
@Post()
@Roles(RoleName.GYM_OWNER)
async create(@Body() dto: CreateGymDto, @ReqContext() ctx: RequestContext) {
  return this.gymService.create(dto, ctx.userId);
}

@Patch(':id')
@UseGuards(ResourceAccessGuard)
@CheckResource('gym')
@Roles(RoleName.GYM_OWNER)
async update(@Param('id') id: string, @Body() dto: UpdateGymDto, @ReqContext() ctx: RequestContext) {
  return this.gymService.update(id, dto);
}

// Admin-only writes stay the same
@Patch(':id/approve')
@Roles(RoleName.SUPER_ADMIN, RoleName.ADMIN_STAFF)
async approve(@Param('id') id: string, @Body('tier') tier: number) {
  return this.gymService.approve(id, tier);
}
3. ResourceAccessGuard.checkGymAccess — skip ownership check on reads
The guard already only runs when @CheckResource('gym') is present, and you only put that decorator on write endpoints now. No other changes needed.
Summary of the rule: @Public() on all GET gym endpoints. @Roles(GYM_OWNER) + @CheckResource('gym') on all mutating endpoints. ctx becomes optional on public endpoints — JwtAuthGuard should be updated to attach context if a token is present but not require one on @Public() routes, so logged-in owners still get their scoped view on their dashboard.