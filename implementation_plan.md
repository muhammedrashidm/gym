# Auth System — Backend Implementation Plan

## Stack
- **Framework:** NestJS (already scaffolded at `/server`)
- **ORM:** Prisma + PostgreSQL
- **Auth:** JWT (access) + opaque UUID (refresh, DB-stored)
- **Validation:** class-validator + class-transformer
- **Config:** @nestjs/config (.env)
- **Test OTP:** `1234` (hardcoded in dev, stubbed SMS interface for prod)

---

## Step 1 — Install Dependencies

```bash
# Prisma
npm install prisma @prisma/client
npx prisma init  # creates prisma/schema.prisma + .env

# NestJS Auth
npm install @nestjs/jwt @nestjs/passport passport passport-jwt @nestjs/config

# Validation & Types
npm install class-validator class-transformer
npm install --save-dev @types/passport-jwt
```

---

## Step 2 — Prisma Schema

**File:** `prisma/schema.prisma`

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────

enum RoleType {
  ADMIN       // system-wide superuser
  OWNER
  MANAGER
  STAFF
  TRAINER
  SUBSCRIBER
}

enum Sex          { MALE FEMALE OTHER }
enum FitnessGoal  { LOSE MAINTAIN GAIN }
enum ExpLevel     { BEGINNER INTERMEDIATE PRO }
enum PlanType     { MONTHLY ANNUAL CLASS PUNCH_CARD }
enum MembershipStatus { PAID UNPAID ACTIVE_KINETIC }

// ─────────────────────────────────────────
// IDENTITY & AUTH
// ─────────────────────────────────────────

model User {
  id            String   @id @default(uuid())
  phoneNumber   String   @unique
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())

  profile       Profile?
  roles         UserRole[]
  refreshTokens RefreshToken[]
  otpRequests   OtpRequest[]
}

model OtpRequest {
  id          String   @id @default(uuid())
  phoneNumber String
  code        String   // "1234" in dev
  expiresAt   DateTime
  verified    Boolean  @default(false)
  createdAt   DateTime @default(now())

  userId      String?
  user        User?    @relation(fields: [userId], references: [id])
}

model RefreshToken {
  id        String   @id @default(uuid())
  token     String   @unique  // random UUID, stored hashed
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  expiresAt DateTime
  isRevoked Boolean  @default(false)
  createdAt DateTime @default(now())
}

// ─────────────────────────────────────────
// USER PROFILE (Hybrid Bridge)
// ─────────────────────────────────────────

model Profile {
  id             String       @id @default(uuid())
  userId         String?      @unique
  user           User?        @relation(fields: [userId], references: [id])
  phoneNumber    String       @unique
  fullName       String
  age            Int?
  sex            Sex?
  fitnessGoal    FitnessGoal?
  expLevel       ExpLevel?
  isKinetic      Boolean      @default(false)
  isClaimed      Boolean      @default(false)
  createdById    String?      // FK to User (staff who created it)
  createdAtGymId String?      // FK to Gym
  createdAt      DateTime     @default(now())

  memberships    Membership[]
}

// ─────────────────────────────────────────
// GYM
// ─────────────────────────────────────────

model Gym {
  id        String   @id @default(uuid())
  name      String
  createdAt DateTime @default(now())

  userRoles   UserRole[]
  memberships Membership[]
}

// ─────────────────────────────────────────
// ROLES & PERMISSIONS
// ─────────────────────────────────────────

model UserRole {
  id       String   @id @default(uuid())
  userId   String
  user     User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  gymId    String?  // NULL = system-level (ADMIN only)
  gym      Gym?     @relation(fields: [gymId], references: [id])
  roleType RoleType

  @@unique([userId, gymId, roleType])  // no duplicate role per gym
}

// ─────────────────────────────────────────
// MEMBERSHIPS & BILLING
// ─────────────────────────────────────────

