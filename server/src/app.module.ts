import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { MediaModule } from './media/media.module';
import { UsersModule } from './users/users.module';
import { GymModule } from './gym/gym.module';
import { WorkoutModule } from './workout/workout.module';
import { ExerciseConfigModule } from './exercise-config/exercise-config.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    MediaModule,
    UsersModule,
    GymModule,
    ExerciseConfigModule,
    WorkoutModule,
  ],
})
export class AppModule {}
