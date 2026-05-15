import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { SYSTEM_ROLES } from '../constants/roles';
import type { AuthUser, UserRoleClaim } from '../interfaces/auth-user.interface';
import type { RequestContext } from '../../common/types/request-context.type';

interface JwtPayload {
  sub: string;
  phone: string;
  roles?: UserRoleClaim[];
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) {
      if (isPublic) return true;
      throw new UnauthorizedException('No access token provided');
    }

    let payload: JwtPayload;
    try {
      payload = this.jwtService.verify<JwtPayload>(token);
    } catch {
      if (isPublic) return true;
      throw new UnauthorizedException('Invalid or expired access token');
    }

    const authUser = await this.buildAuthUser(payload);
    request.user = authUser;
    request.context = await this.buildContext(authUser, request);

    return true;
  }

  private extractToken(request: any): string | undefined {
    const auth = request.headers?.authorization;
    if (Array.isArray(auth)) return this.parseBearer(auth[0]);
    return this.parseBearer(auth);
  }

  private parseBearer(auth?: string): string | undefined {
    if (!auth?.startsWith('Bearer ')) return undefined;
    return auth.slice(7);
  }

  private async buildAuthUser(payload: JwtPayload): Promise<AuthUser> {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, phoneNumber: true, isActive: true },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }

    return {
      id: user.id,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      roles: payload.roles ?? [],
    };
  }

  private async buildContext(
    user: AuthUser,
    request: any,
  ): Promise<RequestContext> {
    const roleNames = user.roles.map((role) => role.roleName);
    const profile = await this.prisma.profile.findUnique({
      where: { userId: user.id },
      select: { id: true },
    });

    const gymId = this.getHeader(request, 'x-gym-id') ??
      this.getHeader(request, 'x-gym-context') ??
      user.roles.find((role) => role.gymId)?.gymId;

    let gymContext: RequestContext['gymContext'];
    if (gymId) {
      const gym = await this.prisma.gym.findUnique({
        where: { id: gymId },
        select: { id: true, tier: true, ownerId: true },
      });

      if (gym) {
        gymContext = {
          gymId: gym.id,
          gymTier: gym.tier,
          isOwner: gym.ownerId === user.id,
          isStaff: user.roles.some(
            (role) =>
              role.gymId === gym.id &&
              [SYSTEM_ROLES.STAFF, SYSTEM_ROLES.MANAGER, SYSTEM_ROLES.TRAINER]
                .includes(role.roleName as any),
          ),
        };
      }
    }

    const isSuperAdmin = roleNames.includes(SYSTEM_ROLES.ADMIN);
    const isAdminStaff = roleNames.includes(SYSTEM_ROLES.ADMIN_STAFF);

    return {
      userId: user.id,
      phoneNumber: user.phoneNumber,
      roles: roleNames,
      roleAssignments: user.roles,
      profileId: profile?.id,
      gymContext,
      isSuperAdmin,
      isAdminStaff,
      isAdmin: isSuperAdmin || isAdminStaff,
      isOwner: roleNames.includes(SYSTEM_ROLES.OWNER),
      isStaff: roleNames.some((role) =>
        [SYSTEM_ROLES.STAFF, SYSTEM_ROLES.MANAGER, SYSTEM_ROLES.TRAINER]
          .includes(role as any),
      ),
      isMember: roleNames.some((role) =>
        [SYSTEM_ROLES.MEMBER, SYSTEM_ROLES.SUBSCRIBER].includes(role as any),
      ),
    };
  }

  private getHeader(request: any, name: string): string | undefined {
    const value = request.headers?.[name];
    if (Array.isArray(value)) return value[0];
    return value;
  }
}
