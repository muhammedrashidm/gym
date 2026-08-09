import {
  Inject,
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import {
  MediaVisibility,
  type Prisma,
  type Media,
  type ExerciseConfig,
} from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import {
  PUBLIC_STORAGE_SERVICE,
  type StorageService,
} from '../../media/storage/storage.interface';
import type { RequestContext } from '../../common/types/request-context.type';
import {
  CreateExerciseConfigDto,
  UpdateExerciseConfigDto,
  SearchExerciseConfigQueryDto,
  ExerciseConfigResponseDto,
  ExerciseConfigSummaryDto,
} from '../dto/exercise-config.dto';

type ExerciseConfigWithMedia = ExerciseConfig & { media: Media };

@Injectable()
export class ExerciseConfigService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(PUBLIC_STORAGE_SERVICE)
    private readonly storage: StorageService,
  ) {}

  async create(
    dto: CreateExerciseConfigDto,
    file: Express.Multer.File,
    ctx: RequestContext,
  ): Promise<ExerciseConfigResponseDto> {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    if (
      !file.mimetype.startsWith('video/') &&
      file.mimetype !== 'image/gif'
    ) {
      throw new BadRequestException(
        `Unsupported media type "${file.mimetype}" — only videos and gifs are allowed`,
      );
    }

    // Upload the file before creating DB rows. A later DB failure would leave
    // an orphaned object, which is acceptable (no partial DB state) — same
    // tradeoff TaskMediaService.create makes.
    const stored = await this.storage.upload(
      file.buffer,
      file.originalname,
      file.mimetype,
    );

    const created = await this.prisma.$transaction(async (tx) => {
      const media = await tx.media.create({
        data: {
          storageKey: stored.storageKey,
          mimeType: stored.mimeType,
          sizeBytes: stored.sizeBytes,
          createdById: ctx.userId,
          visibility: MediaVisibility.PUBLIC,
        },
      });
      return tx.exerciseConfig.create({
        data: {
          mediaId: media.id,
          name: dto.name,
          description: dto.description || null,
          analyzerType: dto.analyzerType,
          keywords: dto.keywords ?? [],
          aiConfigJson: dto.aiConfigJson as Prisma.InputJsonValue,
          createdById: ctx.userId,
        },
        include: { media: true },
      });
    });

    return this.mapToResponse(created);
  }

  async search(query: SearchExerciseConfigQueryDto) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;

    const filters: Prisma.ExerciseConfigWhereInput[] = [{ isActive: true }];

    if (query.analyzerType) {
      filters.push({ analyzerType: query.analyzerType });
    }

    if (query.search?.trim()) {
      const term = query.search.trim();
      const tokens = term
        .toLowerCase()
        .split(/\s+/)
        .filter((t) => t.length > 0);
      filters.push({
        OR: [
          { name: { contains: term, mode: 'insensitive' } },
          { description: { contains: term, mode: 'insensitive' } },
          ...(tokens.length ? [{ keywords: { hasSome: tokens } }] : []),
        ],
      });
    }

    const where: Prisma.ExerciseConfigWhereInput = { AND: filters };

    const [rows, total] = await Promise.all([
      this.prisma.exerciseConfig.findMany({
        where,
        include: { media: true },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.exerciseConfig.count({ where }),
    ]);

    const data = await Promise.all(rows.map((r) => this.mapToSummary(r)));
    return { data, meta: { total, page, pageSize } };
  }

  async findOne(id: string): Promise<ExerciseConfigResponseDto> {
    const row = await this.prisma.exerciseConfig.findUnique({
      where: { id },
      include: { media: true },
    });
    if (!row) {
      throw new NotFoundException(`Exercise config with ID ${id} not found`);
    }
    return this.mapToResponse(row);
  }

  async update(
    id: string,
    dto: UpdateExerciseConfigDto,
  ): Promise<ExerciseConfigResponseDto> {
    const existing = await this.prisma.exerciseConfig.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException(`Exercise config with ID ${id} not found`);
    }

    const updated = await this.prisma.exerciseConfig.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        analyzerType: dto.analyzerType,
        keywords: dto.keywords,
        aiConfigJson: dto.aiConfigJson as Prisma.InputJsonValue | undefined,
        isActive: dto.isActive,
      },
      include: { media: true },
    });
    return this.mapToResponse(updated);
  }

  /**
   * Hard-deletes the ExerciseConfig row only — its Media row is deliberately
   * left in place (unlike TaskMediaService.remove, which cascades). Config
   * media is PUBLIC/non-private, may be worth keeping for audit/reuse, and
   * an orphaned row is harmless. Any Task.exerciseConfigId pointing here is
   * cleared by the DB's onDelete: SetNull.
   */
  async remove(id: string) {
    const existing = await this.prisma.exerciseConfig.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException(`Exercise config with ID ${id} not found`);
    }
    await this.prisma.exerciseConfig.delete({ where: { id } });
    return { success: true };
  }

  /**
   * Validates that [id] exists and is active. Throws otherwise. Used by
   * TaskService/WeeklyPlanService when a task references an exerciseConfigId,
   * mirroring TaskMediaService.assertUsable's role in the attachments flow.
   */
  async assertUsable(id: string) {
    const config = await this.prisma.exerciseConfig.findUnique({
      where: { id },
      select: { id: true, isActive: true },
    });
    if (!config) {
      throw new BadRequestException(`Exercise config ${id} does not exist`);
    }
    if (!config.isActive) {
      throw new BadRequestException(`Exercise config ${id} is retired`);
    }
  }

  /**
   * Batched version of assertUsable for WeeklyPlanService's nested-tasks
   * create path, where many tasks (each optionally referencing a config)
   * are validated in one pass — mirrors TaskMediaService.assertUsable's
   * array-accepting signature used the same way for attachments.
   */
  async assertAllUsable(ids: Array<string | null | undefined>) {
    const unique = Array.from(new Set(ids.filter((id): id is string => !!id)));
    if (unique.length === 0) return;
    const found = await this.prisma.exerciseConfig.findMany({
      where: { id: { in: unique } },
      select: { id: true, isActive: true },
    });
    const byId = new Map(found.map((c) => [c.id, c]));
    for (const id of unique) {
      const config = byId.get(id);
      if (!config) {
        throw new BadRequestException(`Exercise config ${id} does not exist`);
      }
      if (!config.isActive) {
        throw new BadRequestException(`Exercise config ${id} is retired`);
      }
    }
  }

  /**
   * Resolves the lightweight summary for a Task's nested `exerciseConfig`
   * field. Returns null for a null id (task has no config) so callers can
   * chain it directly without a branch.
   */
  async findSummaryById(
    id: string | null | undefined,
  ): Promise<ExerciseConfigSummaryDto | null> {
    if (!id) return null;
    const row = await this.prisma.exerciseConfig.findUnique({
      where: { id },
      include: { media: true },
    });
    if (!row) return null;
    return this.mapToSummary(row);
  }

  /** Public so callers with an already-joined row (e.g. TaskService mapping a
   * Task's nested exerciseConfig) can reuse this without an extra query. */
  async mapToSummary(
    row: ExerciseConfigWithMedia,
  ): Promise<ExerciseConfigSummaryDto> {
    const mediaUrl = await this.storage.getUrl(row.media.storageKey);
    return {
      id: row.id,
      name: row.name,
      description: row.description,
      analyzerType: row.analyzerType,
      keywords: row.keywords,
      mediaUrl,
    };
  }

  async mapToResponse(
    row: ExerciseConfigWithMedia,
  ): Promise<ExerciseConfigResponseDto> {
    const summary = await this.mapToSummary(row);
    return {
      ...summary,
      aiConfigJson: row.aiConfigJson as Record<string, unknown>,
      isActive: row.isActive,
      createdById: row.createdById,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
