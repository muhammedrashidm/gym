# GymOS Owner App — Project Setup + Auth Feature

**App**: `c:\Desk\gym_all\owner` (React Router v7 / Remix-style, SSR, TypeScript)  
**Phase**: Phase 2 Clean Architecture  
**Design**: Slate & Sinew (Stitch asset `assets/4c85fd43d5a84d95beffd192028b06fb`)

---

## Decisions & Constraints

| Decision | Choice |
|---|---|
| Architecture | Phase 2 — domain + infrastructure + application per feature |
| DI | `tsyringe` + `reflect-metadata` |
| UI | shadcn/ui on Tailwind v4 (already installed) |
| Theme | Light + Dark only, `next-themes`, CSS custom properties |
| Auth Pattern | Remix server-side session cookies (HttpOnly) |
| API | NestJS at `VITE_API_URL` from `.env` |
| Fonts | `@fontsource/manrope` + `@fontsource/inter` (self-hosted) |
| Token Storage | `accessToken` in session cookie, `refreshToken` in session cookie |

> [!IMPORTANT]
> Tokens are stored **server-side in a signed session cookie** via `react-router` sessions. The client never touches raw JWTs. This is the secure Remix pattern.

---

## Open Questions

> [!NOTE]
> None remaining. Proceeding with plan.

---

## Proposed Changes

### 1. Packages

Run in `c:\Desk\gym_all\owner`:

```bash
# DI
npm install tsyringe reflect-metadata

# Fonts
npm install @fontsource/manrope @fontsource/inter

# Theme
npm install next-themes

# shadcn/ui init (interactive — choose: TypeScript, Tailwind, CSS vars, default style)
npx shadcn@latest init

# shadcn components needed for auth
npx shadcn@latest add button input label card

# Form + validation
npm install react-hook-form zod @hookform/resolvers

# Session
npm install @react-router/node   # already present — provides createCookieSessionStorage
```

---

### 2. Environment

#### [NEW] `.env`
```
VITE_API_URL=http://localhost:3001/api/v1
SESSION_SECRET=change-me-in-production
```

#### [NEW] `.env.example`
Same as `.env` with placeholder values.

---

### 3. Project Folder Structure

After scaffolding, `app/` will look like:

```
app/
├── core/
│   ├── config/
│   │   └── env.ts                  ← typed env access
│   ├── di/
│   │   ├── container.ts            ← tsyringe container setup
│   │   └── tokens.ts               ← InjectionToken enum
│   ├── auth/
│   │   └── session.server.ts       ← cookie session helpers
│   └── hooks/
│       └── use_theme.ts            ← theme hook wrapper
│
├── datasources/
│   └── api_datasource/
│       ├── api_client.ts           ← base fetch wrapper (auth-aware)
│       └── models/
│           └── auth.model.ts       ← API DTOs
│
├── features/
│   └── auth/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── auth_user.ts    ← AuthUser entity
│       │   ├── repositories/
│       │   │   └── i_auth_repository.ts
│       │   └── errors.ts
│       ├── infrastructure/
│       │   └── repositories/
│       │       └── auth_repository.ts
│       ├── application/
│       │   └── auth_handler.ts     ← loader/action orchestration
│       └── presentation/
│           ├── components/
│           │   ├── otp_request_form.tsx
│           │   └── otp_verify_form.tsx
│           └── pages/
│               └── login_page.tsx
│
├── shared/
│   ├── components/
│   │   └── loader_button.tsx       ← Button + spinner state
│   ├── layouts/
│   │   ├── auth_layout.tsx
│   │   └── app_layout.tsx          ← stub for future use
│   └── ui/
│       └── theme/
│           ├── theme_provider.tsx
│           ├── theme_script.tsx    ← SSR flash prevention
│           └── theme_switcher.tsx
│
├── styles/
│   ├── globals.css                 ← Tailwind + CSS vars
│   └── tokens.css                  ← Slate & Sinew color tokens
│
├── routes/
│   ├── _auth.tsx                   ← auth layout shell (no nav)
│   ├── _auth.login.tsx             ← /login route
│   ├── _app.tsx                    ← protected shell (redirect if unauthed)
│   └── _app._index.tsx             ← / (dashboard stub)
│
├── root.tsx                        ← updated: ThemeProvider, fonts
├── routes.ts                       ← updated: all routes
└── entry.client.tsx                ← reflect-metadata import
```

