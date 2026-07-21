import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';
import { ExerciseConfigController } from './controllers/exercise-config.controller';
import { ExerciseConfigService } from './services/exercise-config.service';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [ExerciseConfigController],
  providers: [ExerciseConfigService],
  // Exported so WorkoutModule's TaskService/WeeklyPlanService can inject it
  // for the exerciseConfigId existence/isActive check — same relationship
  // shape as their existing dependency on TaskMediaService.
  exports: [ExerciseConfigService],
})
export class ExerciseConfigModule {}
