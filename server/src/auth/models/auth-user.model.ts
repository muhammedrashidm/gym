import { ApiProperty } from '@nestjs/swagger';
import { UserRoleModel } from './user-role.model';

export class AuthUserModel {
  @ApiProperty({ description: 'Unique user ID (UUID)' })
  id: string;

  @ApiProperty({ description: 'Verified phone number' })
  phoneNumber: string;

  @ApiProperty({ description: 'Whether the account is currently active' })
  isActive: boolean;

  @ApiProperty({
    description: 'All role assignments for this user',
    type: [UserRoleModel],
  })
  roles: UserRoleModel[];
}
