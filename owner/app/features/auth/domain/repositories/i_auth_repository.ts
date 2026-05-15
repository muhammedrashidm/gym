import type { AuthUser } from "../entities/auth_user";

export interface IAuthRepository {
  requestOtp(phoneNumber: string): Promise<void>;
  verifyOtp(
    phoneNumber: string,
    code: string
  ): Promise<{
    accessToken: string;
    refreshToken: string;
    user: AuthUser;
  }>;
  refresh(refreshToken: string): Promise<{
    accessToken: string;
    refreshToken: string;
  }>;
  logout(accessToken: string, refreshToken: string): Promise<void>;
  getMe(accessToken: string): Promise<AuthUser>;
}