model Membership {
  id         String           @id @default(uuid())
  profileId  String
  profile    Profile          @relation(fields: [profileId], references: [id])
  gymId      String
  gym        Gym              @relation(fields: [gymId], references: [id])
  planType   PlanType
  status     MembershipStatus
  autoDebit  Boolean          @default(false)
  expiryDate DateTime?
  createdAt  DateTime         @default(now())
}
```

---

## Step 3 — Environment Config

**File:** `.env`
```env
DATABASE_URL="postgresql://user:pass@localhost:5432/gymdb"
JWT_SECRET="super-secret-change-in-prod"
JWT_EXPIRES_IN="15m"
REFRESH_TOKEN_EXPIRES_DAYS=30
NODE_ENV="development"
PORT=3000
```

---

## Step 4 — NestJS Module Tree

```
src/
├── main.ts                          # enable ValidationPipe, CORS
├── app.module.ts                    # root: imports ConfigModule, PrismaModule, AuthModule, UsersModule
│
├── prisma/
│   ├── prisma.module.ts             # global module
│   └── prisma.service.ts            # extends PrismaClient, onModuleInit/Destroy
│
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts           # route handlers
│   ├── auth.service.ts              # all business logic
│   │
│   ├── strategies/
│   │   ├── jwt.strategy.ts          # validates access token → injects AuthUser
│   │   └── jwt-refresh.strategy.ts  # validates refresh token header
│   │
│   ├── guards/
│   │   ├── jwt-auth.guard.ts        # protects routes with access token
│   │   ├── jwt-refresh.guard.ts     # used only on /auth/refresh
│   │   └── roles.guard.ts           # checks roles[] against @Roles() decorator
│   │
│   ├── decorators/
│   │   ├── current-user.decorator.ts  # @CurrentUser() → req.user
│   │   └── roles.decorator.ts         # @Roles(RoleType.OWNER, ...)
│   │
│   ├── dto/
│   │   ├── request-otp.dto.ts       # { phoneNumber: string }
│   │   └── verify-otp.dto.ts        # { phoneNumber: string; code: string }
│   │
│   └── interfaces/
│       └── auth-user.interface.ts   # shape injected into all guarded routes
│
└── users/
    ├── users.module.ts
    └── users.service.ts             # findById, findByPhone (used by JWT strategy)
```

---

## Step 5 — Key Interfaces & Types

**`auth/interfaces/auth-user.interface.ts`**
```ts
export interface JwtRoleClaim {
  gymId: string | null;  // null = system-level
  roleType: string;      // RoleType enum value
}

export interface AuthUser {
  id: string;
  phoneNumber: string;
  isActive: boolean;
  roles: JwtRoleClaim[];
  // profile fields NOT in JWT — fetch from DB if needed
}
```

**JWT Access Token Payload:**
```json
{
  "sub": "user-uuid",
  "phone": "+919999999999",
  "roles": [
    { "gymId": "gym-uuid-1", "roleType": "OWNER" },
    { "gymId": "gym-uuid-2", "roleType": "TRAINER" },
    { "gymId": null,         "roleType": "ADMIN" }
  ],
  "iat": 1714000000,
  "exp": 1714000900
}
```

---

## Step 6 — Auth Service Logic

### `requestOtp(phoneNumber)`
```
1. Generate OTP: "1234" in dev (NODE_ENV=development)
2. Set expiresAt = now + 10 minutes
3. Insert into OtpRequest table
4. [Stub] Call SMS provider (no-op in dev, logs OTP to console)
5. Return { success: true }  — always 200 (no phone enumeration)
```

### `verifyOtp(phoneNumber, code)`
```
1. Find latest unverified OtpRequest WHERE phoneNumber = ? AND verified = FALSE
   └── If not found or expired → throw UnauthorizedException
2. In dev: accept code = "1234" unconditionally
   In prod: compare OtpRequest.code === code
3. Mark OtpRequest.verified = TRUE
4. Find or Create User WHERE phoneNumber = ?
   ├── Found existing → use it
   └── Not found → create new User record
