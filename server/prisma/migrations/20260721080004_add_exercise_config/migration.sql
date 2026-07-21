-- CreateEnum
CREATE TYPE "AnalyzerType" AS ENUM ('DYNAMIC_REP', 'STATIC_HOLD', 'COMPOUND_MOVEMENT', 'CARDIO_MOVEMENT');

-- AlterTable
ALTER TABLE "tasks" ADD COLUMN     "exerciseConfigId" TEXT;

-- CreateTable
CREATE TABLE "exercise_configs" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "analyzerType" "AnalyzerType" NOT NULL,
    "keywords" TEXT[],
    "mediaId" TEXT NOT NULL,
    "aiConfigJson" JSONB NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exercise_configs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "exercise_configs_mediaId_key" ON "exercise_configs"("mediaId");

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_exerciseConfigId_fkey" FOREIGN KEY ("exerciseConfigId") REFERENCES "exercise_configs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exercise_configs" ADD CONSTRAINT "exercise_configs_mediaId_fkey" FOREIGN KEY ("mediaId") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
