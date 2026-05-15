import { Form, Link, Outlet, useLoaderData, redirect } from "react-router";
import { getPermittedMenu, canAccessPath } from "~/core/auth/role_guard";
import { loadProtectedUser } from "~/features/auth/application/auth_handler";
import type { Route } from "./+types/_app";
import { ThemeSwitcher } from "~/shared/ui/theme/theme_switcher";
import { LayoutDashboard, MapPin, Users, Calendar, DollarSign, LogOut } from "lucide-react";

export async function loader({ request }: Route.LoaderArgs) {
  const user = await loadProtectedUser(request);
  
  if (user.roles.length === 0) {
    throw redirect("/onboarding");
  }

  const url = new URL(request.url);
  if (!canAccessPath(url.pathname, user.roles)) {
    const permittedMenu = getPermittedMenu(user.roles);
    const safePath = permittedMenu.length > 0 ? permittedMenu[0].path : "/onboarding";
    throw redirect(safePath);
  }

  const permittedMenu = getPermittedMenu(user.roles);
  
  // Highest role name for display
  const highestRoleName = user.roles.reduce((prev, current) => {
    return (current.roleId > prev.roleId) ? current : prev;
  }, user.roles[0])?.roleName || "User";

  return { user, permittedMenu, highestRoleName };
}

export default function AppLayout({ loaderData }: Route.ComponentProps) {
  const { permittedMenu, highestRoleName } = loaderData;

  const getIcon = (label: string) => {
    switch (label) {
      case "Global Overview": return <LayoutDashboard className="w-5 h-5" />;
      case "Venue Management": return <MapPin className="w-5 h-5" />;
      case "Member Analytics": return <Users className="w-5 h-5" />;
      case "Staff Schedule": return <Calendar className="w-5 h-5" />;
      case "Financials": return <DollarSign className="w-5 h-5" />;
      default: return null;
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col md:flex-row">
      {/* Sidebar */}
      <aside className="w-full md:w-[280px] bg-sidebar border-r-0 md:border-r border-sidebar-border flex flex-col">
        <div className="p-8 pb-12 flex justify-between items-center">
          <h1 className="font-heading font-black text-2xl tracking-tighter uppercase text-sidebar-primary">
            MONOLITHIC
          </h1>
          <ThemeSwitcher />
        </div>

        <nav className="flex-1 px-4 flex flex-col gap-2">
          <div className="px-4 pb-4 mb-4 border-b border-sidebar-border">
            <p className="text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground mb-1">
              Group Control
            </p>
          </div>
          
          {permittedMenu.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className="flex items-center gap-4 px-4 py-3 text-sm font-semibold text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground rounded-none transition-colors"
            >
              {getIcon(item.label)}
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="p-8 border-t border-sidebar-border flex justify-between items-center">
          <div className="flex flex-col">
            <span className="text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground">
              Profile
            </span>
            <span className="text-sm font-semibold uppercase">
              {highestRoleName}
            </span>
          </div>
          <Form action="/logout" method="post">
            <button type="submit" className="text-muted-foreground hover:text-destructive transition-colors">
              <LogOut className="w-5 h-5" />
            </button>
          </Form>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <Outlet />
      </main>
    </div>
  );
}
