import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsInt,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { PaginationQueryDto } from '../../common/dto/api-response.dto';

export class CreateWorkoutProfileDto {
  @ApiProperty({
    description: 'The profile ID of the client (refers to Profile)',
    example: 'client-profile-uuid',
  })
  @IsString()
  @IsNotEmpty()
  clientProfileId: string;

  @ApiPropertyOptional({
    description: 'The staff profile ID of the trainer (refers to StaffProfile)',
    example: 'staff-profile-uuid',
  })
  @IsString()
  @IsOptional()
  trainerProfileId?: string;

  @ApiPropertyOptional({
    description:
      'Name of the workout profile (ignored by server, accepted for compatibility)',
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({
    description:
      'Start date of the workout profile (ignored by server, accepted for compatibility)',
  })
  @IsString()
  @IsOptional()
  startDate?: string;
}

export class WorkoutProfileResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ nullable: true })
  clientUserId: string | null;

  @ApiProperty()
  clientProfileId: string;

  @ApiProperty()
  trainerUserId: string;

  @ApiProperty()
  trainerProfileId: string;

  @ApiProperty({ nullable: true })
  activeWeeklyPlanId: string | null;

  @ApiProperty()
  currentDayIndex: number;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  isDeleted: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class WorkoutProfileQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Filter profiles by client profile ID',
  })
  @IsString()
  @IsOptional()
  clientProfileId?: string;
}

export class UpdateWorkoutProfileDto {
  @ApiPropertyOptional({
    description: 'Toggle whether this profile is active',
  })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  isActive?: boolean;

  @ApiPropertyOptional({
    description: 'Advance or change current day index cursor (1..7)',
  })
  @IsInt()
  @IsOptional()
  currentDayIndex?: number;
}
