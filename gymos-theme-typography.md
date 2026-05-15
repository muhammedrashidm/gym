# GymOS Web App — Typography, Themes & Dark/Night Mode

> Extends `web-app.md`. Slots into the existing clean architecture without modifying any feature module. All theme and typography infrastructure lives in `shared/` and `core/` — zero coupling to domain or application layers.

---

## Table of Contents

1. [Design Decisions](#1-design-decisions)
2. [Three Modes Defined](#2-three-modes-defined)
3. [Typography System](#3-typography-system)
4. [Folder Placement](#4-folder-placement)
5. [Phase 1: Setup (CSS Vars + Tailwind + Fonts)](#5-phase-1-setup)
6. [Phase 2: Theme Token System](#6-phase-2-theme-token-system)
7. [Phase 3: Core Hook + Context](#7-phase-3-core-hook--context)
8. [Phase 4: SSR Flash Prevention](#8-phase-4-ssr-flash-prevention)
9. [Phase 5: Theme Switcher Component](#9-phase-5-theme-switcher-component)
10. [Phase 6: shadcn/ui Integration](#10-phase-6-shadcnui-integration)
11. [Usage Patterns](#11-usage-patterns)
12. [Checklist](#12-checklist)

---

## 1. Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| Theme strategy | CSS custom properties + Tailwind `class` mode | Works with SSR, no flash, shadcn/ui compatible |
| Theme storage | `localStorage` + cookie for SSR | Cookie survives hard refresh, no hydration mismatch |
| Three modes | `light`, `dark`, `night` | Night = deeper OLED-friendly dark, warmer tone |
| Typography | Tailwind Typography plugin + custom font tokens | Scale is per-role (admin vs member density differs) |
| Font stack | `Syne` (headings) + `Inter` (body) + `DM Mono` (code/data) | Consistent with existing brand in design system |
| Font loading | `@fontsource` npm packages | No CDN dependency, tree-shaken, self-hosted |
| Token naming | Semantic names, not raw values | `--color-primary` not `--color-blue-600` |
| shadcn/ui | Override CSS vars in theme layers | shadcn variables mapped to our token names |

---

## 2. Three Modes Defined

```
LIGHT                    DARK                     NIGHT
─────────────────────    ─────────────────────    ─────────────────────
bg:     #ffffff          bg:     #0f1117          bg:     #090b0e
surface:#f8f9fa          surface:#1a1d27          surface:#101318
text:   #111827          text:   #e2e8f0          text:   #c9d1d9
muted:  #6b7280          muted:  #6b7a94          muted:  #586069
border: #e5e7eb          border: #252c38          border: #1c2128
accent: #00e5a0          accent: #00e5a0          accent: #39d353
─────────────────────    ─────────────────────    ─────────────────────
Use case:                Use case:                Use case:
General use,             Evening use,             Low-light environments,
bright environments      reduced eye strain       OLED screens, night owls
```

`night` is not just a darker `dark`. It has:
- Higher contrast ratio for accessibility in dim rooms
- Slightly warm-tinted neutrals (prevents blue-light fatigue)
- A green accent that's slightly more saturated for visibility

---

## 3. Typography System

### Font Stack

```
Heading:   Syne         — Bold, geometric. Used for page titles, card headings.
Body:      Inter        — Clean, readable. Used for all body copy, labels, inputs.
Mono:      DM Mono      — Data, code, IDs, amounts, phone numbers, metric values.
```

### Type Scale

```
Display    48px / Syne Bold     — Hero sections, landing page only
H1         36px / Syne Bold     — Page titles
H2         28px / Syne SemiBold — Section headings
H3         22px / Syne SemiBold — Card headings, modal titles
H4         18px / Syne Medium   — Sub-headings, sidebar labels (capitalized)
Body LG    16px / Inter Regular — Primary reading text
Body       14px / Inter Regular — Default — forms, descriptions, table cells
Body SM    12px / Inter Regular — Captions, helper text, timestamps
Label      12px / Inter Medium  — Form labels, badge text (uppercase + tracking)
Mono LG    16px / DM Mono       — Revenue amounts, member IDs, metrics
Mono       14px / DM Mono       — Phone numbers, table data fields, codes
Mono SM    12px / DM Mono       — Timestamps in tables, API keys
```

### Role-Specific Density

Different dashboards need different information density:

```
Super Admin / Admin Staff  → "Data Dense" variant
  - Body: 13px
  - Line height: 1.5
  - Table cells: compact padding
  - Focus: maximum information per screen

Gym Owner                  → "Balanced" variant (default)
  - Body: 14px
  - Line height: 1.7
  - Cards: comfortable padding

Staff Mobile (web fallback) → N/A (Flutter handles this)
```

---

## 4. Folder Placement

Fits the existing structure from `web-app.md` without modification:

```
gym-app/
├── app/
│   ├── core/
│   │   ├── hooks/
│   │   │   └── use_theme.ts          ← theme hook (Phase 3)
│   │   └── config/
│   │       └── theme.ts              ← theme constants + type definitions
│   │
│   ├── shared/
│   │   ├── ui/
│   │   │   ├── theme/
│   │   │   │   ├── theme_switcher.tsx      ← switcher component (Phase 5)
│   │   │   │   ├── theme_script.tsx        ← SSR inline script (Phase 4)
│   │   │   │   └── theme_provider.tsx      ← React context (Phase 3)
│   │   │   │
│   │   │   └── typography/
│   │   │       ├── text.tsx                ← <Text> component
│   │   │       └── heading.tsx             ← <Heading> component
│   │   │
│   │   └── layouts/
│   │       └── root_layout.tsx       ← wraps ThemeProvider (Phase 3)
│   │
│   └── styles/
│       ├── globals.css               ← CSS variables + base styles (Phase 1)
│       ├── tokens.css                ← all theme token layers (Phase 2)
│       └── typography.css            ← font-face + type utilities (Phase 1)
```

> `styles/` is a new folder alongside `shared/`. Alternatively, put it inside `shared/styles/` — either works. The key point is it has **no imports from features or domain** — it's pure CSS and shared components only.

---

## 5. Phase 1: Setup

### Step 1 — Install Dependencies

```bash
# Fonts via fontsource (self-hosted, no CDN needed)
npm install @fontsource/syne @fontsource/inter @fontsource/dm-mono

# Tailwind typography plugin
npm install -D @tailwindcss/typography

# next-themes for theme management (SSR-safe)
npm install next-themes
```

> **Why `next-themes`?** It handles the SSR flash problem out of the box, works with React Router 7 / Remix, and supports custom theme names beyond just `light`/`dark`. We add `night` as a custom value.

---

### Step 2 — Import Fonts in Entry File

```typescript
// app/entry.client.tsx  (or root.tsx imports section)

// Syne — weights 400, 600, 700, 800
import '@fontsource/syne/400.css';
import '@fontsource/syne/600.css';
import '@fontsource/syne/700.css';
import '@fontsource/syne/800.css';

// Inter — weights 300, 400, 500
import '@fontsource/inter/300.css';
import '@fontsource/inter/400.css';
import '@fontsource/inter/500.css';

// DM Mono — weights 400, 500
import '@fontsource/dm-mono/400.css';
import '@fontsource/dm-mono/500.css';
```

---

### Step 3 — Tailwind Config

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';
import typography from '@tailwindcss/typography';

export default {
  // 'class' strategy: theme is set by a class on <html>
  // e.g. <html class="dark"> or <html class="night">
  darkMode: ['class'],

  content: ['./app/**/*.{ts,tsx}'],

  theme: {
    extend: {
      // ── FONT FAMILIES ──────────────────────────────
      fontFamily: {
        sans:    ['Inter', 'system-ui', 'sans-serif'],
        heading: ['Syne', 'system-ui', 'sans-serif'],
        mono:    ['DM Mono', 'ui-monospace', 'monospace'],
      },

      // ── TYPE SCALE ─────────────────────────────────
      fontSize: {
        'display': ['3rem', { lineHeight: '1.05', letterSpacing: '-0.04em', fontWeight: '800' }],
        'h1':      ['2.25rem', { lineHeight: '1.1',  letterSpacing: '-0.04em', fontWeight: '700' }],
        'h2':      ['1.75rem', { lineHeight: '1.2',  letterSpacing: '-0.03em', fontWeight: '600' }],
        'h3':      ['1.375rem',{ lineHeight: '1.3',  letterSpacing: '-0.02em', fontWeight: '600' }],
        'h4':      ['1.125rem',{ lineHeight: '1.4',  letterSpacing: '0em',     fontWeight: '500' }],
        'body-lg': ['1rem',    { lineHeight: '1.7' }],
        'body':    ['0.875rem',{ lineHeight: '1.7' }],
        'body-sm': ['0.75rem', { lineHeight: '1.6' }],
        'label':   ['0.75rem', { lineHeight: '1.4', letterSpacing: '0.06em',  fontWeight: '500' }],
        'mono-lg': ['1rem',    { lineHeight: '1.5', fontFamily: 'DM Mono' }],
        'mono':    ['0.875rem',{ lineHeight: '1.5', fontFamily: 'DM Mono' }],
        'mono-sm': ['0.75rem', { lineHeight: '1.5', fontFamily: 'DM Mono' }],
      },

      // ── SEMANTIC COLOR TOKENS (via CSS vars) ───────
      // All colors reference CSS custom properties.
      // The actual hex values live in tokens.css, not here.
      colors: {
        background:   'hsl(var(--color-bg) / <alpha-value>)',
        surface:      'hsl(var(--color-surface) / <alpha-value>)',
        'surface-2':  'hsl(var(--color-surface-2) / <alpha-value>)',
        border:       'hsl(var(--color-border) / <alpha-value>)',
        foreground:   'hsl(var(--color-text) / <alpha-value>)',
        muted:        'hsl(var(--color-muted) / <alpha-value>)',
        primary:      'hsl(var(--color-primary) / <alpha-value>)',
        'primary-fg': 'hsl(var(--color-primary-fg) / <alpha-value>)',
        secondary:    'hsl(var(--color-secondary) / <alpha-value>)',
        accent:       'hsl(var(--color-accent) / <alpha-value>)',
        destructive:  'hsl(var(--color-destructive) / <alpha-value>)',
        warning:      'hsl(var(--color-warning) / <alpha-value>)',
        success:      'hsl(var(--color-success) / <alpha-value>)',
      },

      // ── BORDER RADIUS (shadcn/ui compatible) ───────
      borderRadius: {
        lg:  'var(--radius)',
        md:  'calc(var(--radius) - 2px)',
        sm:  'calc(var(--radius) - 4px)',
      },
    },
  },

  plugins: [typography],
} satisfies Config;
```

---

## 6. Phase 2: Theme Token System

### `app/styles/tokens.css`

This is the single source of truth for all color values. Three layers using CSS attribute selectors on `<html>`.

```css
/* ─────────────────────────────────────────────────────
   LIGHT THEME  (default — no class needed)
───────────────────────────────────────────────────── */
:root {
  /* Background layers */
  --color-bg:        0 0% 100%;        /* #ffffff */
  --color-surface:   210 20% 98%;      /* #f8f9fa */
  --color-surface-2: 210 16% 96%;      /* #f1f3f5 */

  /* Text */
  --color-text:      220 13% 13%;      /* #111827 */
  --color-muted:     220 9% 46%;       /* #6b7280 */

  /* Borders */
  --color-border:    220 13% 91%;      /* #e5e7eb */

  /* Brand */
  --color-primary:   160 100% 45%;     /* #00e5a0 */
  --color-primary-fg:220 13% 13%;      /* dark text on primary bg */
  --color-secondary: 213 100% 50%;     /* #0099ff */
  --color-accent:    160 100% 45%;     /* #00e5a0 */

  /* Semantic */
  --color-destructive: 0 84% 60%;      /* #f87171 */
  --color-warning:     45 96% 54%;     /* #fbbf24 */
  --color-success:     142 72% 45%;    /* #22c55e */

  /* Radius */
  --radius: 0.5rem;

  /* Sidebar width */
  --sidebar-width: 256px;
}

/* ─────────────────────────────────────────────────────
   DARK THEME
───────────────────────────────────────────────────── */
.dark {
  --color-bg:        222 22% 7%;       /* #0f1117 */
  --color-surface:   224 20% 13%;      /* #1a1d27 */
  --color-surface-2: 222 18% 18%;      /* #252c38 */

  --color-text:      213 27% 91%;      /* #e2e8f0 */
  --color-muted:     215 15% 50%;      /* #6b7a94 */

  --color-border:    217 19% 22%;      /* #252c38 */

  --color-primary:   160 100% 45%;     /* #00e5a0 */
  --color-primary-fg:220 13% 13%;
  --color-secondary: 213 100% 50%;     /* #0099ff */
  --color-accent:    160 100% 45%;

  --color-destructive: 0 63% 61%;      /* #e06c75 */
  --color-warning:     45 96% 54%;
  --color-success:     160 100% 45%;

  --radius: 0.5rem;
  --sidebar-width: 256px;
}

/* ─────────────────────────────────────────────────────
   NIGHT THEME
   Deeper dark, warmer neutrals, OLED-optimised
───────────────────────────────────────────────────── */
.night {
  --color-bg:        218 22% 5%;       /* #090b0e */
  --color-surface:   218 20% 9%;       /* #101318 */
  --color-surface-2: 216 18% 13%;      /* #181c22 */

  --color-text:      213 18% 83%;      /* #c9d1d9 — slightly warmer than dark */
  --color-muted:     210 12% 40%;      /* #586069 */

  --color-border:    216 16% 14%;      /* #1c2128 */

  --color-primary:   145 63% 52%;      /* #39d353 — warmer green */
  --color-primary-fg:218 22% 5%;
  --color-secondary: 207 90% 54%;      /* #2196f3 — slightly muted blue */
  --color-accent:    145 63% 52%;

  --color-destructive: 3 56% 52%;      /* #c0392b — muted red, less harsh */
  --color-warning:     37 90% 50%;     /* #e6a817 — amber, not bright yellow */
  --color-success:     145 63% 52%;    /* matches primary */

  --radius: 0.5rem;
  --sidebar-width: 256px;
}
```

---

### `app/styles/globals.css`

```css
@import './tokens.css';
@import './typography.css';

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply border-border;
  }

  html {
    /* Smooth theme transitions */
    transition: background-color 200ms ease, color 150ms ease;
  }

  body {
    @apply bg-background text-foreground font-sans;
    font-feature-settings: "rlig" 1, "calt" 1;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-rendering: optimizeLegibility;
  }
}

@layer utilities {
  /* Density variants */
  .density-compact {
    --spacing-cell: 0.5rem;
    font-size: 0.8125rem;
    line-height: 1.5;
  }
  .density-normal {
    --spacing-cell: 0.75rem;
    font-size: 0.875rem;
    line-height: 1.7;
  }
}
```

---

### `app/styles/typography.css`

```css
@layer base {
  /* ── HEADING DEFAULTS ─────────────────────────── */
  h1, h2, h3, h4 {
    font-family: 'Syne', system-ui, sans-serif;
    font-weight: 700;
    letter-spacing: -0.03em;
    color: hsl(var(--color-text));
  }

  /* ── INLINE MONO ──────────────────────────────── */
  /* Numbers, amounts, IDs, phone numbers rendered inline */
  .font-data {
    font-family: 'DM Mono', ui-monospace, monospace;
    font-variant-numeric: tabular-nums;
    letter-spacing: 0;
  }

  /* ── LABEL TEXT ───────────────────────────────── */
  .text-label {
    font-size: 0.75rem;
    font-weight: 500;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: hsl(var(--color-muted));
  }

  /* ── ADMIN DENSITY ────────────────────────────── */
  /* Applied to admin/staff dashboard root div */
  .admin-density table td,
  .admin-density table th {
    padding: 0.375rem 0.75rem;
    font-size: 0.8125rem;
  }
}
```

---

## 7. Phase 3: Core Hook + Context

### `app/core/config/theme.ts`

```typescript
// Theme type definitions — single source of truth for TypeScript

export const THEMES = ['light', 'dark', 'night'] as const;
export type Theme = typeof THEMES[number];

export const DEFAULT_THEME: Theme = 'dark';
export const THEME_STORAGE_KEY = 'gymos-theme';
export const THEME_COOKIE_KEY = 'theme';

export const THEME_LABELS: Record<Theme, { label: string; icon: string; description: string }> = {
  light: {
    label: 'Light',
    icon: '☀️',
    description: 'Bright, high contrast',
  },
  dark: {
    label: 'Dark',
    icon: '🌙',
    description: 'Easy on the eyes',
  },
  night: {
    label: 'Night',
    icon: '🌑',
    description: 'Deep dark, OLED optimised',
  },
};
```

---

### `app/shared/ui/theme/theme_provider.tsx`

```tsx
import { ThemeProvider as NextThemesProvider } from 'next-themes';
import { THEME_STORAGE_KEY, DEFAULT_THEME } from '~/core/config/theme';
import type { ReactNode } from 'react';

interface ThemeProviderProps {
  children: ReactNode;
  // SSR: pass cookie value so first render matches server
  defaultTheme?: string;
}

export function ThemeProvider({ children, defaultTheme = DEFAULT_THEME }: ThemeProviderProps) {
  return (
    <NextThemesProvider
      attribute="class"                // applies class to <html>
      defaultTheme={defaultTheme}
      themes={['light', 'dark', 'night']}
      storageKey={THEME_STORAGE_KEY}
      enableSystem={false}             // we manage 3 explicit themes, no system override
      disableTransitionOnChange={false}
    >
      {children}
    </NextThemesProvider>
  );
}
```

---

### `app/core/hooks/use_theme.ts`

```typescript
import { useTheme as useNextTheme } from 'next-themes';
import { THEMES, type Theme } from '~/core/config/theme';

export interface UseThemeReturn {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  isDark: boolean;
  isLight: boolean;
  isNight: boolean;
  toggleTheme: () => void;   // cycles light → dark → night → light
}

export function useTheme(): UseThemeReturn {
  const { theme, setTheme } = useNextTheme();

  const current = (theme ?? 'dark') as Theme;

  const toggleTheme = () => {
    const idx = THEMES.indexOf(current);
    const next = THEMES[(idx + 1) % THEMES.length];
    setTheme(next);
  };

  return {
    theme:     current,
    setTheme,
    isDark:    current === 'dark',
    isLight:   current === 'light',
    isNight:   current === 'night',
    toggleTheme,
  };
}
```

---

### Wire into Root Layout

```tsx
// app/shared/layouts/root_layout.tsx
import { ThemeProvider } from '~/shared/ui/theme/theme_provider';
import { Outlet } from 'react-router';

interface RootLayoutProps {
  cookieTheme?: string;    // passed from loader for SSR
}

export function RootLayout({ cookieTheme }: RootLayoutProps) {
  return (
    <ThemeProvider defaultTheme={cookieTheme}>
      <Outlet />
    </ThemeProvider>
  );
}
```

```tsx
// app/root.tsx
import { RootLayout } from '~/shared/layouts/root_layout';
import type { LoaderFunctionArgs } from 'react-router';
import { THEME_COOKIE_KEY } from '~/core/config/theme';

// Read theme from cookie on server so initial HTML class is correct
export async function loader({ request }: LoaderFunctionArgs) {
  const cookieHeader = request.headers.get('Cookie') ?? '';
  const match = cookieHeader.match(new RegExp(`${THEME_COOKIE_KEY}=([^;]+)`));
  const cookieTheme = match?.[1] ?? 'dark';
  return { cookieTheme };
}

export default function App() {
  // data comes from loader
  return <RootLayout />;
}
```

---

## 8. Phase 4: SSR Flash Prevention

Without this, the page briefly flashes the wrong theme on hard refresh before React hydrates.

### `app/shared/ui/theme/theme_script.tsx`

This is a tiny inline `<script>` injected into `<head>` — it runs **before** React hydrates, reading from both cookie and localStorage and setting the class on `<html>` synchronously.

```tsx
// Renders a <script> tag — must be in <head> before any CSS

export function ThemeScript() {
  const script = `
    (function() {
      try {
        var cookie = document.cookie.match(/theme=([^;]+)/);
        var stored = localStorage.getItem('gymos-theme');
        var theme = (cookie && cookie[1]) || stored || 'dark';
        var valid = ['light', 'dark', 'night'];
        if (!valid.includes(theme)) theme = 'dark';
        document.documentElement.classList.add(theme);
        document.documentElement.setAttribute('data-theme', theme);
      } catch(e) {
        document.documentElement.classList.add('dark');
      }
    })();
  `;

  return (
    <script
      dangerouslySetInnerHTML={{ __html: script }}
      suppressHydrationWarning
    />
  );
}
```

```tsx
// app/root.tsx — place ThemeScript in <head>
import { ThemeScript } from '~/shared/ui/theme/theme_script';

export default function App() {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <ThemeScript />
        {/* other head content */}
      </head>
      <body>
        <RootLayout />
      </body>
    </html>
  );
}
```

> `suppressHydrationWarning` on `<html>` is required because the class on the server (`dark` from cookie) might differ from the class applied by the inline script in edge cases. React suppresses the warning rather than erroring.

---

### Persist to Cookie on Theme Change

`next-themes` handles `localStorage`. We also need a cookie so the server can read it on the next request (for SSR). Do this in the theme switcher or in a `useEffect` in the provider:

```typescript
// app/shared/ui/theme/theme_provider.tsx — add this effect

useEffect(() => {
  if (!theme) return;
  // Set cookie with 1-year expiry, path=/, SameSite=Lax
  document.cookie = `theme=${theme};max-age=31536000;path=/;SameSite=Lax`;
}, [theme]);
```

---

## 9. Phase 5: Theme Switcher Component

### `app/shared/ui/theme/theme_switcher.tsx`

```tsx
import { useTheme } from '~/core/hooks/use_theme';
import { THEME_LABELS, THEMES, type Theme } from '~/core/config/theme';
import { cn } from '~/shared/utils/cn';  // clsx/tailwind-merge util

export function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();

  return (
    <div
      role="group"
      aria-label="Select theme"
      className="flex items-center gap-1 rounded-lg border border-border bg-surface p-1"
    >
      {THEMES.map((t) => {
        const { label, icon } = THEME_LABELS[t];
        const isActive = theme === t;

        return (
          <button
            key={t}
            onClick={() => setTheme(t)}
            aria-pressed={isActive}
            aria-label={`Switch to ${label} theme`}
            title={`${label} — ${THEME_LABELS[t].description}`}
            className={cn(
              'flex items-center gap-1.5 rounded-md px-2.5 py-1.5 text-body-sm font-medium transition-all duration-150',
              isActive
                ? 'bg-primary text-primary-fg shadow-sm'
                : 'text-muted hover:text-foreground hover:bg-surface-2'
            )}
          >
            <span aria-hidden="true">{icon}</span>
            <span className="hidden sm:inline">{label}</span>
          </button>
        );
      })}
    </div>
  );
}
```

### Single Toggle Button Variant (for compact headers)

```tsx
export function ThemeToggleButton() {
  const { theme, toggleTheme } = useTheme();
  const { icon, label } = THEME_LABELS[theme];

  return (
    <button
      onClick={toggleTheme}
      aria-label={`Current theme: ${label}. Click to switch.`}
      className="flex h-8 w-8 items-center justify-center rounded-md border border-border text-muted hover:text-foreground hover:bg-surface-2 transition-colors"
    >
      <span aria-hidden="true">{icon}</span>
    </button>
  );
}
```

---

## 10. Phase 6: shadcn/ui Integration

shadcn/ui uses its own CSS variable names (`--background`, `--foreground`, `--primary`, etc.). We map our tokens to shadcn's expected names so all shadcn components pick up our theme automatically.

### Add to `tokens.css` — inside each theme layer

```css
/* shadcn/ui variable mapping — add into :root, .dark, .night blocks */

/* Inside :root (light) */
:root {
  /* ... existing tokens ... */

  /* shadcn compatibility mapping */
  --background:          var(--color-bg);
  --foreground:          var(--color-text);
  --card:                var(--color-surface);
  --card-foreground:     var(--color-text);
  --popover:             var(--color-surface);
  --popover-foreground:  var(--color-text);
  --primary:             var(--color-primary);
  --primary-foreground:  var(--color-primary-fg);
  --secondary:           var(--color-surface-2);
  --secondary-foreground:var(--color-text);
  --muted:               var(--color-surface-2);
  --muted-foreground:    var(--color-muted);
  --accent:              var(--color-surface-2);
  --accent-foreground:   var(--color-text);
  --destructive:         var(--color-destructive);
  --destructive-foreground: 0 0% 100%;
  --border:              var(--color-border);
  --input:               var(--color-border);
  --ring:                var(--color-primary);
}

/* Repeat the same mapping block inside .dark { } and .night { } */
/* Since they all reference --color-* vars, the values update automatically */
/* when the theme class changes. No duplication needed. */
```

> This is the clean win: because both our tokens and the shadcn mapping use the same `--color-*` custom properties as the source, the shadcn mapping block only needs to be written once inside `:root`. The `.dark` and `.night` layers redefine `--color-*`, and the shadcn vars automatically inherit the updated values.

---

## 11. Usage Patterns

### In Components — Tailwind semantic classes

```tsx
// ✅ Always use semantic color classes, never raw color classes

// Background
<div className="bg-background">           {/* main page bg */}
<div className="bg-surface">              {/* card bg */}
<div className="bg-surface-2">           {/* nested surface */}

// Text
<p className="text-foreground">          {/* body text */}
<p className="text-muted">               {/* secondary text */}

// Brand
<button className="bg-primary text-primary-fg">   {/* CTA */}
<span className="text-primary">                    {/* accent text */}

// ❌ Never do this — breaks theming
<div className="bg-gray-900">
<p className="text-white">
```

---

### Typography Components

```tsx
// app/shared/ui/typography/heading.tsx
import { cn } from '~/shared/utils/cn';
import type { ReactNode } from 'react';

type Level = 1 | 2 | 3 | 4;

const sizeMap: Record<Level, string> = {
  1: 'text-h1 font-heading font-bold',
  2: 'text-h2 font-heading font-semibold',
  3: 'text-h3 font-heading font-semibold',
  4: 'text-h4 font-heading font-medium',
};

export function Heading({ level = 2, children, className }: {
  level?: Level;
  children: ReactNode;
  className?: string;
}) {
  const Tag = `h${level}` as const;
  return (
    <Tag className={cn(sizeMap[level], 'text-foreground', className)}>
      {children}
    </Tag>
  );
}
```

```tsx
// app/shared/ui/typography/text.tsx
import { cn } from '~/shared/utils/cn';

type Variant = 'body-lg' | 'body' | 'body-sm' | 'label' | 'mono-lg' | 'mono' | 'mono-sm';
type Color = 'default' | 'muted' | 'primary' | 'destructive';

const colorMap: Record<Color, string> = {
  default:     'text-foreground',
  muted:       'text-muted',
  primary:     'text-primary',
  destructive: 'text-destructive',
};

const variantMap: Record<Variant, string> = {
  'body-lg': 'text-body-lg font-sans',
  'body':    'text-body font-sans',
  'body-sm': 'text-body-sm font-sans',
  'label':   'text-label font-sans uppercase tracking-wider',
  'mono-lg': 'text-mono-lg font-mono font-data',
  'mono':    'text-mono font-mono font-data',
  'mono-sm': 'text-mono-sm font-mono font-data',
};

export function Text({ variant = 'body', color = 'default', children, className }: {
  variant?: Variant;
  color?: Color;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span className={cn(variantMap[variant], colorMap[color], className)}>
      {children}
    </span>
  );
}
```

---

### Data Values (revenue, phone, IDs)

```tsx
// Numbers and data values always use mono font
// so they're readable and aligned in tables

<Text variant="mono-lg" color="primary">₹1,29,000</Text>
<Text variant="mono" color="muted">+91 98765 43210</Text>
<Text variant="mono-sm" color="muted">usr_a3f2c1d4</Text>

// Or directly with Tailwind
<span className="font-mono text-mono font-data tabular-nums text-foreground">
  ₹1,29,000
</span>
```

---

### Placing ThemeSwitcher in Sidebar / Header

```tsx
// Sidebar bottom (recommended — away from primary actions)
import { ThemeSwitcher } from '~/shared/ui/theme/theme_switcher';
import { ThemeToggleButton } from '~/shared/ui/theme/theme_switcher';

// Full switcher — sidebar footer
<div className="mt-auto border-t border-border p-4">
  <ThemeSwitcher />
</div>

// Compact toggle — top-right header bar
<header className="flex items-center justify-between border-b border-border px-6 py-3">
  <Heading level={4}>{pageTitle}</Heading>
  <ThemeToggleButton />
</header>
```

---

## 12. Checklist

### Phase 1 — Setup

- [ ] `npm install @fontsource/syne @fontsource/inter @fontsource/dm-mono`
- [ ] `npm install next-themes`
- [ ] `npm install -D @tailwindcss/typography`
- [ ] Create `app/styles/tokens.css` with `:root`, `.dark`, `.night` layers
- [ ] Create `app/styles/globals.css` importing tokens + Tailwind directives
- [ ] Create `app/styles/typography.css` with base heading and label styles
- [ ] Update `tailwind.config.ts` with `fontFamily`, `fontSize`, `colors`, `darkMode: ['class']`
- [ ] Import font packages in `entry.client.tsx`

### Phase 2 — Core Wiring

- [ ] Create `app/core/config/theme.ts` with `THEMES`, `Theme`, `DEFAULT_THEME`
- [ ] Create `app/shared/ui/theme/theme_provider.tsx` using `next-themes`
- [ ] Create `app/core/hooks/use_theme.ts` wrapping `next-themes`
- [ ] Create `app/shared/ui/theme/theme_script.tsx` (SSR flash prevention)
- [ ] Add `<ThemeScript />` to `<head>` in `app/root.tsx`
- [ ] Add `suppressHydrationWarning` to `<html>` in `app/root.tsx`
- [ ] Wrap app in `<ThemeProvider>` in `root_layout.tsx`
- [ ] Add cookie persistence `useEffect` in provider

### Phase 3 — Components

- [ ] Create `ThemeSwitcher` (full 3-button) component
- [ ] Create `ThemeToggleButton` (compact cycle) component
- [ ] Create `Heading` typography component
- [ ] Create `Text` typography component with variants
- [ ] Place `ThemeSwitcher` in sidebar footer
- [ ] Place `ThemeToggleButton` in header (optional)

### Phase 4 — shadcn/ui

- [ ] Add shadcn variable mapping block to `tokens.css` `:root` layer
- [ ] Verify shadcn components (`Button`, `Card`, `Input`, `Badge`, etc.) render correctly in all 3 themes
- [ ] Test `Dialog`, `Popover`, `DropdownMenu` — these use `--popover` var

### Phase 5 — Quality

- [ ] Audit: no hardcoded `bg-gray-*`, `text-white`, `bg-zinc-*` in components
- [ ] Test SSR: hard refresh in each theme, verify no flash
- [ ] Test transitions: smooth 200ms background change on theme switch
- [ ] Accessibility: check contrast ratios in all 3 themes meet WCAG AA
- [ ] Admin density class: apply `.admin-density` to admin dashboard root

---

## Appendix: Clean Architecture Fit

| Theme concern | Layer | Location in `web-app.md` structure |
|---|---|---|
| Token definitions (CSS vars) | Styling | `app/styles/tokens.css` |
| Tailwind config | Config | `tailwind.config.ts` |
| Theme type + constants | Core Config | `app/core/config/theme.ts` |
| Theme hook | Core Hook | `app/core/hooks/use_theme.ts` |
| Theme provider (context) | Shared UI | `app/shared/ui/theme/theme_provider.tsx` |
| SSR script | Shared UI | `app/shared/ui/theme/theme_script.tsx` |
| Switcher component | Shared UI | `app/shared/ui/theme/theme_switcher.tsx` |
| Typography components | Shared UI | `app/shared/ui/typography/` |
| Root wiring | Presentation | `app/root.tsx` + `app/shared/layouts/root_layout.tsx` |

**Zero coupling rule maintained:** No feature module (`gym/`, `auth/`, `payments/`) imports anything from the theme system directly. They use Tailwind semantic class names (`bg-surface`, `text-muted`, etc.) which automatically pick up the active theme.
