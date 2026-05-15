import { Role, User, UserRole } from 'generated/prisma/client';
import { AuthUserModel } from '../models/auth-user.model';
import { UserRoleModel } from '../models/user-role.model';

type UserRoleWithRole = UserRole & { role: Role };

/**
 * Maps a Prisma User + its hydrated UserRole[] to an {@link AuthUserModel}.
 */
export function mapToAuthUserModel(
  user: Pick<User, 'id' | 'phoneNumber' | 'isActive'>,
  userRoles: UserRoleWithRole[],
): AuthUserModel {
  const model = new AuthUserModel();
  model.id = user.id;
  model.phoneNumber = user.phoneNumber;
  model.isActive = user.isActive;
  model.roles = userRoles.map((ur) => {
    const roleModel = new UserRoleModel();
    roleModel.roleId = ur.role.id;
    roleModel.roleName = ur.role.name;
    roleModel.gymId = ur.gymId ?? null;
    return roleModel;
  });
  return model;
}
