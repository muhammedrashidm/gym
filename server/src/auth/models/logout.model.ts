import { ApiProperty } from '@nestjs/swagger';

export class LogoutModel {
  @ApiProperty({
    description: 'True when the refresh token was successfully revoked',
  })
  success: boolean;
}
