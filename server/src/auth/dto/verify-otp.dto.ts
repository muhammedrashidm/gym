import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({
    description: 'Phone number in E.164 or local format',
    example: '+919876543210',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{6,14}$/, { message: 'Invalid phone number format' })
  phoneNumber: string;

  @ApiProperty({
    description: '4–6 digit OTP code sent to the phone number',
    example: '1234',
    minLength: 4,
    maxLength: 6,
  })
  @IsString()
  @IsNotEmpty()
  @Length(4, 6)
  code: string;
}
