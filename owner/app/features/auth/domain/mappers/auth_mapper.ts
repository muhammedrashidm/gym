import { AuthUser } from "../entities/auth_user";
import { RoleClaim } from "../entities/role_claim";
import type {
  VerifyOtpResponseDTO,
  UserRoleClaimDTO,
} from "~/datasources/api_datasource/models/auth.model";

export class AuthMapper {
  static mapRoleClaimDTOToEntity(dto: UserRoleClaimDTO): RoleClaim {
    return new RoleClaim(dto.roleId, dto.roleName, dto.gymId);
  }

  static mapAuthUserDTOToEntity(dto: VerifyOtpResponseDTO["user"]): AuthUser {
    return new AuthUser(
      dto.id,
      dto.phoneNumber,
      dto.isActive,
      dto.roles.map(AuthMapper.mapRoleClaimDTOToEntity)
    );
  }
}
