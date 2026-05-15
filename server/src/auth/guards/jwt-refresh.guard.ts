import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

// Used ONLY on POST /auth/refresh.
// Delegates to JwtRefreshStrategy which extracts the raw Bearer UUID.
// AuthService.refresh() performs the actual DB validation (isRevoked, expiry).
@Injectable()
export class JwtRefreshGuard extends AuthGuard('jwt-refresh') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw (
        err ?? new UnauthorizedException('Invalid or missing refresh token')
      );
    }
    // user = { refreshToken: string } as returned by JwtRefreshStrategy.validate()
    return user;
  }
}
