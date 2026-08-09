import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsInt,
  Min,
  IsArray,
  MaxLength,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { TaskMediaType } from '@prisma/client';
import { PaginationQueryDto } from '../../common/dto/api-response.dto';

/** Normalise a multipart keywords field (comma-separated string or repeated
 * field) into a clean, lowercased, de-duplicated string array. */
function normaliseKeywords(value: unknown): string[] {
  const raw: string[] = Array.isArray(value)
    ? value.map((v) => String(v))
    : typeof value === 'string'
      ? value.split(',')
      : [];
  const cleaned = raw
    .map((k) => k.trim().toLowerCase())
    .filter((k) => k.length > 0);
  return Array.from(new Set(cleaned));
}

function toBool(value: unknown): boolean {
  return value === true || value === 'true' || value === '1';
}

export class CreateTaskMediaDto {
  @ApiProperty({ description: 'Display name of the media', example: 'Barbell Squat Demo' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  name: string;

  @ApiPropertyOptional({ description: 'Longer description / coaching notes' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Search keywords (comma-separated or repeated field)',
    example: 'squat,legs,barbell',
  })
  @IsOptional()
  @Transform(({ value }) => normaliseKeywords(value))
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];

  @ApiPropertyOptional({
    description: 'If true, hidden from other trainers’ library searches',
    default: false,
  })
  @IsOptional()
  @Transform(({ value }) => toBool(value))
  @IsBoolean()
  isPrivate?: boolean = false;
}

export class UpdateTaskMediaDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => normaliseKeywords(value))
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => toBool(value))
  @IsBoolean()
  isPrivate?: boolean;
}

export class SearchTaskMediaQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ description: 'Free-text search over name/description/keywords' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Restrict to media created by the caller' })
  @IsOptional()
  @Transform(({ value }) => toBool(value))
  @IsBoolean()
  mine?: boolean;
}

export class TaskMediaResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ enum: TaskMediaType })
  type: TaskMediaType;

  @ApiProperty()
  name: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty({ type: [String] })
  keywords: string[];

  @ApiProperty()
  isPrivate: boolean;

  @ApiProperty()
  createdById: string;

  @ApiProperty({ description: 'Freshly-resolved URL to the media file' })
  url: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}

/** Reference to a library TaskMedia item, used both by the standalone attach
 * endpoint and nested inside a Task's create payload. */
export class TaskAttachmentInputDto {
  @ApiProperty({ description: 'ID of an existing library TaskMedia item' })
  @IsString()
  @IsNotEmpty()
  taskMediaId: string;

  @ApiPropertyOptional({ description: 'Per-attachment caption override' })
  @IsOptional()
  @IsString()
  caption?: string;

  @ApiProperty({ description: 'Ordering position within the task (1..n)', example: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  sequenceIndex: number;
}

/** Body for POST /tasks/:taskId/attachments (sequenceIndex is auto-assigned). */
export class AttachTaskMediaDto {
  @ApiProperty({ description: 'ID of an existing library TaskMedia item' })
  @IsString()
  @IsNotEmpty()
  taskMediaId: string;

  @ApiPropertyOptional({ description: 'Per-attachment caption override' })
  @IsOptional()
  @IsString()
  caption?: string;
}

export class TaskAttachmentResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  taskId: string;

  @ApiProperty()
  taskMediaId: string;

  @ApiProperty({ nullable: true })
  caption: string | null;

  @ApiProperty()
  sequenceIndex: number;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty({ type: TaskMediaResponseDto })
  taskMedia: TaskMediaResponseDto;
}
