import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy, StrategyOptionsWithRequest } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(
  Strategy,
  'jwt-refresh',
) {
  constructor(config: ConfigService) {
    const options: StrategyOptionsWithRequest = {
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: true,
      secretOrKey: config.get<string>('JWT_SECRET') as string,
      passReqToCallback: true,
    };
    super(options);
  }

  async validate(
    req: Request,
    _payload: any,
  ): Promise<{ refreshToken: string }> {
    const authHeader = req.headers.authorization ?? '';
    const rawToken = authHeader.replace('Bearer ', '').trim();

    if (!rawToken) {
      throw new UnauthorizedException('Refresh token missing');
    }

    return { refreshToken: rawToken };
  }
}
