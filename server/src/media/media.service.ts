import { Inject, Injectable } from '@nestjs/common';
import { MediaVisibility } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  PUBLIC_STORAGE_SERVICE,
  PROTECTED_STORAGE_SERVICE,
  type StorageService,
} from './storage/storage.interface';

@Injectable()
export class MediaService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(PUBLIC_STORAGE_SERVICE)
    private readonly publicStorage: StorageService,
    @Inject(PROTECTED_STORAGE_SERVICE)
    private readonly protectedStorage: StorageService,
  ) {}

  /** Storage service matching a given visibility profile. */
  storageFor(visibility: MediaVisibility): StorageService {
    return visibility === MediaVisibility.PROTECTED
      ? this.protectedStorage
      : this.publicStorage;
  }

  /** Resolve a fresh, read-time URL for a persisted media row. */
  resolveUrl(media: {
    storageKey: string;
    visibility: MediaVisibility;
  }): Promise<string> {
    return this.storageFor(media.visibility).getUrl(media.storageKey);
  }

  async createMediaRecord(params: {
    storageKey: string;
    mimeType: string;
    sizeBytes: number;
    createdById: string;
    visibility: MediaVisibility;
  }) {
    return this.prisma.media.create({
      data: {
        storageKey: params.storageKey,
        mimeType: params.mimeType,
        sizeBytes: params.sizeBytes,
        createdById: params.createdById,
        visibility: params.visibility,
      },
    });
  }
}
