export interface IOnboardingRepository {
  claimOwnerRole(accessToken: string): Promise<void>;
  updateProfile(accessToken: string, data: { fullName: string; age?: number; avatarUrl?: string }): Promise<void>;
  uploadAvatar(accessToken: string, file: File): Promise<string>;
}
