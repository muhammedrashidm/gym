import { createCookieSessionStorage, redirect } from "react-router";

export type SessionData = {
  accessToken: string;
  refreshToken: string;
  userId: string;
  phoneNumber: string;
  roles: { roleId: number; roleName: string; gymId: string | null }[];
};

export const sessionStorage = createCookieSessionStorage<SessionData>({
  cookie: {
    name: "__gymos_session",
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    secrets: [process.env.SESSION_SECRET || "default-secret"],
    maxAge: 60 * 60 * 24 * 30, // 30 days
  },
});

export async function getSession(request: Request) {
  return sessionStorage.getSession(request.headers.get("Cookie"));
}

export async function requireAuth(request: Request): Promise<SessionData> {
  const session = await getSession(request);
  const accessToken = session.get("accessToken");
  if (!accessToken) throw redirect("/login");
  return {
    accessToken,
    refreshToken: session.get("refreshToken")!,
    userId: session.get("userId")!,
    phoneNumber: session.get("phoneNumber")!,
    roles: session.get("roles") ?? [],
  };
}

export async function destroySession(request: Request) {
  const session = await getSession(request);
  return sessionStorage.destroySession(session);
}