5. Profile Claiming (atomic):
   Query: profiles WHERE phoneNumber = ? AND isClaimed = FALSE
   ├── Found unclaimed profile:
   │     UPDATE profile SET userId = user.id, isClaimed = TRUE
   │     INSERT UserRole(userId, gymId = profile.createdAtGymId, SUBSCRIBER)
   │     (only if that role doesn't already exist)
   └── Not found: no-op (self-signup; profile created later via onboarding)
6. Load all UserRole[] for this user
7. Sign JWT access token (15 min)
8. Generate refresh token (random UUID), hash it, store in RefreshToken table (30 days)
9. Return:
   {
     accessToken: string,
     refreshToken: string,        // raw UUID (client stores it)
     user: { id, phoneNumber, isActive, roles },
     claimedProfile?: Profile     // non-null if step 5 found a match
   }
```

### `refresh(rawRefreshToken)`
```
1. Hash the incoming token
2. Find RefreshToken WHERE token = hash AND isRevoked = FALSE
   └── Not found or expired → throw UnauthorizedException
3. Revoke old token (isRevoked = TRUE)  — rotation
4. Re-fetch user + roles from DB
5. Issue new access JWT + new refresh token
6. Return { accessToken, refreshToken }
```

### `logout(userId, rawRefreshToken)`
```
1. Hash the incoming token
2. Set RefreshToken.isRevoked = TRUE WHERE token = hash AND userId = userId
3. Return { success: true }
```

---

## Step 7 — API Endpoints

| Method | Path | Guard | Description |
|--------|------|-------|-------------|
| `POST` | `/auth/request-otp` | None | Send OTP to phone |
| `POST` | `/auth/verify-otp` | None | Verify OTP → tokens + profile claim |
| `POST` | `/auth/refresh` | `JwtRefreshGuard` | Rotate refresh token → new pair |
| `POST` | `/auth/logout` | `JwtAuthGuard` | Revoke refresh token |
| `GET` | `/auth/me` | `JwtAuthGuard` | Returns full `AuthUser` with roles |

### Request / Response shapes

**`POST /auth/request-otp`**
```json
// Body
{ "phoneNumber": "+919999999999" }

// Response 200
{ "message": "OTP sent" }
```

**`POST /auth/verify-otp`**
```json
// Body
{ "phoneNumber": "+919999999999", "code": "1234" }

// Response 200
{
  "accessToken": "eyJ...",
  "refreshToken": "550e8400-e29b-...",
  "user": {
    "id": "uuid",
    "phoneNumber": "+919999999999",
    "isActive": true,
    "roles": [{ "gymId": "gym-uuid", "roleType": "SUBSCRIBER" }]
  },
  "claimedProfile": null  // or Profile object
}
```

**`POST /auth/refresh`**
```json
// Header: Authorization: Bearer <refreshToken>
// Response 200
{
  "accessToken": "eyJ...",
  "refreshToken": "new-uuid..."
}
```

**`GET /auth/me`**
```json
// Header: Authorization: Bearer <accessToken>
// Response 200
{
  "id": "uuid",
  "phoneNumber": "+919999999999",
  "isActive": true,
  "roles": [
    { "gymId": "gym-uuid", "roleType": "OWNER" },
    { "gymId": null, "roleType": "ADMIN" }
  ]
}
```

---

## Step 8 — Strategies, Guards & Decorators

This section contains the full implementation code for all Passport strategies, all three guards, and the supporting decorators.

---

### 8A — Passport Strategies

#### `auth/strategies/jwt.strategy.ts` — Access Token

```ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../../users/users.service';
import { AuthUser } from '../interfaces/auth-user.interface';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    config: ConfigService,
    private usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('JWT_SECRET'),
    });
  }

  // Called automatically after token signature is verified.
  // Whatever is returned here becomes req.user.
  async validate(payload: any): Promise<AuthUser> {
    const user = await this.usersService.findById(payload.sub);
    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }
    return {
      id: user.id,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      roles: payload.roles,   // roles array from JWT — no extra DB hit
    };
  }
}
```

#### `auth/strategies/jwt-refresh.strategy.ts` — Refresh Token

```ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

// The refresh token is an opaque UUID, NOT a JWT.
// We use a separate named strategy ('jwt-refresh') that just
// extracts the Bearer token string and attaches it raw to req.user.
// The actual DB validation (isRevoked, expiry) happens in AuthService.refresh().

