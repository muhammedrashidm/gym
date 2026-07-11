import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

import { WorkoutProfileController } from './controllers/workout-profile.controller';
import { WeeklyPlanController } from './controllers/weekly-plan.controller';
import { DayPlanController } from './controllers/day-plan.controller';
import { TaskController } from './controllers/task.controller';
import { WorkoutSessionController } from './controllers/workout-session.controller';

import { WorkoutProfileService } from './services/workout-profile.service';
import { WeeklyPlanService } from './services/weekly-plan.service';
import { DayPlanService } from './services/day-plan.service';
import { TaskService } from './services/task.service';
import { WorkoutSessionService } from './services/workout-session.service';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [
    WorkoutProfileController,
    WeeklyPlanController,
    DayPlanController,
    TaskController,
    WorkoutSessionController,
  ],
  providers: [
    WorkoutProfileService,
    WeeklyPlanService,
    DayPlanService,
    TaskService,
    WorkoutSessionService,
  ],
  exports: [
    WorkoutProfileService,
    WeeklyPlanService,
    DayPlanService,
    TaskService,
    WorkoutSessionService,
  ],
})
export class WorkoutModule {}