---

### 4. Core Infrastructure Files

#### [MODIFY] `app/entry.client.tsx`
Add `import 'reflect-metadata'` as **first line** (required for tsyringe decorators).

#### [NEW] `app/core/config/env.ts`
```typescript
export const env = {
  apiUrl: import.meta.env.VITE_API_URL as string,
};
```

#### [NEW] `app/core/di/tokens.ts`
```typescript
export const Tokens = {
  IAuthRepository: Symbol('IAuthRepository'),
} as const;
```

#### [NEW] `app/core/di/container.ts`
```typescript
import 'reflect-metadata';
import { container } from 'tsyringe';
import { Tokens } from './tokens';
import { AuthRepository } from '~/features/auth/infrastructure/repositories/auth_repository';

container.register(Tokens.IAuthRepository, { useClass: AuthRepository });

export { container };
```

#### [NEW] `app/core/auth/session.server.ts`
```typescript
import { createCookieSessionStorage, redirect } from 'react-router';

// Session shape
export type SessionData = {
  accessToken: string;
  refreshToken: string;
  userId: string;
  phoneNumber: string;
  roles: UserRoleClaim[];
};

export const sessionStorage = createCookieSessionStorage<SessionData>({
  cookie: {
    name: '__gymos_session',
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    secrets: [process.env.SESSION_SECRET!],
    maxAge: 60 * 60 * 24 * 30, // 30 days
  },
});

export async function getSession(request: Request) {
  return sessionStorage.getSession(request.headers.get('Cookie'));
}

export async function requireAuth(request: Request): Promise<SessionData> {
  const session = await getSession(request);
  const accessToken = session.get('accessToken');
  if (!accessToken) throw redirect('/login');
  return {
    accessToken,
    refreshToken: session.get('refreshToken')!,
    userId: session.get('userId')!,
    phoneNumber: session.get('phoneNumber')!,
    roles: session.get('roles') ?? [],
  };
}

export async function destroySession(request: Request) {
  const session = await getSession(request);
  return sessionStorage.destroySession(session);
}
```

---

### 5. Datasource Layer

#### [NEW] `app/datasources/api_datasource/models/auth.model.ts`
```typescript
export interface UserRoleClaim {
  roleId: string;
  roleName: string;
  gymId: string | null;
}

export interface VerifyOtpResponseDTO {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    phoneNumber: string;
    isActive: boolean;
    roles: UserRoleClaim[];
  };
  claimedProfile: unknown | null;
}

export interface RefreshTokenResponseDTO {
  accessToken: string;
  refreshToken: string;
}
```

#### [NEW] `app/datasources/api_datasource/api_client.ts`
```typescript
import { env } from '~/core/config/env';

export class ApiClient {
  private baseUrl: string;

  constructor(baseUrl = env.apiUrl) {
    this.baseUrl = baseUrl;
  }

  async post<T>(path: string, body?: unknown, token?: string): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const res = await fetch(`${this.baseUrl}${path}`, {
      method: 'POST',
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new ApiError(res.status, err.message ?? 'Request failed');
    }
    return res.json();
  }

  async get<T>(path: string, token: string): Promise<T> {
    const res = await fetch(`${this.baseUrl}${path}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new ApiError(res.status, 'Request failed');
    return res.json();
  }
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

// Singleton
export const apiClient = new ApiClient();
```

---

### 6. Auth Feature — Domain

#### [NEW] `app/features/auth/domain/entities/auth_user.ts`
```typescript
import type { UserRoleClaim } from '~/datasources/api_datasource/models/auth.model';

