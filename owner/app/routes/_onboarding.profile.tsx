import { ProfileSetupPage } from "~/features/onboarding/presentation/pages/profile_setup_page";
import { handleProfileSetup } from "~/features/onboarding/application/onboarding_handler";
import type { Route } from "./+types/_onboarding.profile";

export async function action({ request }: Route.ActionArgs) {
  const cloned = request.clone();
  const form = await cloned.formData();
  if (form.get("_action") === "setup_profile") {
    return handleProfileSetup(request);
  }
  return { error: "Invalid action" };
}

export default function OnboardingProfileRoute() {
  return <ProfileSetupPage />;
}
