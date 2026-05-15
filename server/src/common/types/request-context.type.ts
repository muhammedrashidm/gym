import type { UserRoleClaim } from '../../auth/interfaces/auth-user.interface';

export interface GymContext {
  gymId: string;
  gymTier: number;
  isOwner: boolean;
  isStaff: boolean;
}

export interface RequestContext {
  userId: string;
  phoneNumber: string;
  roles: string[];
  roleAssignments: UserRoleClaim[];
  profileId?: string;
  gymContext?: GymContext;
  isSuperAdmin: boolean;
  isAdminStaff: boolean;
  isAdmin: boolean;
  isOwner: boolean;
  isStaff: boolean;
  isMember: boolean;
}
