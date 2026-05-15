import { ApiProperty } from '@nestjs/swagger';
import { TokenPairModel } from './token-pair.model';
import { AuthUserModel } from './auth-user.model';
import { ProfileModel } from '../../users/models/profile.model';

export class VerifyOtpResponseModel extends TokenPairModel {
  @ApiProperty({ description: 'Authenticated user summary', type: AuthUserModel })
  user: AuthUserModel;

  @ApiProperty({
    description: 'Profile that was auto-claimed for this phone number (if one existed), or null',
    type: ProfileModel,
    nullable: true,
  })
  claimedProfile: ProfileModel | null;
}
