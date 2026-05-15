// A single role assignment embedded in the JWT payload and req.user.
// roleName is the string from the DB `roles` table, fully dynamic.
export interface UserRoleClaim {
  roleId: number;
  roleName: string;
  gymId: string | null;
}

// Injected as req.user by JwtAuthGuard after access token verification.
// Profile data is resolved into RequestContext when needed.
export interface AuthUser {
  id: string;
  phoneNumber: string;
  isActive: boolean;
  roles: UserRoleClaim[];
}
