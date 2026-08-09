import {
  Inject,
  Injectable,
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import {
  MediaVisibility,
  TaskMediaType,
  type Prisma,
  type Media,
  type TaskMedia,
} from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import {
  PROTECTED_STORAGE_SERVICE,
  type StorageService,
} from '../../media/storage/storage.interface';
import type { RequestContext } from '../../common/types/request-context.type';
import {
  CreateTaskMediaDto,
  UpdateTaskMediaDto,
  SearchTaskMediaQueryDto,
  TaskMediaResponseDto,
} from '../dto/task-media.dto';

type TaskMediaWithMedia = TaskMedia & { media: Media };

@Injectable()
export class TaskMediaService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(PROTECTED_STORAGE_SERVICE)
    private readonly storage: StorageService,
  ) {}

  async create(
    dto: CreateTaskMediaDto,
    file: Express.Multer.File,
    ctx: RequestContext,
  ): Promise<TaskMediaResponseDto> {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    const type = this.inferType(file.mimetype);

    // Upload the file before creating DB rows. A later DB failure would leave
    // an orphaned object, which is acceptable (no partial DB state).
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
          visibility: MediaVisibility.PROTECTED,
        },
      });
      return tx.taskMedia.create({
        data: {
          mediaId: media.id,
          type,
          name: dto.name,
          description: dto.description || null,
          keywords: dto.keywords ?? [],
          createdById: ctx.userId,
          isPrivate: dto.isPrivate ?? false,
        },
        include: { media: true },
      });
    });

    return this.mapToResponse(created);
  }

  async search(query: SearchTaskMediaQueryDto, ctx: RequestContext) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 20;

    const filters: Prisma.TaskMediaWhereInput[] = [];

    // Visibility: own items always visible; others' only if not private.
    filters.push(
      query.mine
        ? { createdById: ctx.userId }
        : { OR: [{ isPrivate: false }, { createdById: ctx.userId }] },
    );

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

    const where: Prisma.TaskMediaWhereInput = { AND: filters };

    const [rows, total] = await Promise.all([
      this.prisma.taskMedia.findMany({
        where,
        include: { media: true },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.taskMedia.count({ where }),
    ]);

    const data = await Promise.all(rows.map((r) => this.mapToResponse(r)));
    return { data, meta: { total, page, pageSize } };
  }

  async update(id: string, dto: UpdateTaskMediaDto, ctx: RequestContext) {
    const existing = await this.prisma.taskMedia.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Task media with ID ${id} not found`);
    }
    this.assertCanModify(existing, ctx);

    const updated = await this.prisma.taskMedia.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        keywords: dto.keywords,
        isPrivate: dto.isPrivate,
      },
      include: { media: true },
    });
    return this.mapToResponse(updated);
  }

  async remove(id: string, ctx: RequestContext) {
    const existing = await this.prisma.taskMedia.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Task media with ID ${id} not found`);
    }
    this.assertCanModify(existing, ctx);

    // Cascade removes any TaskAttachment rows; the Media row is removed too
    // so we don't leak orphaned file records.
    await this.prisma.$transaction(async (tx) => {
      await tx.taskMedia.delete({ where: { id } });
      await tx.media.delete({ where: { id: existing.mediaId } });
    });
    return { success: true };
  }

  /**
   * Validates that every id in [taskMediaIds] exists and is usable by the
   * caller (own item, or a non-private item). Throws otherwise. Used by the
   * task/weekly-plan attach paths so a plan can't reference forbidden media.
   */
  async assertUsable(taskMediaIds: string[], ctx: RequestContext) {
    if (taskMediaIds.length === 0) return;
    const unique = Array.from(new Set(taskMediaIds));
    const found = await this.prisma.taskMedia.findMany({
      where: { id: { in: unique } },
      select: { id: true, isPrivate: true, createdById: true },
    });
    const byId = new Map(found.map((m) => [m.id, m]));
    for (const id of unique) {
      const m = byId.get(id);
      if (!m) {
        throw new BadRequestException(`Task media ${id} does not exist`);
      }
      const usable = ctx.isAdmin || !m.isPrivate || m.createdById === ctx.userId;
      if (!usable) {
        throw new ForbiddenException(
          `Task media ${id} is private and not owned by you`,
        );
      }
    }
  }

  /** Resolves a fresh signed URL for a persisted TaskMedia + its Media. */
  async mapToResponse(
    row: TaskMediaWithMedia,
  ): Promise<TaskMediaResponseDto> {
    const url = await this.storage.getUrl(row.media.storageKey);
    return {
      id: row.id,
      type: row.type,
      name: row.name,
      description: row.description,
      keywords: row.keywords,
      isPrivate: row.isPrivate,
      createdById: row.createdById,
      url,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }

  private inferType(mimeType: string): TaskMediaType {
    if (mimeType === 'image/gif') return TaskMediaType.GIF;
    if (mimeType.startsWith('image/')) return TaskMediaType.IMAGE;
    if (mimeType.startsWith('video/')) return TaskMediaType.VIDEO;
    throw new BadRequestException(
      `Unsupported media type "${mimeType}" — only images, gifs and videos are allowed`,
    );
  }

  private assertCanModify(
    media: { createdById: string },
    ctx: RequestContext,
  ) {
    if (ctx.isAdmin) return;
    if (media.createdById !== ctx.userId) {
      throw new ForbiddenException(
        'Only the creator can modify this media library item',
      );
    }
  }
}
