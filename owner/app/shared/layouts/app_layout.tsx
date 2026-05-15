import { Form } from 'react-router';
import { ThemeSwitcher } from '~/shared/ui/theme/theme_switcher';
import { LogOut } from 'lucide-react';
import type { SessionData } from '~/core/auth/session.server';

interface AppLayoutProps {
  children: React.ReactNode;
  user: SessionData;
}

export function AppLayout({ children, user }: AppLayoutProps) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-surface border-b border-surface-high">
        <div className="flex items-center justify-between px-6 py-4">
          <div className="font-[Manrope] font-bold text-xl tracking-tight">
            GymOS
          </div>
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">
              {user.phoneNumber}
            </span>
            <ThemeSwitcher />
            <Form action="/logout" method="post">
              <button
                type="submit"
                className="flex items-center gap-2 px-3 py-2 text-sm text-muted-foreground hover:text-foreground transition-colors"
              >
                <LogOut className="w-4 h-4" />
                Sign out
              </button>
            </Form>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="pt-20 px-6 py-8">
        {children}
      </main>
    </div>
  );
}
