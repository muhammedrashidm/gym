import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

// Accepts plain strings — works with SYSTEM_ROLES constants OR any custom DB role name.
// Example: @Roles(SYSTEM_ROLES.OWNER, 'CUSTOM_COACH')
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
