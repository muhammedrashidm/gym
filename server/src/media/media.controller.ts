import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { MediaVisibility } from '@prisma/client';
import { MediaService } from './media.service';
import { ReqContext } from '../common/decorators/request-context.decorator';
import type { RequestContext } from '../common/types/request-context.type';

const MAX_UPLOAD_BYTES = 25 * 1024 * 1024; // 25MB

@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: MAX_UPLOAD_BYTES },
    }),
  )
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @ReqContext() ctx: RequestContext,
  ) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }

    const stored = await this.mediaService
      .storageFor(MediaVisibility.PUBLIC)
      .upload(file.buffer, file.originalname, file.mimetype);

    const media = await this.mediaService.createMediaRecord({
      storageKey: stored.storageKey,
      mimeType: stored.mimeType,
      sizeBytes: stored.sizeBytes,
      createdById: ctx.userId,
      visibility: MediaVisibility.PUBLIC,
    });

    const url = await this.mediaService.resolveUrl(media);

    // Preserve the { url } response shape existing callers (owner/ avatar
    // upload) already rely on, alongside the new media metadata.
    return { ...media, url };
  }
}
