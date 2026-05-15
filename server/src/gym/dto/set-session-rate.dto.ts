import { Type } from 'class-transformer';
import { IsNumber, Min } from 'class-validator';

export class SetSessionRateDto {
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  rate: number;
}
