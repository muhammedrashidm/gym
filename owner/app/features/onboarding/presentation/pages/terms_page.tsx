import { useActionData, useNavigation, Form } from "react-router";
import { LoaderButton } from "~/shared/components/loader_button";

export function TermsPage() {
  const actionData = useActionData<{ error?: string }>();
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";

  return (
    <div className="bg-background text-foreground min-h-screen font-sans selection:bg-primary selection:text-white">
      {/* Texture Overlay for "Grit" */}
      <div className="fixed inset-0 bg-[url('https://lh3.googleusercontent.com/aida-public/AB6AXuDawd6bnQOUnkgk-RRnJHY_VGtFjwAFJhBr14qgedUDWqbcwuk78cYw1piuzo0FLeZOIbFDYYJKoL2e-_yNwPiZwXCIX6AqvlcBTZpM1j5_S86MXjZKCm6CKkgK-SP7u8RMbSby2dufGaF5_HSyyXULMoNYwa5B9FUem2qUZmHxEPFVgpyOHJurd2y0kEcWRyVhy0UzOd5DXEv8eX5Kx6ynpPpwVh61HABmFAbFf3JzD2EKmaHpAm_Y9jipyNCT-cYI8wR1MS8HTgcn')] bg-cover opacity-[0.03] pointer-events-none z-0"></div>

      {/* Main Shell */}
      <div className="relative z-10 flex flex-col items-center min-h-screen w-full">
        {/* Desktop Header */}
        <header className="w-full border-b border-border/30 bg-background/80 backdrop-blur-md px-6 lg:px-10 h-20 flex items-center justify-between sticky top-0 z-50">
          <div className="flex items-center gap-8">
            <button className="flex items-center justify-center w-10 h-10 hover:bg-surface-low transition-colors rounded-full active:scale-95 duration-150">
              <span className="material-symbols-outlined text-primary">arrow_back</span>
            </button>
            <div className="hidden md:block">
              <span className="font-heading text-xl font-black tracking-tighter uppercase">Monolithic</span>
            </div>
          </div>
          <h1 className="font-heading text-[10px] font-bold uppercase text-primary tracking-[0.3em] absolute left-1/2 -translate-x-1/2">Onboarding</h1>
          <div className="w-10"></div>
        </header>

        {/* Main Content */}
        <main className="w-full max-w-5xl px-6 lg:px-10 py-16 lg:py-24 flex flex-col md:flex-row gap-12 items-start mt-4 mb-10">
          {/* Left Column: Title & Info */}
          <aside className="w-full md:w-1/3 flex flex-col sticky top-32">
            <section className="mb-10 flex flex-col">
              <div className="flex items-center gap-3 mb-4">
                <span className="w-8 h-[2px] bg-primary"></span>
                <p className="font-sans text-[10px] font-bold tracking-[0.2em] text-muted-foreground">STEP 01 // COMPLIANCE</p>
              </div>
              <h2 className="font-heading text-[56px] font-black text-primary uppercase italic leading-[0.9] mb-8">
                Legal<br />Foundation
              </h2>
              <p className="text-muted-foreground max-w-xs">
                Review the Monolithic Operating Agreement. Your commitment to these standards ensures the integrity of our high-performance sanctuary.
              </p>
            </section>
          </aside>

          {/* Right Column: Document Viewer & Actions */}
          <div className="w-full md:w-2/3 flex flex-col">
            {/* Legal Document Card */}
            <section className="bg-background border border-border shadow-sm flex flex-col overflow-hidden mb-10">
              <div className="px-8 py-6 border-b border-border flex justify-between items-center bg-surface-low">
                <p className="font-sans text-[10px] font-bold tracking-[0.2em] text-primary">MONOLITHIC OPERATING AGREEMENT v2.4</p>
                <span className="material-symbols-outlined text-muted-foreground">gavel</span>
              </div>
              <div className="overflow-y-auto max-h-[600px] p-8 space-y-10 font-sans text-muted-foreground leading-relaxed custom-scrollbar">
                <div>
                  <h3 className="text-primary font-bold text-lg uppercase mb-3">1. DEFINITIONS</h3>
                  <p>The term "Sanctuary of Performance" refers to any physical location or digital entity managed under the MONOLITHIC brand umbrella. "Operator" refers to the individual or entity seeking certification and ownership status within our exclusive ecosystem.</p>
                </div>
                <div>
                  <h3 className="text-primary font-bold text-lg uppercase mb-3">2. ARCHITECTURAL STANDARDS</h3>
                  <p>All facilities must adhere to the Monolithic Design Protocol. This includes, but is not limited to, the use of monochromatic color palettes, high-contrast lighting arrays, and Brutalist structural elements. Deviation from these visual standards results in immediate revocation of the operating license.</p>
                </div>
                <div>
                  <h3 className="text-primary font-bold text-lg uppercase mb-3">3. PERFORMANCE METRICS</h3>
                  <p>Operators agree to maintain a minimum athlete performance growth rate of 12% annually across the aggregate member base. Failure to meet these KPIs indicates a failure of discipline and focus, contradicting the core Monolithic ethos of relentless athletic pursuit.</p>
                </div>
                <div>
                  <h3 className="text-primary font-bold text-lg uppercase mb-3">4. INTELLECTUAL PROPERTY</h3>
                  <p>The specific typographic scales, diagonal corner motifs, and tonal layer hierarchies used within the Monolithic Management Interface are proprietary and protected. Any replication of this UI for external ventures is strictly prohibited.</p>
                </div>
                <div>
                  <h3 className="text-primary font-bold text-lg uppercase mb-3">5. DISCIPLINARY ACTIONS</h3>
                  <p>Monolithic reserves the right to audit facility operations at any time. We demand a culture of total transparency and unwavering commitment to the sanctuary’s standards of excellence and exclusivity.</p>
                </div>
                <div className="py-12 text-center border-t border-border/30 italic">
                  <p className="text-[10px] font-bold tracking-[0.2em] opacity-50 uppercase">— End of Document —</p>
                </div>
              </div>
            </section>

            {/* Interaction Footer */}
            <Form method="post" className="space-y-8 bg-surface-low p-8 border border-border">
              <input type="hidden" name="_action" value="claim_role" />

              <label className="flex items-start gap-4 cursor-pointer group">
                <div className="relative mt-1">
                  <input required type="checkbox" className="peer appearance-none w-6 h-6 border-2 border-border bg-background checked:bg-primary checked:border-primary transition-all rounded-none" />
                  <span className="material-symbols-outlined absolute inset-0 text-primary-foreground text-lg flex items-center justify-center opacity-0 peer-checked:opacity-100 transition-opacity pointer-events-none" style={{ fontVariationSettings: "'FILL' 1" }}>check</span>
                </div>
                <span className="font-sans text-[12px] font-bold leading-tight uppercase text-muted-foreground group-hover:text-primary transition-colors pt-1">
                  I agree to the terms and service and acknowledge the professional requirements of the Monolithic brand.
                </span>
              </label>

              {actionData?.error && (
                <p className="text-destructive text-sm font-semibold">
                  {actionData.error}
                </p>
              )}

              <div className="flex justify-end">
                <LoaderButton
                  type="submit"
                  isLoading={isSubmitting}
                  className="px-12 bg-primary text-primary-foreground font-heading text-lg font-bold py-6 uppercase tracking-widest hover:bg-primary/90 transition-all flex items-center justify-center gap-3 active:scale-95 duration-150 rounded-none"
                >
                  Accept & Continue
                  <span className="material-symbols-outlined">east</span>
                </LoaderButton>
              </div>
            </Form>
          </div>
        </main>

        {/* Desktop Accents (Subtle Corners) */}
        <div className="fixed top-24 left-8 w-12 h-12 border-t-2 border-l-2 border-primary/10 pointer-events-none hidden lg:block z-0"></div>
        <div className="fixed bottom-8 right-8 w-12 h-12 border-b-2 border-r-2 border-primary/10 pointer-events-none hidden lg:block z-0"></div>
      </div>
    </div>
  );
}

