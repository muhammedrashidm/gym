import { RoleType } from "../enums/role_type";

export class RoleClaim {
  constructor(
    public roleId: RoleType,
    public roleName: string,
    public gymId: string | null
  ) {}
}
