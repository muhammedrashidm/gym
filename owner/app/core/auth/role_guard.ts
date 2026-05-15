import { RoleType } from "~/features/auth/domain/enums/role_type";
import type { RoleClaim } from "~/features/auth/domain/entities/role_claim";

export const MENU_ITEMS = [
  { label: "Global Overview", path: "/", allowedRoles: [RoleType.Admin, RoleType.Owner] },
  {
    label: "Venue Management",
    path: "/venues",
    allowedRoles: [RoleType.Admin, RoleType.Owner],
  },
  {
    label: "Member Analytics",
    path: "/members",
    allowedRoles: [RoleType.Admin, RoleType.Owner],
  },
  {
    label: "Staff Schedule",
    path: "/schedule",
    allowedRoles: [RoleType.Admin, RoleType.Owner],
  },
  { label: "Financials", path: "/financials", allowedRoles: [RoleType.Admin] },
];

export function getPermittedMenu(
  roles: { roleId: number; roleName: string; gymId: string | null }[]
) {
  const userRoleIds = roles.map((r) => r.roleId);
  return MENU_ITEMS.filter((item) =>
    item.allowedRoles.some((role) => userRoleIds.includes(role))
  );
}

export function canAccessPath(
  path: string,
  roles: { roleId: number; roleName: string; gymId: string | null }[]
) {
  const userRoleIds = roles.map((r) => r.roleId);

  // Find a menu item that matches the current path.
  // We sort by path length descending to find the most specific match first.
  const matchingItems = [...MENU_ITEMS]
    .filter((item) => {
      if (item.path === "/") return path === "/";
      return path.startsWith(item.path);
    })
    .sort((a, b) => b.path.length - a.path.length);

  const menuItem = matchingItems[0];

  // If no matching menu item is found, we allow it by default
  // (e.g., /profile, /logout, /onboarding are handled by other logic or are public)
  if (!menuItem) return true;

  return menuItem.allowedRoles.some((role) => userRoleIds.includes(role));
}
