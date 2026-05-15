import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import type { RequestContext } from '../../common/types/request-context.type';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles || requiredRoles.length === 0) return true;

    const request = context.switchToHttp().getRequest();
    const ctx = request.context as RequestContext | undefined;
    if (!ctx) {
      throw new UnauthorizedException('Authentication required');
    }

    if (ctx.isAdmin) return true;

    const hasRole = requiredRoles.some((role) => ctx.roles.includes(role));
    if (!hasRole) {
      throw new ForbiddenException(
        `Requires one of [${requiredRoles.join(', ')}]`,
      );
    }

    return true;
  }
}
