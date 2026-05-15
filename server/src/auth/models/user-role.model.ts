import { ApiProperty } from '@nestjs/swagger';

export class UserRoleModel {
  @ApiProperty({ description: 'Numeric role ID from the roles table' })
  roleId: number;

  @ApiProperty({ description: 'Human-readable role name (e.g. member, staff, owner)' })
  roleName: string;

  @ApiProperty({ description: 'Gym this role is scoped to; null means system-wide', nullable: true, type: String })
  gymId: string | null;
}
