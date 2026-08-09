import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  MaxLength,
  IsOptional,
  IsBoolean,
  ValidateNested,
  ArrayMinSize,
  ArrayMaxSize,
} from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { WeeklyPlanStatus } from '@prisma/client';
import { DayPlanInputDto, DayPlanResponseDto } from './day-plan.dto';

export class CreateWeeklyPlanDto {
  @ApiProperty({
    description: 'Name of the weekly training plan',
    example: 'Hypertrophy Cycle Phase 1',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name: string;

  @ApiPropertyOptional({
    description:
      'Optional remarks or instruction notes for the overall weekly plan',
    example: 'Ensure consistent hydration and focus on progressive overload.',
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({
    description:
      'If true, this plan becomes ACTIVE and overrides the current active plan, resetting the profile cursor to day 1.',
    default: false,
  })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  activateImmediately?: boolean = false;

  @ApiProperty({
    description: 'Exactly 7 day plans corresponding to dayIndex 1 to 7.',
    type: [DayPlanInputDto],
  })
  @ValidateNested({ each: true })
  @ArrayMinSize(0)
  @ArrayMaxSize(7)
  @Type(() => DayPlanInputDto)
  days: DayPlanInputDto[];
}

export class UpdateWeeklyPlanDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(120)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
}

export class WeeklyPlanResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  workoutProfileId: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ enum: WeeklyPlanStatus })
  status: WeeklyPlanStatus;

  @ApiProperty({ nullable: true })
  effectiveFrom: Date | null;

  @ApiProperty({ nullable: true })
  effectiveTo: Date | null;

  @ApiProperty()
  createdById: string;

  @ApiProperty({ nullable: true })
  notes: string | null;

  @ApiProperty({ type: [DayPlanResponseDto] })
  days: DayPlanResponseDto[];

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class WeeklyPlanSummaryDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ enum: WeeklyPlanStatus })
  status: WeeklyPlanStatus;

  @ApiProperty({ nullable: true })
  effectiveFrom: Date | null;

  @ApiProperty({ nullable: true })
  effectiveTo: Date | null;

  @ApiProperty()
  createdById: string;

  @ApiProperty()
  dayPlanCount: number;
}
