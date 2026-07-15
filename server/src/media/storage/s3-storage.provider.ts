import { extname } from 'path';
import { randomUUID } from 'crypto';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import type { StorageService, UploadResult } from './storage.interface';

export interface S3ProviderOptions {
  bucket: string;
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  /** Optional custom endpoint for S3-compatible (non-AWS) providers. */
  endpoint?: string;
  /** PUBLIC → stable object URL; PROTECTED → time-limited signed URL. */
  visibility: 'PUBLIC' | 'PROTECTED';
  /** Signed-URL lifetime in seconds (PROTECTED only). */
  signedUrlExpirySeconds: number;
}

/**
 * Stores files in an S3 (or S3-compatible) bucket. For a PUBLIC bucket,
 * `getUrl` returns the stable object URL. For a PROTECTED bucket, objects
 * are never public — `getUrl` mints a fresh time-limited signed URL on
 * every call, so callers must always re-resolve rather than persist it.
 */
export class S3StorageProvider implements StorageService {
  private readonly client: S3Client;

  constructor(private readonly opts: S3ProviderOptions) {
    this.client = new S3Client({
      region: opts.region,
      endpoint: opts.endpoint || undefined,
      // Path-style addressing is required by most non-AWS S3-compatible
      // providers (MinIO, etc.) when a custom endpoint is set.
      forcePathStyle: !!opts.endpoint,
      credentials: {
        accessKeyId: opts.accessKeyId,
        secretAccessKey: opts.secretAccessKey,
      },
    });
  }

  async upload(
    buffer: Buffer,
    originalName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    const storageKey = `${randomUUID()}${extname(originalName)}`;
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.opts.bucket,
        Key: storageKey,
        Body: buffer,
        ContentType: mimeType,
      }),
    );
    return { storageKey, mimeType, sizeBytes: buffer.length };
  }

  async getUrl(storageKey: string): Promise<string> {
    if (this.opts.visibility === 'PUBLIC') {
      if (this.opts.endpoint) {
        const base = this.opts.endpoint.replace(/\/+$/, '');
        return `${base}/${this.opts.bucket}/${storageKey}`;
      }
      return `https://${this.opts.bucket}.s3.${this.opts.region}.amazonaws.com/${storageKey}`;
    }
    return getSignedUrl(
      this.client,
      new GetObjectCommand({ Bucket: this.opts.bucket, Key: storageKey }),
      { expiresIn: this.opts.signedUrlExpirySeconds },
    );
  }
}
