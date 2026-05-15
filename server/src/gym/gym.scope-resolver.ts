import { Injectable } from '@nestjs/common';
import type { Prisma } from 'generated/prisma/client';
import type { RequestContext } from '../common/types/request-context.type';

@Injectable()
export class GymScopeResolver {
  async resolve(ctx?: RequestContext): Promise<Prisma.GymWhereInput> {
    if (!ctx) return { isApproved: true };
    if (ctx.isAdmin) return {};
    if (ctx.isOwner) return { ownerId: ctx.userId };
    return { isApproved: true };
  }
}
