import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class OtpRequestedModel {
  @ApiProperty({
    description: 'True when the OTP was successfully queued for delivery',
  })
  success: boolean;

  @ApiPropertyOptional({
    description:
      'TEMPORARY: the plaintext OTP, returned only until OTP_ECHO_UNTIL ' +
      '(default 2026-11-10) while SMS delivery is unavailable. Remove this ' +
      'field along with the echo logic once the SMS provider is live.',
    nullable: true,
  })
  code?: string;
}
