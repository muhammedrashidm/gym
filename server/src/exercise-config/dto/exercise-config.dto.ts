import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsArray,
  IsEnum,
  IsObject,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { AnalyzerType } from 'generated/prisma/client';
import { PaginationQueryDto } from '../../common/dto/api-response.dto';

/** Normalise a multipart keywords field (comma-separated string or repeated
 * field) into a clean, lowercased, de-duplicated string array. Identical to
 * task-media.dto.ts's helper of the same name. */
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

/** The multipart create endpoint carries aiConfigJson as a stringified JSON
 * field (like every other text field in a multipart body) — parse it back
 * into an object. Left as-is (already an object) when the value arrives via
 * a plain JSON request body instead. */
function parseJsonField(value: unknown): unknown {
  if (typeof value !== 'string') return value;
  try {
    return JSON.parse(value);
  } catch {
    return value; // let @IsObject() reject the malformed input with a clear error
  }
}

export class CreateExerciseConfigDto {
  @ApiProperty({ description: 'Display name', example: 'Barbell Squat' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  name: string;

  @ApiPropertyOptional({ description: 'Longer description / coaching notes' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ enum: AnalyzerType })
  @IsEnum(AnalyzerType)
  analyzerType: AnalyzerType;

  @ApiPropertyOptional({
    description: 'Search keywords (comma-separated or repeated field)',
    example: 'squat,legs,barbell',
  })
  @IsOptional()
  @Transform(({ value }) => normaliseKeywords(value))
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];

  @ApiProperty({
    description:
      'Landmarks/angles/thresholds/state-machine/feedback-rules payload, ' +
      'as a JSON string in this multipart request',
    type: 'string',
  })
  @Transform(({ value }) => parseJsonField(value))
  @IsObject()
  aiConfigJson: Record<string, unknown>;
}

export class UpdateExerciseConfigDto {
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

  @ApiPropertyOptional({ enum: AnalyzerType })
  @IsOptional()
  @IsEnum(AnalyzerType)
  analyzerType?: AnalyzerType;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => normaliseKeywords(value))
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];

  @ApiPropertyOptional({ description: 'Replaces the entire JSON payload' })
  @IsOptional()
  @IsObject()
  aiConfigJson?: Record<string, unknown>;

  @ApiPropertyOptional({
    description: 'Soft-retire flag — false hides it from trainer search',
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class SearchExerciseConfigQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Free-text search over name/description/keywords',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: AnalyzerType })
  @IsOptional()
  @IsEnum(AnalyzerType)
  analyzerType?: AnalyzerType;
}

/** Lightweight shape for search results and for nesting inside
 * TaskResponseDto — deliberately omits aiConfigJson so normal plan-browsing
 * payloads stay light. */
export class ExerciseConfigSummaryDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty({ enum: AnalyzerType })
  analyzerType: AnalyzerType;

  @ApiProperty({ type: [String] })
  keywords: string[];

  @ApiProperty({ description: 'Stable, cacheable URL (PUBLIC media)' })
  mediaUrl: string;
}

/** Full shape — includes aiConfigJson. Only returned by the create/update/
 * findOne endpoints, never by search (see ExerciseConfigSummaryDto). */
export class ExerciseConfigResponseDto extends ExerciseConfigSummaryDto {
  @ApiProperty({ description: 'Landmarks/angles/thresholds/feedback-rules payload' })
  aiConfigJson: Record<string, unknown>;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  createdById: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
