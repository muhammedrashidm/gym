import { redirect, Outlet } from "react-router";
import { loadProtectedUser } from "~/features/auth/application/auth_handler";
import type { Route } from "./+types/_onboarding";

export async function loader({ request }: Route.LoaderArgs) {
  const user = await loadProtectedUser(request);
  const url = new URL(request.url);
  
  // If user already has a role, they shouldn't be in onboarding, EXCEPT to finish their profile setup.
  if (user.roles.length > 0 && !url.pathname.endsWith("/profile")) {
    throw redirect("/");
  }

  return null;
}

export default function OnboardingLayout() {
  return <Outlet />;
}
