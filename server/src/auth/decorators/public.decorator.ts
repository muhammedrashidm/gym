import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

// Mark a route as public — JwtAuthGuard will skip it entirely.
// Use on: POST /auth/request-otp, POST /auth/verify-otp
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
