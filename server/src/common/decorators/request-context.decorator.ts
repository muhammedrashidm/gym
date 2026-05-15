import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { RequestContext } from '../types/request-context.type';

export const ReqContext = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestContext | undefined => {
    const request = ctx.switchToHttp().getRequest();
    return request.context as RequestContext | undefined;
  },
);
