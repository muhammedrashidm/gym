import { Module } from '@nestjs/common';
import { GymController } from './gym.controller';
import { GymScopeResolver } from './gym.scope-resolver';
import { GymService } from './gym.service';

@Module({
  controllers: [GymController],
  providers: [GymService, GymScopeResolver],
})
export class GymModule {}
