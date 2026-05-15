import type { Route } from "./+types/_app._index";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Dashboard | Monolithic" },
    { name: "description", content: "Executive overview" },
  ];
}

export default function Index() {
  return (
    <div className="p-8 md:p-16 max-w-5xl mx-auto flex flex-col gap-16">
      <header>
        <h2 className="font-heading text-4xl md:text-5xl font-extrabold tracking-tight uppercase text-primary mb-4">
          DASHBOARD_OVERVIEW
        </h2>
        <p className="text-muted-foreground text-lg leading-relaxed max-w-2xl">
          Aggregated performance metrics across the global gymnasium portfolio. 
          Strategic data visualization for executive oversight.
        </p>
      </header>

      <section className="flex flex-col gap-6">
        <h3 className="text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground">
          PORTFOLIO_VENUES
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div className="bg-surface-high p-8 border-l-2 border-primary">
            <h4 className="font-heading font-bold text-xl uppercase mb-2">DOWNTOWN HQ</h4>
            <p className="text-sm text-muted-foreground">Peak Occupancy</p>
          </div>
          <div className="bg-surface-low p-8">
            <h4 className="font-heading font-bold text-xl uppercase mb-2">UPTOWN WELLNESS</h4>
            <p className="text-sm text-muted-foreground">Highest Growth Plan</p>
          </div>
          <div className="bg-surface-low p-8">
            <h4 className="font-heading font-bold text-xl uppercase mb-2">WESTSIDE BOX</h4>
            <p className="text-sm text-muted-foreground">Equipment Health Index</p>
          </div>
        </div>
      </section>

      <section className="flex flex-col gap-6">
        <h3 className="text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground">
          ANALYTICS_PULSE
        </h3>
        <div className="h-64 bg-surface-highest/50 flex items-center justify-center">
          <p className="text-muted-foreground font-mono text-sm uppercase">Chart Data Unavailable</p>
        </div>
      </section>
      
      <footer className="pt-16 border-t border-border mt-auto">
        <p className="text-xs text-muted-foreground uppercase tracking-widest font-bold">
          © 2024 Monolithic Editorial Gym Group. All Rights Reserved.
        </p>
      </footer>
    </div>
  );
}
