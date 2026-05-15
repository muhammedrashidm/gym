import { TermsPage } from "~/features/onboarding/presentation/pages/terms_page";
import { handleClaimRole } from "~/features/onboarding/application/onboarding_handler";
import type { Route } from "./+types/_onboarding.terms";

export async function action({ request }: Route.ActionArgs) {
  const cloned = request.clone();
  const form = await cloned.formData();
  if (form.get("_action") === "claim_role") {
    return handleClaimRole(request);
  }
  return { error: "Invalid action" };
}

export default function OnboardingTermsRoute() {
  return <TermsPage />;
}
