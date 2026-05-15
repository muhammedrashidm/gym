import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MediaService {
  constructor(private readonly prisma: PrismaService) {}

  async createMediaRecord(url: string, type: string) {
    return this.prisma.media.create({
      data: {
        url,
        type,
      },
    });
  }
}
