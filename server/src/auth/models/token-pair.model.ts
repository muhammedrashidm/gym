import { ApiProperty } from '@nestjs/swagger';

export class TokenPairModel {
  @ApiProperty({ description: 'Short-lived JWT access token' })
  accessToken: string;

  @ApiProperty({ description: 'Long-lived opaque refresh token (UUID)' })
  refreshToken: string;
}
