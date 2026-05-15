export const SYSTEM_ROLES = {
  MEMBER: 'member',
  STAFF: 'staff',
  OWNER: 'owner',
  ADMIN_STAFF: 'admin_staff',
  ADMIN: 'admin',
  MANAGER: 'manager',
  TRAINER: 'trainer',
  SUBSCRIBER: 'subscriber',
} as const;

export type SystemRoleName = (typeof SYSTEM_ROLES)[keyof typeof SYSTEM_ROLES];

export const ROLE_IDS = {
  [SYSTEM_ROLES.MEMBER]: 1,
  [SYSTEM_ROLES.STAFF]: 2,
  [SYSTEM_ROLES.OWNER]: 3,
  [SYSTEM_ROLES.ADMIN_STAFF]: 4,
  [SYSTEM_ROLES.ADMIN]: 5,
} as const;
