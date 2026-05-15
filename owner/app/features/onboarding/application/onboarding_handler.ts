import { data, redirect } from "react-router";
import { container } from "~/core/di/container";
import { Tokens } from "~/core/di/tokens";
import type { IOnboardingRepository } from "../domain/repositories/i_onboarding_repository";
import type { IAuthRepository } from "~/features/auth/domain/repositories/i_auth_repository";
import { requireAuth, getSession, sessionStorage } from "~/core/auth/session.server";

function getOnboardingRepo(): IOnboardingRepository {
  return container.resolve<IOnboardingRepository>(Tokens.IOnboardingRepository);
}
function getAuthRepo(): IAuthRepository {
  return container.resolve<IAuthRepository>(Tokens.IAuthRepository);
}

export async function handleClaimRole(request: Request) {
  const sessionData = await requireAuth(request);
  
  try {
    await getOnboardingRepo().claimOwnerRole(sessionData.accessToken);
    // Refresh the user data to get the new role
    const updatedUser = await getAuthRepo().getMe(sessionData.accessToken);
    
    // Update the session
    const session = await getSession(request);
    session.set("roles", updatedUser.roles.map((r) => ({
      roleId: r.roleId,
      roleName: r.roleName,
      gymId: r.gymId,
    })));
    
    return redirect("/onboarding/profile", {
      headers: { "Set-Cookie": await sessionStorage.commitSession(session) },
    });
  } catch (e) {
    return data({ error: "Failed to claim role. Please try again." }, { status: 500 });
  }
}

export async function handleProfileSetup(request: Request) {
  const sessionData = await requireAuth(request);
  const formData = await request.formData();
  
  const fullName = formData.get("fullName") as string;
  const ageStr = formData.get("age") as string;
  const age = ageStr ? parseInt(ageStr, 10) : undefined;
  const avatarFile = formData.get("avatar") as File | null;
  
  try {
    let avatarUrl;
    if (avatarFile && avatarFile.size > 0) {
      avatarUrl = await getOnboardingRepo().uploadAvatar(sessionData.accessToken, avatarFile);
    }
    
    await getOnboardingRepo().updateProfile(sessionData.accessToken, {
      fullName,
      age,
      avatarUrl
    });
    
    return redirect("/");
  } catch (e) {
    return data({ error: "Failed to update profile. Please try again." }, { status: 500 });
  }
}
