import { Link } from "react-router";

export function NoRolePage() {
  return (
    <div className="font-sans text-foreground antialiased bg-background min-h-screen">
      <div className="fixed inset-0 bg-[url('https://lh3.googleusercontent.com/aida-public/AB6AXuCnBZy_1X7C9Q2Cr9DSARKkB8m-FE38TjkMURNiWERgPLfPjvha2NZlyB02sJAnKWzPiZOIrsp6LQ3eFSSJaf5CKpuvPrhGu7_rE4RCfY8g208Qck3SV7gnTGafH4JnQzvgdolv366VjboMkI3R2CvnK-2dh_vLtIaLg_8Eg0i0GZK8UyIn5tx8gLXw1EFiDDD9CKa-_rpKB7r2cSM1el5FJqhXri5iZgAORhM-8UL4G_UwiEhhloP4qnVeYemYDrArTI5RWuL2CCHC')] opacity-[0.03] pointer-events-none z-[1]"></div>

      {/* Architectural Decorative Elements */}
      <div className="fixed bg-primary opacity-10 w-px h-screen left-[10%] top-0 z-0"></div>
      <div className="fixed bg-primary opacity-10 w-px h-screen right-[10%] top-0 z-0"></div>
      <div className="fixed bg-primary opacity-10 h-px w-screen top-24 left-0 z-0"></div>
      <div className="fixed bg-primary opacity-10 h-px w-screen bottom-24 left-0 z-0"></div>

      {/* Top Navigation */}
      <header className="fixed top-0 w-full z-50 bg-background/80 backdrop-blur-md border-b border-border/20 px-10 h-20 flex items-center justify-between">
        <div className="flex items-center gap-8">
          <div className="flex items-center gap-3 cursor-pointer group">
            <span className="material-symbols-outlined text-primary group-hover:-translate-x-1 transition-transform">arrow_back</span>
            <span className="font-sans text-[10px] font-bold uppercase tracking-[0.2em]">Back to Terminal</span>
          </div>
          <div className="h-6 w-px bg-border/30"></div>
          <h1 className="font-heading font-bold tracking-tight text-primary">Onboarding Flow // Identity Setup</h1>
        </div>
        <div className="text-2xl font-black text-primary uppercase tracking-tighter">
          MONOLITHIC
        </div>
      </header>

      <main className="relative z-10 flex flex-col items-center justify-center min-h-screen pt-32 pb-24 px-10">
        <div className="max-w-[1440px] mx-auto w-full grid grid-cols-12 gap-10 items-start">
          {/* Left Side: Identity & Messaging */}
          <div className="col-span-12 lg:col-span-7 flex flex-col">
            <div className="mb-16 relative">
              <div className="inline-flex items-center gap-4 mb-3">
                <div className="w-2 h-2 bg-primary"></div>
                <p className="font-sans text-[10px] font-bold text-primary tracking-[0.4em] uppercase">STATUS: PENDING_AUTHORIZATION</p>
              </div>
              <h2 className="font-heading text-[84px] leading-[0.95] uppercase italic tracking-tighter mb-10 text-primary">
                Welcome to<br />the Temple.
              </h2>
              <div className="w-48 h-2 bg-primary mb-16"></div>
              <div className="max-w-xl">
                <p className="font-sans text-xl text-muted-foreground leading-relaxed mb-10">
                  Your profile has been created successfully. To access our elite performance management suite, a role must be assigned to your identity.
                </p>
                <p className="font-sans text-lg text-muted-foreground/70 leading-relaxed italic border-l-4 border-border/30 pl-6">
                  "The strength of the collective begins with the precision of the individual."
                </p>
              </div>
            </div>

            {/* Secondary Visual for Desktop */}
            <div className="mt-12 w-full h-[300px] overflow-hidden grayscale contrast-150 border border-border/40 group">
              <img alt="Brutalist gym interior" className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s] ease-out" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBitcopGsaJfnIARMjZG3RngRy2eYqvTu_abnNwUN69TDqSWv1gTtlQGRlfRu_9Qkv0Duv07RJNKXtzGE8Z-n8DUvcr0WzkKZtNxbURI1C9aA56y-ic146rRtuZLtob90Mw1Kk8oXsk1XBqHG4qS7kuFsWA9m2kHH3GfnrSdhW5OA7Y95dXogyfd0I0734fYJDo9klEF0Kk0-J5IwE3euxfMePqF-uBnOgdPyzs_kWf3UsOeGNsWbg4QlablIrnzDESH9XcQUty0dr5" />
            </div>
          </div>

          {/* Right Side: Action Card */}
          <div className="col-span-12 lg:col-span-5 sticky top-32">
            <div className="bg-surface-low p-12 w-full relative border-2 border-primary shadow-[20px_20px_0px_rgba(19,19,19,0.05)]">
              {/* Diagonal Corner Accents */}
              <div className="absolute -top-3 -left-3 w-6 h-6 border-t-2 border-l-2 border-primary"></div>
              <div className="absolute -bottom-3 -right-3 w-6 h-6 border-b-2 border-r-2 border-primary"></div>

              <div className="mb-10">
                <p className="font-sans text-[10px] font-bold text-muted-foreground uppercase tracking-[0.2em] mb-2">Required Action</p>
                <h3 className="font-heading text-2xl uppercase italic font-black text-primary">Initiate Protocol</h3>
              </div>

              <div className="flex flex-col gap-6 w-full">
                <Link to="/onboarding/terms" className="w-full py-8 bg-primary text-primary-foreground font-sans text-[16px] font-black uppercase tracking-[0.3em] hover:bg-primary/90 transition-all active:scale-[0.98] flex items-center justify-center gap-4 group">
                  Onboard as Gym Owner
                  <span className="material-symbols-outlined group-hover:translate-x-2 transition-transform">arrow_forward</span>
                </Link>
                <div className="grid grid-cols-2 gap-4">
                  <button className="flex items-center justify-center gap-2 py-5 border border-border/30 text-muted-foreground hover:bg-surface-highest transition-colors group">
                    <span className="font-sans text-xs uppercase tracking-widest font-bold">Contact Support</span>
                    <span className="material-symbols-outlined text-[16px]">north_east</span>
                  </button>
                  <button className="flex items-center justify-center gap-2 py-5 border border-border/30 text-muted-foreground hover:bg-surface-highest transition-colors group">
                    <span className="font-sans text-xs uppercase tracking-widest font-bold">Manual Auth</span>
                    <span className="material-symbols-outlined text-[16px]">lock_open</span>
                  </button>
                </div>
              </div>

              <div className="mt-12 pt-8 border-t border-border/20">
                <p className="text-xs text-muted-foreground/60 leading-relaxed">
                  System Authorization Required // Terminal 01<br />
                  Encryption: Active // AES-256-GCM<br />
                  Timestamp: 2024.Q3.08.12.00.00
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Visual Footer Accent */}
      <div className="fixed bottom-0 left-[10%] w-[1px] h-48 bg-gradient-to-t from-primary to-transparent opacity-10 z-0"></div>
      <div className="fixed bottom-0 right-[10%] w-[1px] h-48 bg-gradient-to-t from-primary to-transparent opacity-10 z-0"></div>

      <footer className="fixed bottom-0 w-full px-10 py-4 flex justify-between items-center z-50">
        <p className="font-sans text-[9px] font-bold text-muted-foreground uppercase tracking-[0.4em]">© MONOLITHIC PERFORMANCE SYSTEMS 2024</p>
        <div className="flex gap-6">
          <span className="font-sans text-[9px] font-bold text-muted-foreground uppercase tracking-[0.2em]">Privacy</span>
          <span className="font-sans text-[9px] font-bold text-muted-foreground uppercase tracking-[0.2em]">Terms</span>
        </div>
      </footer>
    </div>
  );
}
