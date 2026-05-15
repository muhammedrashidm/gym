import type { ReactNode } from "react";

export function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center p-4">
      <div className="absolute top-8 left-8">
        <h1 className="font-heading font-black text-2xl tracking-tighter uppercase text-primary">
          MONOLITHIC
        </h1>
      </div>
      <div className="w-full max-w-[448px]">
        {children}
      </div>
      <div className="absolute bottom-8 flex gap-6 text-xs font-bold tracking-widest uppercase text-muted-foreground">
        <a href="#" className="hover:text-primary transition-colors">Help</a>
        <a href="#" className="hover:text-primary transition-colors">Privacy</a>
        <a href="#" className="hover:text-primary transition-colors">Terms</a>
      </div>
    </div>
  );
}
