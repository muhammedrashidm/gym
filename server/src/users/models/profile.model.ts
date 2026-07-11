import { ApiProperty } from '@nestjs/swagger';
import { BodyMetricsModel } from './body-metrics.model';
import { ExpLevel, Sex } from 'generated/prisma/client';

export class ProfileModel {
  @ApiProperty({ description: 'Unique identifier' })
  id: string;

  @ApiProperty({
    description: 'Linked user account ID',
    nullable: true,
    type: String,
  })
  userId: string | null;

  @ApiProperty({ description: 'Phone number associated with this profile' })
  phoneNumber: string;

  @ApiProperty({ description: 'Full display name' })
  fullName: string;

  @ApiProperty({ description: 'Age in years', nullable: true, type: Number })
  age: number | null;

  @ApiProperty({ description: 'Biological sex', enum: Sex, nullable: true })
  sex: Sex | null;

  @ApiProperty({
    description: 'Training experience level',
    enum: ExpLevel,
    nullable: true,
  })
  expLevel: ExpLevel | null;

  @ApiProperty({ description: 'Whether the profile is a Kinetic member' })
  isKinetic: boolean;

  @ApiProperty({
    description: 'Whether the profile has been claimed by a user account',
  })
  isClaimed: boolean;

  @ApiProperty({
    description: 'Avatar image URL',
    nullable: true,
    type: String,
  })
  avatarUrl: string | null;

  @ApiProperty({ description: 'Whether the profile is active' })
  isActive: boolean;

  @ApiProperty({ description: 'Profile creation timestamp' })
  createdAt: Date;

  @ApiProperty({
    description: 'Body metrics history for this profile',
    type: [BodyMetricsModel],
  })
  bodyMetrics: BodyMetricsModel[];
}
