# Gym Management App - Clean Architecture Guide

**Design Principle**: Start simple, extend easily. No breaking changes when adding complexity.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Folder Structure (Simple → Complex)](#folder-structure-simple--complex)
3. [Core Patterns](#core-patterns)
4. [Extension Points](#extension-points)
5. [Phase 1: MVP (Simplified)](#phase-1-mvp-simplified)
6. [Phase 2: Growth (Adding Complexity)](#phase-2-growth-adding-complexity)
7. [Phase 3: Scale (Full Clean Architecture)](#phase-3-scale-full-clean-architecture)
8. [Best Practices & Patterns](#best-practices--patterns)
9. [Migration Without Breaking](#migration-without-breaking)

---

## Architecture Overview

### Layered Architecture (Clean Architecture)

```
┌─────────────────────────────────────────────┐
│     PRESENTATION LAYER (React UI)           │
│  - Pages, Components, Hooks                 │
│  - Consumes loaders/actions                 │
│  - Never calls API directly                 │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  APPLICATION LAYER (Remix Loaders/Actions)  │
│  - Orchestration logic                      │
│  - Request/response handling                │
│  - Error transformation                     │
│  [EXTENSION POINT 1: Add Use Cases here]    │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│      DOMAIN LAYER (Business Logic)          │
│  - Entities, Value Objects                  │
│  - Repository interfaces                    │
│  - Business rules                           │
│  [EXTENSION POINT 2: Add Use Cases here]    │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│   INFRASTRUCTURE LAYER (Implementation)     │
│  - Repository implementations               │
│  - Data mappers (optional)                  │
│  - External service adapters                │
│  [EXTENSION POINT 3: Add mappers here]      │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│     DATA SOURCES LAYER (API/DB)             │
│  - GraphQL/REST operations                  │
│  - DTOs (Data Transfer Objects)             │
│  [EXTENSION POINT 4: Add read/write split]  │
└─────────────────────────────────────────────┘
```

### Dependency Rule

**"Dependencies always point inward"**

```
Presentation → Application → Domain ← Infrastructure
                              ↑
                          (both depend)
                              ↓
                          Data Sources
```

- **Domain** has ZERO external dependencies
- **Infrastructure** implements domain contracts
- **Application** orchestrates domain
- **Presentation** consumes application output

---

## Folder Structure (Simple → Complex)

### Phase 1: MVP (SIMPLE)

```
gym-app/
├── app/
│   ├── core/                           # Shared infrastructure
│   │   ├── auth/                       # Auth context + hooks
│   │   ├── config/                     # App config
│   │   ├── hooks/                      # Global hooks
│   │   ├── constants.ts
│   │   └── types.ts
│   │
│   ├── datasources/                    # API Layer
│   │   └── api.ts                      # Single API client
│   │
│   ├── features/                       # Feature modules (bounded contexts)
│   │   ├── gym/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── pages/
│   │   │   ├── services.ts             # Business logic (inline)
│   │   │   └── types.ts
│   │   │
│   │   ├── auth/
│   │   ├── tickets/
│   │   ├── payments/
│   │   └── reports/
│   │
│   ├── shared/
│   │   ├── components/
│   │   ├── layouts/
│   │   └── ui/
│   │
│   ├── routes/
│   │   ├── root.tsx
│   │   ├── home.tsx
│   │   └── [feature]_routes/
│   │
│   ├── root.tsx
│   └── entry.*.tsx
│
├── vite.config.ts
├── react-router.config.ts
├── tsconfig.json
└── package.json
```

**Key Characteristic**: Business logic lives in `services.ts` inside features.

---

### Phase 2: GROWTH (MEDIUM COMPLEXITY)

When you need better organization, add domain + infrastructure folders:

```
gym-app/
├── app/
│   ├── core/                           # Shared infrastructure
│   │   ├── di/                         # [NEW] Dependency injection
│   │   │   └── container.ts            # DI setup
│   │   ├── auth/
│   │   ├── config/
│   │   └── hooks/
│   │
│   ├── datasources/                    # API Layer
│   │   └── api_datasource/             # [NEW] Organized
│   │       ├── api.ts
│   │       ├── models/                 # DTOs
│   │       └── queries/                # GraphQL/REST queries
│   │
│   ├── features/                       # Feature modules (bounded contexts)
│   │   ├── gym/
│   │   │   ├── domain/                 # [NEW] Domain layer
│   │   │   │   ├── entities/
│   │   │   │   │   └── gym.ts          # Pure business object
│   │   │   │   ├── repositories/
│   │   │   │   │   └── i_gym_repository.ts  # Interface (contract)
│   │   │   │   └── errors.ts           # Domain errors
│   │   │   │
│   │   │   ├── infrastructure/         # [NEW] Implementation
│   │   │   │   └── repositories/
│   │   │   │       └── gym_repository.ts    # Implementation
│   │   │   │
│   │   │   ├── application/            # [NEW] Handlers (was inline)
│   │   │   │   └── gym_handler.ts
│   │   │   │
│   │   │   ├── presentation/           # UI components
│   │   │   │   ├── components/
│   │   │   │   ├── hooks/
│   │   │   │   └── pages/
│   │   │   │
│   │   │   └── types.ts                # Feature-specific types
│   │   │
│   │   ├── auth/
│   │   ├── tickets/
│   │   ├── payments/
│   │   └── reports/
│   │
│   ├── shared/
│   ├── routes/
│   └── [entry files]
│
└── [config files]
```

**Key Characteristic**: Folder structure reflects Clean Architecture but still simple per-feature.

---

### Phase 3: SCALE (FULL ARCHITECTURE)

When you have 10+ features, add advanced patterns:

```
gym-app/
├── app/
│   ├── core/
│   │   ├── di/
│   │   │   ├── container.ts
│   │   │   └── injection_token.ts      # [NEW] Token registry
│   │   ├── auth/
│   │   ├── config/
│   │   └── hooks/
│   │
│   ├── datasources/
│   │   └── api_datasource/
│   │       ├── api.ts
│   │       ├── models/
│   │       └── queries/
│   │
│   ├── features/
│   │   ├── gym/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   ├── usecases/           # [NEW] Use cases (commands/queries)
│   │   │   │   │   ├── command/
│   │   │   │   │   │   ├── create_gym_command.ts
│   │   │   │   │   │   ├── update_gym_command.ts
│   │   │   │   │   │   └── approve_gym_command.ts
│   │   │   │   │   └── query/
│   │   │   │   │       ├── get_gym_query.ts
│   │   │   │   │       └── list_gyms_query.ts
│   │   │   │   └── errors.ts
│   │   │   │
│   │   │   ├── infrastructure/
│   │   │   │   ├── repositories/
│   │   │   │   └── mappers/            # [NEW] DTO ↔ Entity conversion
│   │   │   │       └── gym_mapper.ts
│   │   │   │
│   │   │   ├── application/
│   │   │   │   └── gym_handler.ts
│   │   │   │
│   │   │   ├── presentation/
│   │   │   │   ├── components/
│   │   │   │   ├── hooks/
│   │   │   │   └── pages/
│   │   │   │
│   │   │   └── types.ts
│   │   │
│   │   ├── [other features]
│   │
│   ├── shared/
│   ├── routes/
│   └── [entry files]
│
└── [config files]
```

**Key Characteristic**: All Clean Architecture patterns from Raithu are now in place.

---

## Core Patterns

### Pattern 1: Domain Entity (Pure Business Object)

```typescript
// app/features/gym/domain/entities/gym.ts
// ✅ NO imports from infrastructure, datasources, or presentation

export enum GymStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  SUSPENDED = 'suspended',
}

export class Gym {
  constructor(
    public id: string,
    public name: string,
    public address: string,
    public ownerName: string,
    public status: GymStatus,
    public createdAt: Date,
    public updatedAt: Date
  ) {}

  // Pure business logic
  canBeApproved(): boolean {
    return this.status === GymStatus.PENDING;
  }

  approve(): Gym {
    if (!this.canBeApproved()) {
      throw new Error('Gym cannot be approved in current status');
    }
    return new Gym(
      this.id,
      this.name,
      this.address,
      this.ownerName,
      GymStatus.APPROVED,
      this.createdAt,
      new Date()
    );
  }

  reject(reason: string): Gym {
    if (this.status !== GymStatus.PENDING) {
      throw new Error('Only pending gyms can be rejected');
    }
    return new Gym(
      this.id,
      this.name,
      this.address,
      this.ownerName,
      GymStatus.REJECTED,
      this.createdAt,
      new Date()
    );
  }
}
```

---

### Pattern 2: Repository Interface (Contract)

```typescript
// app/features/gym/domain/repositories/i_gym_repository.ts
// ✅ Interface only - NO implementation details

import { Gym } from '../entities/gym';
import type { AuthToken } from '~/features/auth/domain/entities/auth_token';

export interface IGymnRepository {
  // Queries (read)
  getList(filters?: GymFilters): Promise<Gym[]>;
  getById(id: string): Promise<Gym | null>;
  getByOwnerId(ownerId: string): Promise<Gym[]>;
  
  // Commands (write)
  create(input: CreateGymInput): Promise<Gym>;
  update(id: string, input: UpdateGymInput): Promise<Gym>;
  delete(id: string): Promise<boolean>;
}

export interface GymFilters {
  status?: string;
  ownerId?: string;
  search?: string;
  limit?: number;
  offset?: number;
}

export interface CreateGymInput {
  name: string;
  address: string;
  ownerName: string;
}

export interface UpdateGymInput extends Partial<CreateGymInput> {
  status?: string;
}
```

---

### Pattern 3: Handler (Application Layer - Remix)

**Phase 1 (Simple):**
```typescript
// app/features/gym/services.ts
// Business logic inline in features

export async function listGyms(authToken: string) {
  const response = await fetch('/api/gyms', {
    headers: { Authorization: `Bearer ${authToken}` },
  });
  return response.json();
}

export async function createGym(data: CreateGymInput, authToken: string) {
  const response = await fetch('/api/gyms', {
    method: 'POST',
    headers: { Authorization: `Bearer ${authToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}
```

**Phase 2+ (Structured):**
```typescript
// app/features/gym/application/gym_handler.ts
// Handlers orchestrate repositories (always present)

import { LoaderFunctionArgs, ActionFunctionArgs, json } from 'react-router';
import { getAuthSession } from '~/features/auth/application/auth_session';
import type { IGymnRepository } from '../domain/repositories/i_gym_repository';
import type { CreateGymInput, GymFilters } from '../domain/repositories/i_gym_repository';
import { container } from 'tsyringe';
import { InjectionToken } from '~/core/di/injection_token';

export class GymHandler {
  constructor(
    private repo: IGymnRepository = container.resolve<IGymnRepository>(
      InjectionToken.IGymnRepository
    )
  ) {}

  async listGyms(request: Request, filters?: GymFilters) {
    const authSession = await getAuthSession(request);
    const gyms = await this.repo.getList(filters);
    return json({ gyms, user: authSession.user });
  }

  async createGym(request: Request) {
    const authSession = await getAuthSession(request);
    const formData = await request.formData();

    const input: CreateGymInput = {
      name: formData.get('name') as string,
      address: formData.get('address') as string,
      ownerName: formData.get('ownerName') as string,
    };

    const gym = await this.repo.create(input);
    return json({ gym, success: true });
  }

  async approveGym(gymId: string, request: Request) {
    const authSession = await getAuthSession(request);
    
    // Fetch gym
    const gym = await this.repo.getById(gymId);
    if (!gym) throw new Response('Not Found', { status: 404 });

    // Apply business logic
    const approvedGym = gym.approve();

    // Persist
    await this.repo.update(gymId, { status: approvedGym.status });

    return json({ gym: approvedGym, success: true });
  }
}
```

---

### Pattern 4: Repository Implementation (Infrastructure)

**Phase 1 (Simple):**
```typescript
// app/features/gym/infrastructure/repositories/gym_repository.ts (Phase 1)

import { api } from '~/datasources/api';
import type { IGymnRepository, CreateGymInput, GymFilters } from '../../domain/repositories/i_gym_repository';
import { Gym } from '../../domain/entities/gym';

export class GymRepository implements IGymnRepository {
  async getList(filters?: GymFilters): Promise<Gym[]> {
    const response = await api.getGyms(filters);
    // Phase 1: Direct mapping (no separate mapper)
    return response.data.map(dto => new Gym(
      dto.id,
      dto.name,
      dto.address,
      dto.ownerName,
      dto.status,
      new Date(dto.createdAt),
      new Date(dto.updatedAt)
    ));
  }

  async create(input: CreateGymInput): Promise<Gym> {
    const response = await api.createGym(input);
    const dto = response.data;
    return new Gym(
      dto.id,
      dto.name,
      dto.address,
      dto.ownerName,
      dto.status,
      new Date(dto.createdAt),
      new Date(dto.updatedAt)
    );
  }
}
```

**Phase 2+ (With Mappers):**
```typescript
// app/features/gym/infrastructure/repositories/gym_repository.ts (Phase 2+)

import { api } from '~/datasources/api_datasource/api';
import type { IGymnRepository, CreateGymInput } from '../../domain/repositories/i_gym_repository';
import { Gym } from '../../domain/entities/gym';
import { GymMapper } from '../mappers/gym_mapper';

export class GymRepository implements IGymnRepository {
  async getList(filters?: any): Promise<Gym[]> {
    const response = await api.getGyms(filters);
    // Use mapper for clean separation
    return response.data.map(dto => GymMapper.toDomain(dto));
  }

  async create(input: CreateGymInput): Promise<Gym> {
    const response = await api.createGym(input);
    return GymMapper.toDomain(response.data);
  }
}
```

---

### Pattern 5: Mapper (Infrastructure - Optional)

Add **only in Phase 2+** when you have complex DTO ↔ Entity transformations.

```typescript
// app/features/gym/infrastructure/mappers/gym_mapper.ts
// [EXTENSION POINT 3]: Add this file when transformations get complex

import { Gym, GymStatus } from '../../domain/entities/gym';
import type { GymDTO } from '~/datasources/api_datasource/models/gym.model';

export class GymMapper {
  static toDomain(dto: GymDTO): Gym {
    // Transform DTO to domain entity
    // Normalize statuses, dates, enums, etc.
    return new Gym(
      dto.id,
      dto.name,
      dto.address,
      dto.ownerName,
      this.mapStatus(dto.status),
      new Date(dto.createdAt),
      new Date(dto.updatedAt)
    );
  }

  static toDTO(domain: Gym): GymDTO {
    // Transform domain entity to DTO
    return {
      id: domain.id,
      name: domain.name,
      address: domain.address,
      ownerName: domain.ownerName,
      status: domain.status,
      createdAt: domain.createdAt.toISOString(),
      updatedAt: domain.updatedAt.toISOString(),
    };
  }

  private static mapStatus(status: string): GymStatus {
    const map: Record<string, GymStatus> = {
      'pending_approval': GymStatus.PENDING,
      'approved': GymStatus.APPROVED,
      'rejected_status': GymStatus.REJECTED,
    };
    return map[status] || GymStatus.PENDING;
  }
}
```

---

### Pattern 6: Use Cases (Optional - Phase 3)

Add **only in Phase 3** when you have complex orchestration logic.

```typescript
// app/features/gym/domain/usecases/command/approve_gym_command.ts
// [EXTENSION POINT 2]: Add this file when logic gets complex

import { container } from 'tsyringe';
import { InjectionToken } from '~/core/di/injection_token';
import type { IGymnRepository } from '../../repositories/i_gym_repository';
import { Gym } from '../../entities/gym';

export class ApproveGymCommand {
  constructor(
    private repo: IGymnRepository = container.resolve<IGymnRepository>(
      InjectionToken.IGymnRepository
    )
  ) {}

  async execute(gymId: string): Promise<Gym> {
    // Fetch gym
    const gym = await this.repo.getById(gymId);
    if (!gym) throw new Error('Gym not found');

    // Apply business logic
    const approvedGym = gym.approve();

    // Persist
    const updated = await this.repo.update(gymId, {
      status: approvedGym.status,
    });

    return updated;
  }
}
```

---

## Extension Points

Here's where to add complexity **without breaking existing code**:

### Extension Point 1: Business Logic Location

**Phase 1**: Inside feature's `services.ts`
```
features/gym/services.ts
  ├── listGyms()
  ├── createGym()
  └── approveGym()
```

**→ Phase 2**: Move to `domain/entities` + `application/handlers`
```
domain/entities/gym.ts        (business rules)
application/gym_handler.ts    (orchestration)
```

**→ Phase 3**: Extract to `domain/usecases`
```
domain/usecases/command/approve_gym_command.ts
domain/usecases/query/list_gyms_query.ts
```

✅ **No breaking changes**: Just move code around, interfaces stay the same.

---

### Extension Point 2: Data Transformation

**Phase 1**: Inline in repository
```typescript
// Direct mapping
return new Gym(dto.id, dto.name, ...);
```

**→ Phase 2+**: Extract to mapper
```typescript
// app/features/gym/infrastructure/mappers/gym_mapper.ts
return GymMapper.toDomain(dto);
```

✅ **No breaking changes**: Repository interface stays the same, implementation updates internally.

---

### Extension Point 3: Dependency Injection

**Phase 1**: None needed
```typescript
const repo = new GymRepository();
```

**→ Phase 2**: Add lightweight DI
```typescript
const repo = container.resolve<IGymnRepository>(
  InjectionToken.IGymnRepository
);
```

**→ Phase 3**: Add feature-specific DI containers
```typescript
// app/core/di/containers/gym_di.ts
container.register(InjectionToken.IGymnRepository, {
  useClass: GymRepository,
});
```

✅ **No breaking changes**: Just add DI gradually, code structure remains same.

---

### Extension Point 4: API Datasource

**Phase 1**: Single API client
```typescript
// app/datasources/api.ts
export const api = {
  getGyms: (filters) => fetch(...),
  createGym: (data) => fetch(...),
};
```

**→ Phase 2+**: Organized with models
```
datasources/api_datasource/
├── api.ts
├── models/
│   └── gym.model.ts
└── queries/
    └── gym.graphql.ts
```

✅ **No breaking changes**: Same imports, just better organized.

---

### Extension Point 5: Repository Pattern

**Phase 1**: Single repository interface
```typescript
interface IGymnRepository {
  getList(): Promise<Gym[]>;      // Query
  create(): Promise<Gym>;         // Command
  approve(): Promise<Gym>;        // Command
}
```

**→ Phase 2+**: Separate Query + Command (CQRS)
```typescript
interface IGymnQueryRepository {
  getList(): Promise<Gym[]>;
  getById(id: string): Promise<Gym | null>;
}

interface IGymnCommandRepository {
  create(): Promise<Gym>;
  approve(): Promise<Gym>;
  delete(): Promise<boolean>;
}
```

✅ **No breaking changes**: Just split interface + create two implementations, handlers update naturally.

---

## Phase 1: MVP (Simplified)

### Project Setup

```bash
# Create React Router 7 project
npm create react-router@latest gym-app -- --template vite

cd gym-app

# Add dependencies
npm install zustand react-hook-form zod @hookform/resolvers axios

# Dev dependencies
npm install -D typescript @types/react @types/react-dom @types/node
npm install -D tailwindcss postcss autoprefixer
npm install -D eslint prettier husky lint-staged
```

### Key Files

**1. Root Layout (`app/root.tsx`)**

```typescript
import { Outlet, useLoaderData } from 'react-router';
import { getAuthSession } from '~/core/auth/auth.server';
import AppLayout from '~/shared/layouts/app_layout';
import AuthLayout from '~/shared/layouts/auth_layout';
import type { LoaderFunctionArgs } from 'react-router';

export async function loader({ request }: LoaderFunctionArgs) {
  const authSession = await getAuthSession(request);
  return { user: authSession.user };
}

export default function Root() {
  const { user } = useLoaderData<typeof loader>();

  if (!user) {
    return (
      <AuthLayout>
        <Outlet />
      </AuthLayout>
    );
  }

  return (
    <AppLayout user={user}>
      <Outlet />
    </AppLayout>
  );
}
```

**2. Route Protection (`app/core/auth/route_guard.server.ts`)**

```typescript
import type { LoaderFunctionArgs } from 'react-router';
import { redirect } from 'react-router';
import { getAuthSession } from './auth.server';

export interface RouteConfig {
  allowedRoles?: string[];
  requireAuth?: boolean;
}

export async function protectRoute(
  request: Request,
  config: RouteConfig
): Promise<{ user: any; role: string } | null> {
  const authSession = await getAuthSession(request);

  if (config.requireAuth && !authSession.user) {
    return redirect('/login');
  }

  if (config.allowedRoles && !config.allowedRoles.includes(authSession.user.role)) {
    return redirect('/unauthorized');
  }

  return { user: authSession.user, role: authSession.user.role };
}
```

**3. Feature Service (`app/features/gym/services.ts`)**

```typescript
import { api } from '~/datasources/api';
import type { CreateGymInput } from './types';

export const gymService = {
  async list(filters?: any) {
    const response = await api.get('/gyms', { params: filters });
    return response.data;
  },

  async create(data: CreateGymInput) {
    const response = await api.post('/gyms', data);
    return response.data;
  },

  async getById(id: string) {
    const response = await api.get(`/gyms/${id}`);
    return response.data;
  },

  async approve(id: string) {
    const response = await api.post(`/gyms/${id}/approve`);
    return response.data;
  },
};
```

**4. Route File (`app/routes/gym/list.tsx`)**

```typescript
import { LoaderFunctionArgs, useLoaderData } from 'react-router';
import { protectRoute } from '~/core/auth/route_guard.server';
import { gymService } from '~/features/gym/services';
import GymListPage from '~/features/gym/pages/gym_list_page';

export async function loader({ request }: LoaderFunctionArgs) {
  const auth = await protectRoute(request, {
    requireAuth: true,
    allowedRoles: ['admin', 'office_staff'],
  });

  if (!auth) throw new Error('Unauthorized');

  const gyms = await gymService.list();
  return { gyms, user: auth.user };
}

export default function GymListRoute() {
  const { gyms, user } = useLoaderData<typeof loader>();
  return <GymListPage gyms={gyms} user={user} />;
}
```

**5. Component (`app/features/gym/pages/gym_list_page.tsx`)**

```typescript
import { useFetcher } from 'react-router';
import GymCard from '~/features/gym/components/gym_card';
import GymApprovalModal from '~/features/gym/components/gym_approval_modal';
import { useState } from 'react';

export default function GymListPage({ gyms, user }: any) {
  const [selectedGym, setSelectedGym] = useState(null);
  const fetcher = useFetcher();

  const handleApprove = (gymId: string) => {
    fetcher.submit({ gymId }, { method: 'post', action: '/gym/approve' });
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Gym Management</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {gyms.map((gym: any) => (
          <GymCard key={gym.id} gym={gym} onApprove={handleApprove} />
        ))}
      </div>

      {selectedGym && (
        <GymApprovalModal
          gym={selectedGym}
          onClose={() => setSelectedGym(null)}
          onApprove={handleApprove}
        />
      )}
    </div>
  );
}
```

**6. Types (`app/features/gym/types.ts`)**

```typescript
export interface Gym {
  id: string;
  name: string;
  address: string;
  ownerName: string;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: string;
  updatedAt: string;
}

export interface CreateGymInput {
  name: string;
  address: string;
  ownerName: string;
}

export interface GymFilters {
  status?: string;
  search?: string;
  limit?: number;
  offset?: number;
}
```

---

## Phase 2: Growth (Adding Complexity)

### When to Add Phase 2

- App grows to **5+ features**
- Need **better code organization**
- Teams working on **separate features**
- Want to **add testing** more easily

### Migration Steps (No Breaking Changes)

#### Step 1: Add Domain Entities

**Create file:**
```typescript
// app/features/gym/domain/entities/gym.ts

export enum GymStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export class Gym {
  constructor(
    public id: string,
    public name: string,
    public address: string,
    public ownerName: string,
    public status: GymStatus,
    public createdAt: Date,
    public updatedAt: Date
  ) {}

  canBeApproved(): boolean {
    return this.status === GymStatus.PENDING;
  }

  approve(): Gym {
    return new Gym(
      this.id,
      this.name,
      this.address,
      this.ownerName,
      GymStatus.APPROVED,
      this.createdAt,
      new Date()
    );
  }
}
```

**Update service to use entity:**
```typescript
// app/features/gym/services.ts (UPDATED)

import { Gym } from './domain/entities/gym';

export const gymService = {
  async list(filters?: any) {
    const response = await api.get('/gyms', { params: filters });
    // Map DTOs to entities
    return response.data.map(dto => new Gym(
      dto.id,
      dto.name,
      dto.address,
      dto.ownerName,
      dto.status,
      new Date(dto.createdAt),
      new Date(dto.updatedAt)
    ));
  },
  // ... rest stays the same
};
```

✅ **No breaking changes**: Component props still work the same.

---

#### Step 2: Add Repository Interface

**Create file:**
```typescript
// app/features/gym/domain/repositories/i_gym_repository.ts

import { Gym } from '../entities/gym';

export interface IGymnRepository {
  getList(filters?: any): Promise<Gym[]>;
  getById(id: string): Promise<Gym | null>;
  create(input: CreateGymInput): Promise<Gym>;
  update(id: string, input: UpdateGymInput): Promise<Gym>;
  approve(id: string): Promise<Gym>;
}
```

**Create implementation:**
```typescript
// app/features/gym/infrastructure/repositories/gym_repository.ts

import { api } from '~/datasources/api';
import { Gym } from '../../domain/entities/gym';
import { IGymnRepository } from '../../domain/repositories/i_gym_repository';

export class GymRepository implements IGymnRepository {
  async getList(filters?: any): Promise<Gym[]> {
    const response = await api.get('/gyms', { params: filters });
    return response.data.map(dto => new Gym(...));
  }

  async approve(id: string): Promise<Gym> {
    const response = await api.post(`/gyms/${id}/approve`);
    return new Gym(...);
  }
  // ... rest
}
```

**Update service to delegate:**
```typescript
// app/features/gym/services.ts (UPDATED)

import { GymRepository } from './infrastructure/repositories/gym_repository';

const gymRepository = new GymRepository();

export const gymService = {
  async list(filters?: any) {
    return gymRepository.getList(filters);
  },

  async approve(id: string) {
    return gymRepository.approve(id);
  },
  // ...
};
```

✅ **No breaking changes**: Everything else stays the same.

---

#### Step 3: Organize into Handlers

**Create file:**
```typescript
// app/features/gym/application/gym_handler.ts

import { LoaderFunctionArgs, json } from 'react-router';
import { protectRoute } from '~/core/auth/route_guard.server';
import { GymRepository } from '../infrastructure/repositories/gym_repository';

export class GymHandler {
  constructor(private repo = new GymRepository()) {}

  async listGyms(request: Request) {
    const auth = await protectRoute(request, {
      requireAuth: true,
      allowedRoles: ['admin', 'office_staff'],
    });

    if (!auth) throw new Error('Unauthorized');

    const gyms = await this.repo.getList();
    return json({ gyms, user: auth.user });
  }

  async approveGym(gymId: string, request: Request) {
    const auth = await protectRoute(request, {
      requireAuth: true,
      allowedRoles: ['admin'],
    });

    if (!auth) throw new Error('Unauthorized');

    const gym = await this.repo.approve(gymId);
    return json({ gym, success: true });
  }
}
```

**Update route to use handler:**
```typescript
// app/routes/gym/list.tsx (UPDATED)

import { GymHandler } from '~/features/gym/application/gym_handler';

const handler = new GymHandler();

export async function loader({ request }: LoaderFunctionArgs) {
  return handler.listGyms(request);
}

export async function action({ request }: ActionFunctionArgs) {
  if (request.method === 'POST') {
    const formData = await request.formData();
    return handler.approveGym(formData.get('gymId'), request);
  }
  throw new Response('Method Not Allowed', { status: 405 });
}
```

✅ **No breaking changes**: Components still work, routes still work.

---

## Phase 3: Scale (Full Clean Architecture)

### When to Add Phase 3

- App has **10+ features** or **large team**
- Need **advanced patterns** like **CQRS**
- Want **strict testing** requirements
- Need **complex data transformations**

### Add Use Cases

```typescript
// app/features/gym/domain/usecases/command/approve_gym_command.ts

import { GymRepository } from '../../infrastructure/repositories/gym_repository';
import { Gym } from '../../entities/gym';

export class ApproveGymCommand {
  constructor(private repo = new GymRepository()) {}

  async execute(gymId: string): Promise<Gym> {
    const gym = await this.repo.getById(gymId);
    if (!gym) throw new Error('Gym not found');

    const approved = gym.approve();
    await this.repo.update(gymId, { status: approved.status });

    return approved;
  }
}
```

```typescript
// app/features/gym/domain/usecases/query/list_gyms_query.ts

import { GymRepository } from '../../infrastructure/repositories/gym_repository';
import { Gym } from '../../entities/gym';

export class ListGymsQuery {
  constructor(private repo = new GymRepository()) {}

  async execute(filters?: any): Promise<Gym[]> {
    return this.repo.getList(filters);
  }
}
```

**Update handler:**
```typescript
// app/features/gym/application/gym_handler.ts (UPDATED)

import { ApproveGymCommand } from '../domain/usecases/command/approve_gym_command';
import { ListGymsQuery } from '../domain/usecases/query/list_gyms_query';

export class GymHandler {
  private listQuery = new ListGymsQuery();
  private approveCommand = new ApproveGymCommand();

  async listGyms(request: Request) {
    const gyms = await this.listQuery.execute();
    return json({ gyms });
  }

  async approveGym(gymId: string, request: Request) {
    const gym = await this.approveCommand.execute(gymId);
    return json({ gym, success: true });
  }
}
```

✅ **No breaking changes**: Routes and components stay identical.

---

## Best Practices & Patterns

### 1. Transaction Pattern (for complex writes)

```typescript
// app/features/gym/domain/services/gym_transaction.ts
// [PATTERN] Use for multi-step operations

export class GymApprovalTransaction {
  constructor(
    private gymRepo: IGymnRepository,
    private notificationService: INotificationService,
    private auditService: IAuditService
  ) {}

  async execute(gymId: string, approvedBy: string): Promise<void> {
    try {
      // Step 1: Approve gym
      const gym = await this.gymRepo.getById(gymId);
      const approved = gym.approve();
      await this.gymRepo.update(gymId, { status: approved.status });

      // Step 2: Send notification
      await this.notificationService.notify(gym.ownerName, 'Your gym has been approved!');

      // Step 3: Audit log
      await this.auditService.log({
        action: 'GYM_APPROVED',
        gymId,
        approvedBy,
        timestamp: new Date(),
      });
    } catch (error) {
      // Rollback if needed
      throw error;
    }
  }
}
```

---

### 2. Transactional Boundaries (multiple repositories)

```typescript
// app/features/payments/domain/usecases/process_payment_command.ts
// [PATTERN] When you need to coordinate multiple repositories

export class ProcessPaymentCommand {
  constructor(
    private paymentRepo: IPaymentRepository,
    private gymRepo: IGymnRepository,
    private notificationRepo: INotificationRepository
  ) {}

  async execute(paymentData: PaymentInput): Promise<Payment> {
    // All operations or none (logical transaction)
    try {
      const payment = await this.paymentRepo.create(paymentData);
      
      // Update gym's payment status
      await this.gymRepo.updatePaymentStatus(payment.gymId, 'paid');
      
      // Send notification
      await this.notificationRepo.send({
        userId: payment.userId,
        message: 'Payment processed successfully',
      });

      return payment;
    } catch (error) {
      // Notify user of failure
      throw new PaymentFailedError(error.message);
    }
  }
}
```

---

### 3. Domain Events (when things happen)

```typescript
// app/features/gym/domain/events/gym_events.ts
// [PATTERN] Emit events when domain state changes

export class GymApprovedEvent {
  constructor(
    public gymId: string,
    public gymName: string,
    public approvedAt: Date
  ) {}
}

export class Gym {
  private events: DomainEvent[] = [];

  approve(): Gym {
    if (!this.canBeApproved()) throw new Error('Cannot approve');

    const approved = new Gym(
      this.id,
      this.name,
      this.address,
      this.ownerName,
      GymStatus.APPROVED,
      this.createdAt,
      new Date()
    );

    // Emit event
    approved.events.push(
      new GymApprovedEvent(this.id, this.name, new Date())
    );

    return approved;
  }

  getDomainEvents(): DomainEvent[] {
    return this.events;
  }

  clearDomainEvents(): void {
    this.events = [];
  }
}
```

---

### 4. Specification Pattern (complex queries)

```typescript
// app/features/gym/domain/specifications/pending_gyms_spec.ts
// [PATTERN] For complex query filtering

export abstract class Specification<T> {
  abstract isSatisfiedBy(candidate: T): boolean;
}

export class PendingGymsSpecification extends Specification<Gym> {
  isSatisfiedBy(gym: Gym): boolean {
    return gym.status === GymStatus.PENDING;
  }
}

export class GymsOwnedByUserSpecification extends Specification<Gym> {
  constructor(private userId: string) {
    super();
  }

  isSatisfiedBy(gym: Gym): boolean {
    return gym.ownerId === this.userId;
  }
}

// Usage in repository
export class GymRepository {
  async listBySpecification(spec: Specification<Gym>): Promise<Gym[]> {
    const allGyms = await this.fetchAll();
    return allGyms.filter(gym => spec.isSatisfiedBy(gym));
  }
}
```

---

### 5. Value Objects (immutable domain values)

```typescript
// app/features/gym/domain/value-objects/gym_address.ts
// [PATTERN] For complex domain values with validation

export class GymAddress {
  constructor(
    public street: string,
    public city: string,
    public state: string,
    public zipCode: string
  ) {
    if (!street || !city || !state || !zipCode) {
      throw new Error('All address fields are required');
    }
  }

  equals(other: GymAddress): boolean {
    return (
      this.street === other.street &&
      this.city === other.city &&
      this.state === other.state &&
      this.zipCode === other.zipCode
    );
  }

  toString(): string {
    return `${this.street}, ${this.city}, ${this.state} ${this.zipCode}`;
  }
}

// Usage in entity
export class Gym {
  constructor(
    public id: string,
    public name: string,
    public address: GymAddress,
    // ...
  ) {}
}
```

---

### 6. Anti-Corruption Layer (external service)

```typescript
// app/features/payment/infrastructure/adapters/stripe_adapter.ts
// [PATTERN] Wrap external services so domain doesn't know about them

import Stripe from 'stripe';
import { Payment } from '../../domain/entities/payment';

export interface IPaymentGateway {
  charge(amount: number, cardToken: string): Promise<string>;
  refund(chargeId: string): Promise<boolean>;
}

export class StripePaymentGateway implements IPaymentGateway {
  private stripe = new Stripe(process.env.STRIPE_KEY);

  async charge(amount: number, cardToken: string): Promise<string> {
    const charge = await this.stripe.charges.create({
      amount: Math.round(amount * 100),
      currency: 'usd',
      source: cardToken,
    });

    return charge.id;
  }

  async refund(chargeId: string): Promise<boolean> {
    const refund = await this.stripe.refunds.create({
      charge: chargeId,
    });

    return refund.status === 'succeeded';
  }
}

// Domain only knows about interface, not Stripe
export class PaymentRepository implements IPaymentRepository {
  constructor(private gateway: IPaymentGateway) {}

  async processPayment(payment: Payment): Promise<Payment> {
    const chargeId = await this.gateway.charge(payment.amount, payment.token);
    // Domain logic continues...
    return payment;
  }
}
```

---

## Migration Without Breaking

### Key Rules for Safe Evolution

#### Rule 1: Always Keep Interfaces Stable

```typescript
// ❌ BREAKING: Removing method from interface
interface IGymnRepository {
  // getById removed - breaks all implementations!
  getList(): Promise<Gym[]>;
}

// ✅ SAFE: Adding new method
interface IGymnRepository {
  getById(id: string): Promise<Gym | null>;  // NEW
  getList(): Promise<Gym[]>;
}

// ✅ SAFE: Changing implementation only
class GymRepository implements IGymnRepository {
  // Internal implementation can change freely
  async getById(id: string): Promise<Gym | null> {
    // Use mapper here instead of inline mapping
    const dto = await api.get(`/gyms/${id}`);
    return GymMapper.toDomain(dto);  // Changed!
  }
}
```

#### Rule 2: Move Code Vertically, Not Horizontally

```typescript
// ✅ SAFE MIGRATION PATH:
// features/gym/services.ts (Phase 1)
//  ↓
// features/gym/infrastructure/repositories/gym_repository.ts (Phase 2)
//  ↓
// features/gym/domain/usecases/command/approve_gym_command.ts (Phase 3)

// ✅ Services call repositories without changing interface
// ✅ Repositories call use cases without changing interface
// ✅ Components call handlers without changing interface
```

#### Rule 3: Update Tests After Code Moves

```typescript
// When moving code from services.ts to repository.ts:

// Before:
// __tests__/gym.service.test.ts

// After:
// __tests__/infrastructure/repositories/gym.repository.test.ts

// Update imports, tests logic stays the same
```

---

## Project Checklist

### Phase 1 Setup ✅

- [ ] Create React Router 7 project
- [ ] Add core folders: `features/`, `core/`, `shared/`, `routes/`
- [ ] Setup auth with protected routes
- [ ] Create feature folders for: `gym`, `auth`, `tickets`, `payments`, `reports`
- [ ] Add `services.ts` to each feature with API calls
- [ ] Create page components
- [ ] Setup Tailwind + shadcn/ui
- [ ] Add form validation with Zod + React Hook Form

### Phase 2 Readiness 🎯

- [ ] Add domain entities for each feature
- [ ] Create repository interfaces (IgymnRepository, etc.)
- [ ] Create repository implementations
- [ ] Create handlers (gym_handler.ts, etc.)
- [ ] Move business logic out of services.ts
- [ ] Update routes to use handlers
- [ ] Add basic unit tests for entities

### Phase 3 (Future) 🚀

- [ ] Extract use cases (command/query)
- [ ] Add mappers for complex transformations
- [ ] Setup DI container with TSyringe
- [ ] Add domain events
- [ ] Setup integration tests
- [ ] Add complex patterns (transactions, specifications, etc.)

---

## Summary

This architecture lets you:

1. **Start simple** (Phase 1) → Build MVP quickly
2. **Grow cleanly** (Phase 2) → Add structure without breaking code
3. **Scale professionally** (Phase 3) → Enterprise patterns when needed

**Key principle**: Each layer is **optional until you need it**. You never refactor backward—only forward and outward.

---

**Created for**: Gym Management App (Multi-Role RBAC)  
**Framework**: React Router 7  
**Best Practices**: Clean Architecture + DDD + Transaction Patterns  
**Last Updated**: May 2026