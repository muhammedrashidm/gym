-- CreateEnum
CREATE TYPE "SessionLogActorRole" AS ENUM ('MEMBER', 'TRAINER', 'STAFF');

-- AlterTable
ALTER TABLE "workout_profiles" ADD COLUMN     "completedCycleCount" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "workout_session_logs" ADD COLUMN     "cycleNumberAtTime" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "loggedByRole" "SessionLogActorRole",
ADD COLUMN     "loggedByUserId" TEXT;
