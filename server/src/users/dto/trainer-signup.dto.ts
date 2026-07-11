import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNotEmpty } from 'class-validator';

export class TrainerSignupDto {
  @ApiProperty({
    description: 'Full name of the trainer candidate',
    example: 'John Trainer',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'Years of experience', example: '5' })
  @IsString()
  @IsNotEmpty()
  experience: string;

  @ApiPropertyOptional({
    description: 'Short bio/philosophy',
    example: 'I focus on hypertrophy and strength',
  })
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiPropertyOptional({
    description: 'List of specializations, comma-separated or array',
    example: 'Strength,Yoga',
  })
  @IsOptional()
  specializations?: any;
}
