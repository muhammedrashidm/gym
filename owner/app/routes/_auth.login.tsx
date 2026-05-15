import { redirect } from "react-router";
import {
  handleRequestOtp,
  handleVerifyOtp,
} from "~/features/auth/application/auth_handler";
import { getSession } from "~/core/auth/session.server";
import { LoginPage } from "~/features/auth/presentation/pages/login_page";
import type { Route } from "./+types/_auth.login";

export async function loader({ request }: Route.LoaderArgs) {
  const session = await getSession(request);
  if (session.has("accessToken")) {
    return redirect("/");
  }
  return null;
}

export async function action({ request }: Route.ActionArgs) {
  const clonedReq = request.clone();
  const form = await clonedReq.formData();
  const step = form.get("_step");

  if (step === "request") {
    return handleRequestOtp(request);
  }
  if (step === "verify") {
    return handleVerifyOtp(request);
  }

  return { error: "Invalid action" };
}

export default function LoginRoute() {
  return <LoginPage />;
}
