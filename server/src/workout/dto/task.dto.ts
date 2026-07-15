import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  Min,
  ValidateNested,
  IsArray,
  ArrayMinSize,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  TaskAttachmentInputDto,
  TaskAttachmentResponseDto,
} from './task-media.dto';

export class TaskInputDto {
  @ApiProperty({
    description:
      'Ordering sequence number of the task within the DayPlan (starting from 1)',
    example: 1,
  })
  @IsInt()
  @Min(1)
  sequenceIndex: number;

  @ApiProperty({
    description: 'Name of the exercise/task',
    example: 'Barbell Back Squat',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({
    description: 'Description/instructions of the exercise',
    example: 'Perform with a controlled tempo, depth below parallel.',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Specific machine configurations or pins settings',
    example: 'Squat rack safety height set to 7, safety pins on level 5.',
  })
  @IsOptional()
  @IsString()
  machineDetails?: string;

  @ApiPropertyOptional({
    description: 'Freeform notes',
    example: 'Warm up sets not included in target set count.',
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({
    description: 'Number of sets',
    example: 4,
  })
  @IsInt()
  @Min(1)
  sets: number;

  @ApiProperty({
    description:
      'Reps target (string to allow ranges or custom target descriptions)',
    example: '8-12',
  })
  @IsString()
  @IsNotEmpty()
  reps: string;

  @ApiPropertyOptional({
    description: 'Rest period in seconds between sets',
    example: 90,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  restSeconds?: number;

  @ApiPropertyOptional({
    description: 'Tempo prescription (e.g. 3-1-1)',
    example: '3-0-1-0',
  })
  @IsOptional()
  @IsString()
  tempo?: string;

  @ApiPropertyOptional({
    description:
      'References to reusable library TaskMedia items to attach to this task',
    type: [TaskAttachmentInputDto],
  })
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => TaskAttachmentInputDto)
  attachments?: TaskAttachmentInputDto[];
}

export class CreateTaskDto extends TaskInputDto {}

export class UpdateTaskDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  machineDetails?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  sets?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  reps?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  restSeconds?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  tempo?: string;
}

export class TaskResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  dayPlanId: string;

  @ApiProperty()
  sequenceIndex: number;

  @ApiProperty()
  name: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty({ nullable: true })
  machineDetails: string | null;

  @ApiProperty({ nullable: true })
  notes: string | null;

  @ApiProperty()
  sets: number;

  @ApiProperty()
  reps: string;

  @ApiProperty({ nullable: true })
  restSeconds: number | null;

  @ApiProperty({ nullable: true })
  tempo: string | null;

  @ApiProperty({ type: [TaskAttachmentResponseDto] })
  attachments: TaskAttachmentResponseDto[];

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

export class ReorderTasksDto {
  @ApiProperty({
    description: 'Array of task IDs in the new desired order',
    type: [String],
  })
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  orderedTaskIds: string[];
}