export class AuthUser {
  constructor(
    public id: string,
    public phoneNumber: string,
    public isActive: boolean,
    public roles: UserRoleClaim[],
  ) {}

  hasRole(roleName: string): boolean {
    return this.roles.some(r => r.roleName === roleName);
  }

  isOwner(): boolean {
    return this.hasRole('owner');
  }
}
```

#### [NEW] `app/features/auth/domain/repositories/i_auth_repository.ts`
```typescript
import type { AuthUser } from '../entities/auth_user';

export interface IAuthRepository {
  requestOtp(phoneNumber: string): Promise<void>;
  verifyOtp(phoneNumber: string, code: string): Promise<{
    accessToken: string;
    refreshToken: string;
    user: AuthUser;
  }>;
  refresh(refreshToken: string): Promise<{
    accessToken: string;
    refreshToken: string;
  }>;
  logout(accessToken: string, refreshToken: string): Promise<void>;
  getMe(accessToken: string): Promise<AuthUser>;
}
```

#### [NEW] `app/features/auth/domain/errors.ts`
```typescript
export class InvalidOtpError extends Error {
  constructor() { super('Invalid or expired OTP'); }
}

export class UnauthorizedError extends Error {
  constructor() { super('Unauthorized'); }
}
```

---

### 7. Auth Feature — Infrastructure

#### [NEW] `app/features/auth/infrastructure/repositories/auth_repository.ts`
```typescript
import { injectable } from 'tsyringe';
import { apiClient, ApiError } from '~/datasources/api_datasource/api_client';
import type { IAuthRepository } from '../../domain/repositories/i_auth_repository';
import { AuthUser } from '../../domain/entities/auth_user';
import { InvalidOtpError, UnauthorizedError } from '../../domain/errors';
import type { VerifyOtpResponseDTO, RefreshTokenResponseDTO } from '~/datasources/api_datasource/models/auth.model';

@injectable()
export class AuthRepository implements IAuthRepository {
  async requestOtp(phoneNumber: string): Promise<void> {
    await apiClient.post('/auth/request-otp', { phoneNumber });
  }

  async verifyOtp(phoneNumber: string, code: string) {
    try {
      const data = await apiClient.post<VerifyOtpResponseDTO>(
        '/auth/verify-otp',
        { phoneNumber, code }
      );
      return {
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        user: new AuthUser(data.user.id, data.user.phoneNumber, data.user.isActive, data.user.roles),
      };
    } catch (e) {
      if (e instanceof ApiError && e.status === 401) throw new InvalidOtpError();
      throw e;
    }
  }

  async refresh(refreshToken: string) {
    const data = await apiClient.post<RefreshTokenResponseDTO>(
      '/auth/refresh',
      undefined,
      refreshToken
    );
    return { accessToken: data.accessToken, refreshToken: data.refreshToken };
  }

  async logout(accessToken: string, refreshToken: string): Promise<void> {
    await apiClient.post('/auth/logout', { refreshToken }, accessToken);
  }

  async getMe(accessToken: string): Promise<AuthUser> {
    const data = await apiClient.get<any>('/auth/me', accessToken);
    return new AuthUser(data.id, data.phoneNumber, data.isActive, data.roles ?? []);
  }
}
```

---

### 8. Auth Feature — Application (Handler)

#### [NEW] `app/features/auth/application/auth_handler.ts`
```typescript
import { redirect, data } from 'react-router';
import { container } from '~/core/di/container';
import { Tokens } from '~/core/di/tokens';
import type { IAuthRepository } from '../domain/repositories/i_auth_repository';
import {
  getSession,
  sessionStorage,
  requireAuth,
  destroySession,
} from '~/core/auth/session.server';
import { InvalidOtpError } from '../domain/errors';

function getRepo(): IAuthRepository {
  return container.resolve<IAuthRepository>(Tokens.IAuthRepository);
}

