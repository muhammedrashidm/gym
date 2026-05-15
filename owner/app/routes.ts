import { type RouteConfig, index, route, layout } from "@react-router/dev/routes";

export default [
  layout("routes/_auth.tsx", [
    route("login", "routes/_auth.login.tsx"),
  ]),
  layout("routes/_onboarding.tsx", [
    route("onboarding", "routes/_onboarding._index.tsx"),
    route("onboarding/terms", "routes/_onboarding.terms.tsx"),
    route("onboarding/profile", "routes/_onboarding.profile.tsx"),
  ]),
  layout("routes/_app.tsx", [
    index("routes/_app._index.tsx"),
    route("logout", "routes/_app.logout.tsx"),
  ]),
] satisfies RouteConfig;
