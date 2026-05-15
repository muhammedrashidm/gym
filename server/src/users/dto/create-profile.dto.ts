import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { ExpLevel, Sex } from 'generated/prisma/client';

export class CreateProfileDto {
  @ApiProperty({ description: 'Full display name of the member', example: 'Aisha Khan' })
  @IsString()
  fullName: string;

  @ApiPropertyOptional({ description: 'Age in years', example: 28 })
  @IsOptional()
  @IsNumber()
  age?: number;

  @ApiPropertyOptional({ description: 'Biological sex', enum: Sex })
  @IsOptional()
  @IsEnum(Sex)
  sex?: Sex;



  @ApiPropertyOptional({ description: 'URL of the profile avatar image' })
  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @ApiPropertyOptional({ description: 'Body weight in kilograms', example: 72.5 })
  @IsOptional()
  @IsNumber()
  weight?: number;

  @ApiPropertyOptional({ description: 'Height in centimetres', example: 175 })
  @IsOptional()
  @IsNumber()
  height?: number;

  @ApiPropertyOptional({ description: 'Muscle mass percentage', example: 38.2 })
  @IsOptional()
  @IsNumber()
  muscleMass?: number;

  @ApiPropertyOptional({ description: 'Body fat percentage', example: 18.5 })
  @IsOptional()
  @IsNumber()
  bodyFatPct?: number;
}