export async function handleRequestOtp(request: Request) {
  const form = await request.formData();
  const phoneNumber = form.get('phoneNumber') as string;

  try {
    await getRepo().requestOtp(phoneNumber);
    return data({ success: true, phoneNumber });
  } catch {
    return data({ error: 'Failed to send OTP. Check the number and try again.' }, { status: 400 });
  }
}

export async function handleVerifyOtp(request: Request) {
  const form = await request.formData();
  const phoneNumber = form.get('phoneNumber') as string;
  const code = form.get('code') as string;

  try {
    const result = await getRepo().verifyOtp(phoneNumber, code);
    const session = await getSession(request);

    session.set('accessToken', result.accessToken);
    session.set('refreshToken', result.refreshToken);
    session.set('userId', result.user.id);
    session.set('phoneNumber', result.user.phoneNumber);
    session.set('roles', result.user.roles);

    return redirect('/', {
      headers: { 'Set-Cookie': await sessionStorage.commitSession(session) },
    });
  } catch (e) {
    if (e instanceof InvalidOtpError) {
      return data({ error: 'Invalid OTP. Please try again.' }, { status: 401 });
    }
    return data({ error: 'Something went wrong.' }, { status: 500 });
  }
}

export async function handleLogout(request: Request) {
  const session = await requireAuth(request);
  try {
    await getRepo().logout(session.accessToken, session.refreshToken);
  } catch { /* still destroy session */ }

  return redirect('/login', {
    headers: { 'Set-Cookie': await destroySession(request) },
  });
}

export async function loadProtectedUser(request: Request) {
  return requireAuth(request); // throws redirect('/login') if unauthenticated
}
```

---

### 9. Routes

#### [MODIFY] `app/routes.ts`
```typescript
import { type RouteConfig, index, route, layout } from '@react-router/dev/routes';

export default [
  // Auth (unauthenticated shell)
  layout('routes/_auth.tsx', [
    route('login', 'routes/_auth.login.tsx'),
  ]),

  // Protected (authenticated shell)
  layout('routes/_app.tsx', [
    index('routes/_app._index.tsx'),
    route('logout', 'routes/_app.logout.tsx'),
  ]),
] satisfies RouteConfig;
```

#### [NEW] `app/routes/_auth.tsx`
Auth shell — no sidebar. Renders `<AuthLayout>`.

#### [NEW] `app/routes/_auth.login.tsx`
```typescript
// loader: redirect to / if already authed
// action: dispatches to handleRequestOtp OR handleVerifyOtp based on _step hidden field
// default: renders <LoginPage />
```

Two-step flow:
- **Step 1** form: phone number input → calls `handleRequestOtp` → returns `{ success, phoneNumber }`
- **Step 2** form: OTP code input (phone prefilled) → calls `handleVerifyOtp` → redirects to `/`

#### [NEW] `app/routes/_app.tsx`
```typescript
// loader: calls loadProtectedUser(request) — throws redirect if unauthed
// default: renders <AppLayout> with <Outlet />
```

#### [NEW] `app/routes/_app._index.tsx`
Dashboard stub — just renders a `<h1>Dashboard</h1>` for now.

#### [NEW] `app/routes/_app.logout.tsx`
```typescript
// action: calls handleLogout(request)
// No UI needed
```

---

### 10. Presentation Components

#### [NEW] `app/features/auth/presentation/pages/login_page.tsx`
Manages two-step state (`phone` | `otp`). Uses `useFetcher` to submit without navigation.

- Shows `<OtpRequestForm>` when step = phone
- Shows `<OtpVerifyForm>` when step = otp
- Reads fetcher data to advance step on success

#### [NEW] `app/features/auth/presentation/components/otp_request_form.tsx`
- Phone input (E.164 format hint)
- React Hook Form + Zod: `z.string().regex(/^\+?[1-9]\d{6,14}$/)`
- `<LoaderButton>` on submit

#### [NEW] `app/features/auth/presentation/components/otp_verify_form.tsx`
- 6-char OTP input (single input, not split)
- Hidden `phoneNumber` field
- Back button to reset step
- `<LoaderButton>` on submit

---

### 11. Shared Components

#### [NEW] `app/shared/components/loader_button.tsx`
```typescript
// Props: children, isLoading, ...ButtonProps
// When isLoading: shows spinner + disabled state
// Uses shadcn Button underneath
```

#### [NEW] `app/shared/layouts/auth_layout.tsx`
- Centers content on screen
- Applies Slate & Sinew theme: `bg-background`, Manrope brand logo top-left
- Dark/light safe

#### [NEW] `app/shared/ui/theme/theme_provider.tsx`
Wraps `next-themes` `ThemeProvider` with `attribute="class"`, `defaultTheme="system"`, `themes={['light','dark']}`.

#### [NEW] `app/shared/ui/theme/theme_script.tsx`
Inline `<script>` tag that sets the correct class before first paint (avoids SSR flash). Injected in `root.tsx` `<head>`.

#### [NEW] `app/shared/ui/theme/theme_switcher.tsx`
Icon toggle button (sun/moon). Uses `useTheme()` from `next-themes`.

---

### 12. Styling — Slate & Sinew Tokens

#### [MODIFY] `app/styles/globals.css`
- Add Tailwind `@import`
- Import font CSS
- Add base body styles (font-family: Inter, background, color)

#### [NEW] `app/styles/tokens.css`
CSS custom properties mapped from Slate & Sinew palette:

```css
/* Light mode (default) */
:root {
  --background: #f9f9f9;
  --foreground: #1a1c1c;
  --primary: #000000;
  --primary-foreground: #e5e2e1;
  --secondary: #5f5e5e;
  --secondary-foreground: #ffffff;
  --surface: #f9f9f9;
  --surface-low: #f3f3f3;
  --surface-high: #e8e8e8;
  --surface-highest: #e2e2e2;
  --muted: #eeeeee;
  --muted-foreground: #474747;
  --border: transparent; /* No-line rule */
  --radius: 0px; /* Brutalist 0px */
}

