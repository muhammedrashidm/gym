import { handleLogout } from "~/features/auth/application/auth_handler";
import type { Route } from "./+types/_app.logout";

export async function action({ request }: Route.ActionArgs) {
  return handleLogout(request);
}
