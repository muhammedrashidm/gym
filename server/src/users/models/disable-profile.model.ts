import { ApiProperty } from '@nestjs/swagger';

export class DisableProfileModel {
  @ApiProperty({ description: 'True when the profile was successfully deactivated' })
  success: boolean;
}
