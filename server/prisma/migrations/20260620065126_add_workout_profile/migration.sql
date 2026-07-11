/*
  Warnings:

  - You are about to drop the `WorkoutPlan` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "WeeklyPlanStatus" AS ENUM ('ACTIVE', 'UPCOMING', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "TaskMediaType" AS ENUM ('IMAGE', 'GIF', 'VIDEO');

-- CreateEnum
CREATE TYPE "SessionLogStatus" AS ENUM ('SCHEDULED', 'COMPLETED', 'SKIPPED', 'PARTIAL');

-- DropForeignKey
ALTER TABLE "WorkoutPlan" DROP CONSTRAINT "WorkoutPlan_profileId_fkey";

-- DropTable
DROP TABLE "WorkoutPlan";

-- CreateTable
CREATE TABLE "workout_profiles" (
    "id" TEXT NOT NULL,
    "clientUserId" TEXT NOT NULL,
    "clientProfileId" TEXT NOT NULL,
    "trainerUserId" TEXT NOT NULL,
    "trainerProfileId" TEXT NOT NULL,
    "activeWeeklyPlanId" TEXT,
    "currentDayIndex" INTEGER NOT NULL DEFAULT 1,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workout_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_plans" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "workoutProfileId" TEXT NOT NULL,
    "status" "WeeklyPlanStatus" NOT NULL DEFAULT 'UPCOMING',
    "effectiveFrom" TIMESTAMP(3),
    "effectiveTo" TIMESTAMP(3),
    "createdById" TEXT NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "weekly_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "day_plans" (
    "id" TEXT NOT NULL,
    "weeklyPlanId" TEXT NOT NULL,
    "dayIndex" INTEGER NOT NULL,
    "label" TEXT,
    "isRestDay" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "day_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tasks" (
    "id" TEXT NOT NULL,
    "dayPlanId" TEXT NOT NULL,
    "sequenceIndex" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "machineDetails" TEXT,
    "notes" TEXT,
    "sets" INTEGER NOT NULL,
    "reps" TEXT NOT NULL,
    "restSeconds" INTEGER,
    "tempo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_media" (
    "id" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "type" "TaskMediaType" NOT NULL,
    "url" TEXT NOT NULL,
    "caption" TEXT,
    "sequenceIndex" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workout_session_logs" (
    "id" TEXT NOT NULL,
    "workoutProfileId" TEXT NOT NULL,
    "weeklyPlanId" TEXT NOT NULL,
    "dayPlanId" TEXT,
    "dayIndexAtTime" INTEGER NOT NULL,
    "scheduledDate" TIMESTAMP(3),
    "completedDate" TIMESTAMP(3),
    "status" "SessionLogStatus" NOT NULL DEFAULT 'SCHEDULED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workout_session_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_completion_logs" (
    "id" TEXT NOT NULL,
    "sessionLogId" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "actualSets" INTEGER,
    "actualReps" TEXT,
    "actualWeightKg" DOUBLE PRECISION,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_completion_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "workout_profiles_activeWeeklyPlanId_key" ON "workout_profiles"("activeWeeklyPlanId");

-- CreateIndex
CREATE INDEX "workout_profiles_trainerUserId_idx" ON "workout_profiles"("trainerUserId");

-- CreateIndex
CREATE INDEX "workout_profiles_trainerProfileId_idx" ON "workout_profiles"("trainerProfileId");

-- CreateIndex
CREATE INDEX "weekly_plans_workoutProfileId_status_idx" ON "weekly_plans"("workoutProfileId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "day_plans_weeklyPlanId_dayIndex_key" ON "day_plans"("weeklyPlanId", "dayIndex");

-- CreateIndex
CREATE UNIQUE INDEX "tasks_dayPlanId_sequenceIndex_key" ON "tasks"("dayPlanId", "sequenceIndex");

-- CreateIndex
CREATE UNIQUE INDEX "task_media_taskId_sequenceIndex_key" ON "task_media"("taskId", "sequenceIndex");

-- CreateIndex
CREATE INDEX "workout_session_logs_workoutProfileId_createdAt_idx" ON "workout_session_logs"("workoutProfileId", "createdAt");

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_activeWeeklyPlanId_fkey" FOREIGN KEY ("activeWeeklyPlanId") REFERENCES "weekly_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_clientUserId_fkey" FOREIGN KEY ("clientUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_clientProfileId_fkey" FOREIGN KEY ("clientProfileId") REFERENCES "Profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_trainerUserId_fkey" FOREIGN KEY ("trainerUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_trainerProfileId_fkey" FOREIGN KEY ("trainerProfileId") REFERENCES "StaffProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weekly_plans" ADD CONSTRAINT "weekly_plans_workoutProfileId_fkey" FOREIGN KEY ("workoutProfileId") REFERENCES "workout_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "day_plans" ADD CONSTRAINT "day_plans_weeklyPlanId_fkey" FOREIGN KEY ("weeklyPlanId") REFERENCES "weekly_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_dayPlanId_fkey" FOREIGN KEY ("dayPlanId") REFERENCES "day_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_media" ADD CONSTRAINT "task_media_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_session_logs" ADD CONSTRAINT "workout_session_logs_workoutProfileId_fkey" FOREIGN KEY ("workoutProfileId") REFERENCES "workout_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_session_logs" ADD CONSTRAINT "workout_session_logs_weeklyPlanId_fkey" FOREIGN KEY ("weeklyPlanId") REFERENCES "weekly_plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workout_session_logs" ADD CONSTRAINT "workout_session_logs_dayPlanId_fkey" FOREIGN KEY ("dayPlanId") REFERENCES "day_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_completion_logs" ADD CONSTRAINT "task_completion_logs_sessionLogId_fkey" FOREIGN KEY ("sessionLogId") REFERENCES "workout_session_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_completion_logs" ADD CONSTRAINT "task_completion_logs_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
