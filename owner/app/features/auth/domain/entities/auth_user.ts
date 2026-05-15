import type { RoleClaim } from "./role_claim";
import { RoleType } from "../enums/role_type";

export class AuthUser {
  constructor(
    public id: string,
    public phoneNumber: string,
    public isActive: boolean,
    public roles: RoleClaim[]
  ) {}

  hasRole(roleId: RoleType): boolean {
    return this.roles.some((r) => r.roleId === roleId);
  }

  get highestRole(): RoleType | null {
    if (this.roles.length === 0) return null;
    return Math.max(...this.roles.map((r) => r.roleId)) as RoleType;
  }
}
