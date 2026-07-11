import { ApiProperty } from '@nestjs/swagger';

export class OtpRequestedModel {
  @ApiProperty({
    description: 'True when the OTP was successfully queued for delivery',
  })
  success: boolean;
}
