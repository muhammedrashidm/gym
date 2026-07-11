import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
  CanActivate,
} from '@nestjs/common';

// Used ONLY on POST /auth/refresh.
// Manually extracts the raw Bearer UUID and assigns to request.user.
// AuthService.refresh() performs the actual DB validation (isRevoked, expiry).
@Injectable()
export class JwtRefreshGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Refresh token missing');
    }
    const refreshToken = authHeader.substring(7).trim();
    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token missing');
    }
    request.user = { refreshToken };
    return true;
  }
}
