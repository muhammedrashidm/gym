-- CreateEnum
CREATE TYPE "MediaVisibility" AS ENUM ('PUBLIC', 'PROTECTED');

-- Drop old TaskMedia (per-task attachment) table; feature was unused (0 rows).
-- DropForeignKey / DropTable
ALTER TABLE "task_media" DROP CONSTRAINT IF EXISTS "task_media_taskId_fkey";
DROP TABLE "task_media";

-- Drop old orphaned Media table (write-only log, 0 rows, never FK'd); recreate as "media".
DROP TABLE "Media";

-- CreateTable: media (reusable file store)
CREATE TABLE "media" (
    "id" TEXT NOT NULL,
    "storageKey" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" INTEGER,
    "visibility" "MediaVisibility" NOT NULL DEFAULT 'PUBLIC',
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "media_pkey" PRIMARY KEY ("id")
);

-- CreateTable: task_media (searchable, reusable library entry)
CREATE TABLE "task_media" (
    "id" TEXT NOT NULL,
    "mediaId" TEXT NOT NULL,
    "type" "TaskMediaType" NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "keywords" TEXT[],
    "createdById" TEXT NOT NULL,
    "isPrivate" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "task_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable: task_attachments (join Task <-> TaskMedia)
CREATE TABLE "task_attachments" (
    "id" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "taskMediaId" TEXT NOT NULL,
    "caption" TEXT,
    "sequenceIndex" INTEGER NOT NULL,
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "task_media_mediaId_key" ON "task_media"("mediaId");

-- CreateIndex
CREATE UNIQUE INDEX "task_attachments_taskId_sequenceIndex_key" ON "task_attachments"("taskId", "sequenceIndex");

-- CreateIndex
CREATE UNIQUE INDEX "task_attachments_taskId_taskMediaId_key" ON "task_attachments"("taskId", "taskMediaId");

-- AddForeignKey
ALTER TABLE "task_media" ADD CONSTRAINT "task_media_mediaId_fkey" FOREIGN KEY ("mediaId") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_attachments" ADD CONSTRAINT "task_attachments_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_attachments" ADD CONSTRAINT "task_attachments_taskMediaId_fkey" FOREIGN KEY ("taskMediaId") REFERENCES "task_media"("id") ON DELETE CASCADE ON UPDATE CASCADE;
