import { injectable } from "tsyringe";
import { apiClient, ApiError } from "~/datasources/api_datasource/api_client";
import type { IAuthRepository } from "../../domain/repositories/i_auth_repository";
import { AuthUser } from "../../domain/entities/auth_user";
import { AuthMapper } from "../../domain/mappers/auth_mapper";
import { InvalidOtpError, UnauthorizedError } from "../../domain/errors";
import type {
  VerifyOtpResponseDTO,
  RefreshTokenResponseDTO,
} from "~/datasources/api_datasource/models/auth.model";

@injectable()
export class AuthRepository implements IAuthRepository {
  async requestOtp(phoneNumber: string): Promise<void> {
    try {
    await apiClient.post("/auth/request-otp", { phoneNumber });
    } catch (error) {
      console.error("Request OTP error:", error);
      throw error;
    }
  }

  async verifyOtp(phoneNumber: string, code: string) {
    try {
      const data = await apiClient.post<VerifyOtpResponseDTO>(
        "/auth/verify-otp",
        { phoneNumber, code }
      );
      return {
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        user: AuthMapper.mapAuthUserDTOToEntity(data.user),
      };
    } catch (e) {
      if (e instanceof ApiError && e.status === 401)
        throw new InvalidOtpError();
      throw e;
    }
  }

  async refresh(refreshToken: string) {
    const data = await apiClient.post<RefreshTokenResponseDTO>(
      "/auth/refresh",
      undefined,
      refreshToken
    );
    return { accessToken: data.accessToken, refreshToken: data.refreshToken };
  }

  async logout(accessToken: string, refreshToken: string): Promise<void> {
    await apiClient.post("/auth/logout", { refreshToken }, accessToken);
  }

  async getMe(accessToken: string): Promise<AuthUser> {
    const data = await apiClient.get<VerifyOtpResponseDTO["user"]>(
      "/auth/me",
      accessToken
    );
    return AuthMapper.mapAuthUserDTOToEntity(data);
  }
}
