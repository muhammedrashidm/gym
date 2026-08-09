import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  Min,
  IsNumber,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { SessionLogStatus, SessionLogActorRole } from '@prisma/client';

export class TaskCompletionInputDto {
  @ApiProperty({
    description: 'The task ID that was performed',
    example: 'task-uuid',
  })
  @IsString()
  @IsNotEmpty()
  taskId: string;

  @ApiPropertyOptional({
    description: 'Actual number of sets completed',
    example: 4,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  actualSets?: number;

  @ApiPropertyOptional({
    description: 'Actual reps completed',
    example: '10, 10, 8, 8',
  })
  @IsOptional()
  @IsString()
  actualReps?: string;

  @ApiPropertyOptional({
    description: 'Actual weight lifted in kilograms',
    example: 85.5,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  actualWeightKg?: number;

  @ApiPropertyOptional({
    description: 'Feedback or logs notes for this task',
    example: 'Felt strong, could increase weight next week.',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class CompleteWorkoutSessionDto {
  @ApiPropertyOptional({
    description: 'Completed tasks metrics',
    type: [TaskCompletionInputDto],
  })
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => TaskCompletionInputDto)
  taskCompletions?: TaskCompletionInputDto[];

  @ApiPropertyOptional({
    description: 'General feedback for the workout session',
    example: 'Great energy today, shoulder felt slightly tight but no pain.',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class SkipWorkoutSessionDto {
  @ApiPropertyOptional({
    description: 'Reason for skipping the workout session',
    example: 'Sick / Travel / Rest required',
  })
  @IsOptional()
  @IsString()
  reason?: string;
}

export class TaskCompletionEntryDto {
  @ApiProperty()
  taskId: string;

  @ApiPropertyOptional({ nullable: true })
  actualSets: number | null;

  @ApiPropertyOptional({ nullable: true })
  actualReps: string | null;

  @ApiPropertyOptional({ nullable: true })
  actualWeightKg: number | null;

  @ApiPropertyOptional({ nullable: true })
  notes: string | null;
}

export class WorkoutSessionResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  workoutProfileId: string;

  @ApiProperty()
  weeklyPlanId: string;

  @ApiPropertyOptional({
    description: 'Program name (WeeklyPlan.name) at read time',
  })
  weeklyPlanName: string;

  @ApiProperty({ nullable: true })
  dayPlanId: string | null;

  @ApiPropertyOptional({
    description: 'Day label (DayPlan.label) at read time, if set',
    nullable: true,
  })
  dayPlanLabel: string | null;

  @ApiProperty({ description: 'Template day position (1..7) at log time' })
  dayIndexAtTime: number;

  @ApiProperty({
    description:
      'Which repetition of the 7-day cycle this log belongs to ("week N" of the program)',
  })
  cycleNumberAtTime: number;

  @ApiProperty({ enum: SessionLogStatus })
  status: SessionLogStatus;

  @ApiProperty({ nullable: true })
  scheduledDate: Date | null;

  @ApiProperty({ nullable: true })
  completedDate: Date | null;

  @ApiPropertyOptional({
    enum: SessionLogActorRole,
    description:
      'Who submitted this log: the client themselves, or a trainer/staff member on their behalf',
    nullable: true,
  })
  loggedByRole: SessionLogActorRole | null;

  @ApiPropertyOptional({ nullable: true })
  loggedByUserId: string | null;

  @ApiPropertyOptional({
    description:
      'The updated currentDayIndex cursor value, returned on complete-session response',
  })
  currentDayIndexAfter?: number;

  @ApiProperty({
    type: [TaskCompletionEntryDto],
    description: 'Per-exercise actuals logged for this session, if any',
  })
  taskCompletionLogs: TaskCompletionEntryDto[];
}