/* Dark mode */
.dark {
  --background: #131313;
  --foreground: #e5e2e1;
  --primary: #ffffff;
  --primary-foreground: #2f3131;
  --secondary: #c7c6c6;
  --secondary-foreground: #2f3131;
  --surface: #131313;
  --surface-low: #1c1b1b;
  --surface-high: #2a2a2a;
  --surface-highest: #353534;
  --muted: #201f1f;
  --muted-foreground: #c4c7c8;
  --border: transparent;
  --radius: 0px;
}
```

Map shadcn CSS variables to our tokens in `globals.css`.

---

### 13. Root Updates

#### [MODIFY] `app/root.tsx`
- Import `@fontsource/manrope` and `@fontsource/inter` weights
- Import `./styles/globals.css` and `./styles/tokens.css`  
- Wrap `<Layout>` children in `<ThemeProvider>`
- Inject `<ThemeScript>` in `<head>` before `<Links />`
- Remove Google Fonts CDN link

---

## Verification Plan

### Manual
1. `npm run dev` — app starts, no TS errors
2. Navigate to `/login` — auth layout renders, Slate & Sinew styles applied
3. Enter phone number → OTP sent (check NestJS console for `1234`)
4. Enter `1234` → redirected to `/`
5. Refresh `/` — stays logged in (session persists)
6. Navigate to `/logout` — redirected to `/login`, session cleared
7. Toggle theme — switches light/dark, persists on reload
8. Direct navigate to `/` while unauthenticated → redirected to `/login`

### TypeScript
```bash
npm run typecheck
```

---

## Open Questions for User

> [!IMPORTANT]
> **Owner role check**: Should the login handler verify the user has `roleName === 'owner'` before allowing access? Or is any authenticated user allowed in the owner portal for now?

> [!NOTE]
> **OTP input UX**: Single text input vs. split 6-box input? Single is simpler and matches brutalist aesthetic. Split is more native-feeling. Defaulting to single unless you say otherwise.
