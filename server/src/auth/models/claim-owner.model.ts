import { ApiProperty } from '@nestjs/swagger';

export class ClaimOwnerModel {
  @ApiProperty({ example: true })
  success: boolean;
}
