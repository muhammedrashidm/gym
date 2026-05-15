import { OtpRequestedModel } from '../models/otp-requested.model';
import { VerifyOtpResponseModel } from '../models/verify-otp-response.model';
import { TokenPairModel } from '../models/token-pair.model';
import { LogoutModel } from '../models/logout.model';
import { AuthUserModel } from '../models/auth-user.model';

export interface IAuthService {
  requestOtp(phoneNumber: string): Promise<OtpRequestedModel>;
  verifyOtp(phoneNumber: string, code: string): Promise<VerifyOtpResponseModel>;
  refresh(rawRefreshToken: string): Promise<TokenPairModel>;
  logout(userId: string, rawRefreshToken: string): Promise<LogoutModel>;
  getMe(userId: string): Promise<AuthUserModel>;
  claimOwner(userId: string): Promise<{ success: boolean }>;
}
