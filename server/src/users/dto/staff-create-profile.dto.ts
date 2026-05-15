import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { CreateProfileDto } from './create-profile.dto';

export class StaffCreateProfileDto extends CreateProfileDto {
  @ApiProperty({
    description: 'Phone number of the member being registered by staff',
    example: '+919876543210',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{6,14}$/, { message: 'Invalid phone number format' })
  phoneNumber: string;
}
