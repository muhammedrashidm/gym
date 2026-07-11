import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsInt,
  Min,
  Max,
  IsString,
  IsOptional,
  IsBoolean,
  ValidateNested,
  ValidateIf,
} from 'class-validator';
import { Type } from 'class-transformer';
import { TaskInputDto, TaskResponseDto } from './task.dto';

export class DayPlanInputDto {
  @ApiProperty({
    description: 'Day index within the weekly cycle (1..7)',
    example: 1,
  })
  @IsInt()
  @Min(1)
  @Max(7)
  dayIndex: number;

  @ApiPropertyOptional({
    description: 'Optional label for the day plan (e.g. Leg Day)',
    example: 'Leg Day',
  })
  @IsOptional()
  @IsString()
  label?: string;

  @ApiProperty({
    description: 'Whether this day is a programmed rest day',
    default: false,
  })
  @IsBoolean()
  isRestDay: boolean;

  @ApiPropertyOptional({
    description: 'Tasks scheduled for this day (required if not a rest day)',
    type: [TaskInputDto],
  })
  @IsOptional()
  @ValidateIf((o: DayPlanInputDto) => !o.isRestDay)
  @ValidateNested({ each: true })
  @Type(() => TaskInputDto)
  tasks?: TaskInputDto[];
}

export class UpdateDayPlanDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  label?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isRestDay?: boolean;
}

export class DayPlanResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  weeklyPlanId: string;

  @ApiProperty()
  dayIndex: number;

  @ApiProperty({ nullable: true })
  label: string | null;

  @ApiProperty()
  isRestDay: boolean;

  @ApiProperty({ type: [TaskResponseDto] })
  tasks: TaskResponseDto[];

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
