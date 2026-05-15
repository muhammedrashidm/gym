import { injectable } from "tsyringe";
import { apiClient } from "~/datasources/api_datasource/api_client";
import type { IOnboardingRepository } from "../../domain/repositories/i_onboarding_repository";
import { env } from "~/core/config/env";

@injectable()
export class OnboardingRepository implements IOnboardingRepository {
  async claimOwnerRole(accessToken: string): Promise<void> {
    await apiClient.post("/auth/claim-owner", undefined, accessToken);
  }

  async updateProfile(
    accessToken: string,
    data: { fullName: string; age?: number; avatarUrl?: string }
  ): Promise<void> {
    await apiClient.post("/users/profile", data, accessToken);
  }

  async uploadAvatar(accessToken: string, file: File): Promise<string> {
    const formData = new FormData();
    formData.append("file", file);

    const res = await fetch(`${env.apiUrl}/media/upload`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
      body: formData,
    });
    
    if (!res.ok) throw new Error("Failed to upload avatar");
    const data = await res.json();
    return data.url; // assuming { url: "..." } based on nestjs code
  }
}
