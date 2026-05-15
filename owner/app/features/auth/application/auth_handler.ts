import { data, redirect } from "react-router";
import { container } from "~/core/di/container";
import { Tokens } from "~/core/di/tokens";
import type { IAuthRepository } from "../domain/repositories/i_auth_repository";
import {
  getSession,
  sessionStorage,
  requireAuth,
  destroySession,
} from "~/core/auth/session.server";
import { InvalidOtpError } from "../domain/errors";

function getRepo(): IAuthRepository {
  return container.resolve<IAuthRepository>(Tokens.IAuthRepository);
}

export async function handleRequestOtp(request: Request) {
  const form = await request.formData();
  const phoneNumber = form.get("phoneNumber") as string;

  try {
    await getRepo().requestOtp(phoneNumber);
    return data({ success: true, phoneNumber });
  } catch (error) {
    console.error("Request OTP error:", error);
    return data(
      { error: "Failed to send OTP. Check the number and try again." },
      { status: 400 }
    );
  }
}

export async function handleVerifyOtp(request: Request) {
  const form = await request.formData();
  const phoneNumber = form.get("phoneNumber") as string;
  const code = form.get("code") as string;

  try {
    const result = await getRepo().verifyOtp(phoneNumber, code);
    const session = await getSession(request);

    session.set("accessToken", result.accessToken);
    session.set("refreshToken", result.refreshToken);
    session.set("userId", result.user.id);
    session.set("phoneNumber", result.user.phoneNumber);
    // Serialize RoleClaim array directly to session (needs plain objects)
    session.set(
      "roles",
      result.user.roles.map((r) => ({
        roleId: r.roleId,
        roleName: r.roleName,
        gymId: r.gymId,
      }))
    );

    return redirect("/", {
      headers: { "Set-Cookie": await sessionStorage.commitSession(session) },
    });
  } catch (e) {
    if (e instanceof InvalidOtpError) {
      return data({ error: "Invalid OTP. Please try again." }, { status: 401 });
    }
    return data({ error: "Something went wrong." }, { status: 500 });
  }
}

export async function handleLogout(request: Request) {
  const session = await requireAuth(request);
  try {
    await getRepo().logout(session.accessToken, session.refreshToken);
  } catch {
    // still destroy session locally even if server fails
  }

  return redirect("/login", {
    headers: { "Set-Cookie": await destroySession(request) },
  });
}

export async function loadProtectedUser(request: Request) {
  return requireAuth(request);
}
