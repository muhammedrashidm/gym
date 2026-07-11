-- DropForeignKey
ALTER TABLE "workout_profiles" DROP CONSTRAINT "workout_profiles_clientUserId_fkey";

-- AlterTable
ALTER TABLE "workout_profiles" ALTER COLUMN "clientUserId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "workout_profiles" ADD CONSTRAINT "workout_profiles_clientUserId_fkey" FOREIGN KEY ("clientUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