@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(config: ConfigService) {
    super({
      // Extract raw Bearer token from Authorization header
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      // We do NOT verify a JWT signature here — the token is opaque.
      // Pass secretOrKey as any non-empty string to satisfy passport-jwt;
      // set ignoreExpiration = true so passport doesn't try to parse it as JWT.
      secretOrKey: config.get<string>('JWT_SECRET'),
      ignoreExpiration: true,
      passReqToCallback: true,
    });
  }

  // payload will be the raw string if the token isn't a valid JWT,
  // but since we set ignoreExpiration & aren't checking signature properly,
  // we instead extract the raw token from the request directly.
  async validate(req: Request, _payload: any): Promise<{ refreshToken: string }> {
    const authHeader = req.headers.authorization ?? '';
    const rawToken = authHeader.replace('Bearer ', '').trim();
    if (!rawToken) throw new UnauthorizedException('Refresh token missing');
    // Attach only the raw token — AuthService.refresh() does the real DB check
    return { refreshToken: rawToken };
  }
}
```

> **Note:** Because the refresh token is a plain UUID (not a signed JWT), we use `ignoreExpiration: true` and bypass Passport's JWT parsing. The real expiry + revocation check is done in `AuthService.refresh()` against the DB.

---

### 8B — Guards

#### `auth/guards/jwt-auth.guard.ts` — Protects with Access Token

```ts
import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    // Allow routes decorated with @Public() to skip this guard
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    return super.canActivate(context);
  }

  // Override to customise the error message
  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw err ?? new UnauthorizedException('Invalid or expired access token');
    }
    return user;  // becomes req.user (AuthUser)
  }
}
```

#### `auth/guards/jwt-refresh.guard.ts` — Protects `/auth/refresh` Only

```ts
import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtRefreshGuard extends AuthGuard('jwt-refresh') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw err ?? new UnauthorizedException('Invalid refresh token');
    }
    // user = { refreshToken: string } as set by JwtRefreshStrategy.validate()
    return user;
  }
}
```

**Usage (controller):**
```ts
// Only JwtRefreshGuard here — NOT JwtAuthGuard
@UseGuards(JwtRefreshGuard)
@Post('refresh')
async refresh(@CurrentUser() user: { refreshToken: string }) {
  return this.authService.refresh(user.refreshToken);
}
```

#### `auth/guards/roles.guard.ts` — Gym-Scoped Role Enforcement

```ts
import {
  Injectable, CanActivate, ExecutionContext, ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { RoleType } from '@prisma/client';
import { AuthUser } from '../interfaces/auth-user.interface';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // 1. Get required roles from @Roles() decorator
    const requiredRoles = this.reflector.getAllAndOverride<RoleType[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles || requiredRoles.length === 0) return true;

    const request = context.switchToHttp().getRequest();
    const user: AuthUser = request.user;

    // 2. ADMIN bypasses everything
    const isAdmin = user.roles.some(
      (r) => r.roleType === RoleType.ADMIN && r.gymId === null,
    );
    if (isAdmin) return true;

    // 3. Extract gym context:
    //    Priority: route param :gymId → header X-Gym-Context
    const gymId: string | undefined =
      request.params?.gymId ?? request.headers['x-gym-context'];

    // 4. Check if user has a required role for this gym
    const hasRole = user.roles.some((r) => {
      const gymMatch = gymId ? r.gymId === gymId : true;
      const roleMatch = requiredRoles.includes(r.roleType as RoleType);
      return gymMatch && roleMatch;
    });

    if (!hasRole) {
      throw new ForbiddenException(
        `Requires one of [${requiredRoles.join(', ')}] for gym ${gymId ?? 'any'}`,
      );
    }
    return true;
  }
}
```

**Always apply guards in this order — `JwtAuthGuard` first, then `RolesGuard`:**
```ts
@Roles(RoleType.OWNER, RoleType.MANAGER)
@UseGuards(JwtAuthGuard, RolesGuard)
@Get('gyms/:gymId/dashboard')
getDashboard(@Param('gymId') gymId: string, @CurrentUser() user: AuthUser) {}
```

---

### 8C — Decorators

#### `auth/decorators/current-user.decorator.ts`
```ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthUser } from '../interfaces/auth-user.interface';

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
```

#### `auth/decorators/roles.decorator.ts`
```ts
import { SetMetadata } from '@nestjs/common';
import { RoleType } from '@prisma/client';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: RoleType[]) => SetMetadata(ROLES_KEY, roles);
```

#### `auth/decorators/public.decorator.ts`
```ts
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
// Use on routes that should bypass JwtAuthGuard entirely
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
```

**Usage:**
```ts
@Public()
@Post('request-otp')
requestOtp(@Body() dto: RequestOtpDto) { ... }

