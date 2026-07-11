import { ApiProperty } from '@nestjs/swagger';

export class BodyMetricsModel {
  @ApiProperty({ description: 'Unique identifier' })
  id: string;

  @ApiProperty({ description: 'Weight in kilograms' })
  weight: number;

  @ApiProperty({ description: 'Height in centimetres' })
  height: number;

  @ApiProperty({
    description: 'Muscle mass percentage',
    nullable: true,
    type: Number,
  })
  muscleMass: number | null;

  @ApiProperty({
    description: 'Body fat percentage',
    nullable: true,
    type: Number,
  })
  bodyFatPct: number | null;

  @ApiProperty({ description: 'When this entry was recorded' })
  recordedAt: Date;
}
