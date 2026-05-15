import { RequestOtpDto } from '../dto/request-otp.dto';
import { VerifyOtpDto } from '../dto/verify-otp.dto';
import { OtpRequestedModel } from '../models/otp-requested.model';
import { VerifyOtpResponseModel } from '../models/verify-otp-response.model';
import { TokenPairModel } from '../models/token-pair.model';
import { LogoutModel } from '../models/logout.model';
import { AuthUserModel } from '../models/auth-user.model';
import type { AuthUser } from './auth-user.interface';

export interface IAuthController {
  requestOtp(dto: RequestOtpDto): Promise<OtpRequestedModel>;
  verifyOtp(dto: VerifyOtpDto): Promise<VerifyOtpResponseModel>;
  refresh(user: { refreshToken: string }): Promise<TokenPairModel>;
  logout(user: AuthUser, refreshToken: string): Promise<LogoutModel>;
  getMe(user: AuthUser): Promise<AuthUserModel>;
  claimOwner(user: AuthUser): Promise<{ success: boolean }>;
}
