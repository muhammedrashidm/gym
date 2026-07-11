import { ApiProperty } from '@nestjs/swagger';

export class StaffClientConnectionModel {
  @ApiProperty()
  id: string;

  @ApiProperty()
  staffProfileId: string;

  @ApiProperty()
  clientProfileId: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  isActive: boolean;
}
