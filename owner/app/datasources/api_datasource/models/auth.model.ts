export interface UserRoleClaimDTO {
  roleId: number;
  roleName: string;
  gymId: string | null;
}

export interface VerifyOtpResponseDTO {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    phoneNumber: string;
    isActive: boolean;
    roles: UserRoleClaimDTO[];
  };
  claimedProfile: unknown | null;
}

export interface RefreshTokenResponseDTO {
  accessToken: string;
  refreshToken: string;
}

export interface RequestOtpResponseDTO {
  success: boolean;
}
