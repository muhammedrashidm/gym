import { ApiProperty } from '@nestjs/swagger';

export class QrTokenModel {
  @ApiProperty({
    description: 'The secure QR token generated for the staff profile',
  })
  qrToken: string;

  @ApiProperty({ description: 'The ISO timestamp when the token will expire' })
  expiresAt: Date;
}
