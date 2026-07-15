import { promises as fs } from 'fs';
import { join, extname } from 'path';
import { randomUUID } from 'crypto';
import type { StorageService, UploadResult } from './storage.interface';

/**
 * Stores files on the local disk under `./uploads`, served statically by
 * `app.useStaticAssets` (see main.ts). `getUrl` returns a stable
 * `${PUBLIC_BASE_URL}/uploads/<key>` link. Used as the default driver for
 * both profiles; note that under this driver "protected" media has no true
 * access control — it is still publicly reachable by URL (dev convenience).
 */
export class LocalStorageProvider implements StorageService {
  private readonly uploadDir: string;

  constructor(private readonly publicBaseUrl: string) {
    // Mirror main.ts: uploads live one level up from the compiled dir root.
    this.uploadDir = join(process.cwd(), 'uploads');
  }

  async upload(
    buffer: Buffer,
    originalName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    await fs.mkdir(this.uploadDir, { recursive: true });
    const storageKey = `${randomUUID()}${extname(originalName)}`;
    await fs.writeFile(join(this.uploadDir, storageKey), buffer);
    return { storageKey, mimeType, sizeBytes: buffer.length };
  }

  getUrl(storageKey: string): Promise<string> {
    const base = this.publicBaseUrl.replace(/\/+$/, '');
    return Promise.resolve(`${base}/uploads/${storageKey}`);
  }
}