@Public()
@Post('verify-otp')
verifyOtp(@Body() dto: VerifyOtpDto) { ... }
```

---

### 8D — Guard Decision Map

```
Incoming request
       │
       ▼
  @Public()? ──YES──► Allow (no token needed)
       │NO
       ▼
  JwtAuthGuard
  (passport 'jwt')
       │
  Token valid? ──NO──► 401 Unauthorized
       │YES
       ▼
  req.user = AuthUser
       │
  @Roles() set? ──NO──► Allow
       │YES
       ▼
  RolesGuard
       │
  user.roles has ADMIN? ──YES──► Allow (bypass)
       │NO
       ▼
  Extract gymId from :gymId param
  or X-Gym-Context header
       │
  Role match found? ──NO──► 403 Forbidden
       │YES
       ▼
       Allow

──────────── Separate flow ────────────

POST /auth/refresh only:
  JwtRefreshGuard
  (passport 'jwt-refresh')
       │
  Bearer token present? ──NO──► 401
       │YES
       ▼
  req.user = { refreshToken: string }
       │
  AuthService.refresh() checks DB
  (isRevoked, expiresAt)
       │
  Invalid/revoked? ──YES──► 401
       │NO
       ▼
  Rotate tokens → return new pair
```

> New roles can be added by appending to the `RoleType` enum in `schema.prisma` and running `prisma migrate`. No guard code changes required.

---

## Step 9 — Global Setup (`main.ts`)

```ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,       // strips unknown fields
    forbidNonWhitelisted: true,
    transform: true,
  }));

  app.enableCors({
    origin: ['http://localhost:5173'], // owner web dev
    credentials: true,
  });

  app.setGlobalPrefix('api/v1');

  await app.listen(process.env.PORT ?? 3000);
}
```

---

## Open Questions

> [!IMPORTANT]
> **Q1: Database** — Do you have a PostgreSQL instance running locally, or should we add a `docker-compose.yml` with a Postgres container? This is needed before running `prisma migrate dev`.

> [!IMPORTANT]
> **Q2: Refresh token transport** — Should the refresh token be returned in the JSON body (client stores it in secure storage), or set as an `httpOnly` cookie by the server? Cookie is better for the web owner app; body is better for Flutter. We can support both via a `?client=web|mobile` flag.

> [!NOTE]
> **Q3: OTP expiry** — 10 minutes is the default. Is that acceptable, or do you want a shorter window (e.g., 5 minutes)?

> [!NOTE]
> **Q4: Gym seeding** — The `UserRole` table needs at least one `Gym` record to exist before assigning roles. Should we create a `prisma/seed.ts` that seeds a default gym + admin user?

---

## Verification Checklist

```
[ ] prisma migrate dev --name init  → migrations apply cleanly
[ ] POST /auth/request-otp          → 200, OTP logged to console
[ ] POST /auth/verify-otp (1234)    → 200, tokens returned
[ ] POST /auth/verify-otp (wrong)   → 401
[ ] GET  /auth/me (valid JWT)       → 200, user + roles
[ ] GET  /auth/me (expired JWT)     → 401
[ ] POST /auth/refresh              → 200, new token pair; old refresh revoked
[ ] POST /auth/refresh (reuse old)  → 401 (rotation enforced)
[ ] POST /auth/logout               → 200; refresh token unusable after
[ ] Profile claim: pre-seed unclaimed profile, verify-otp → claimedProfile non-null
[ ] RolesGuard: OWNER can hit /gyms/:gymId → 200
[ ] RolesGuard: SUBSCRIBER hits owner route → 403
[ ] ADMIN role: hits any gym route → 200 (bypass)
```
