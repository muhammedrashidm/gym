import { Global, Module, Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  PUBLIC_STORAGE_SERVICE,
  PROTECTED_STORAGE_SERVICE,
  type StorageService,
  type StorageVisibility,
} from './storage.interface';
import { LocalStorageProvider } from './local-storage.provider';
import { S3StorageProvider } from './s3-storage.provider';

function buildProvider(
  config: ConfigService,
  driverKey: 'PUBLIC_STORAGE_DRIVER' | 'PROTECTED_STORAGE_DRIVER',
  bucketKey: 'S3_PUBLIC_BUCKET' | 'S3_PROTECTED_BUCKET',
  visibility: StorageVisibility,
): StorageService {
  const driver = (config.get<string>(driverKey) ?? 'local').toLowerCase();

  if (driver === 's3') {
    const bucket = config.get<string>(bucketKey);
    const region = config.get<string>('S3_REGION');
    const accessKeyId = config.get<string>('S3_ACCESS_KEY_ID');
    const secretAccessKey = config.get<string>('S3_SECRET_ACCESS_KEY');
    if (!bucket || !region || !accessKeyId || !secretAccessKey) {
      throw new Error(
        `Storage driver for ${driverKey} is "s3" but ${bucketKey}/S3_REGION/S3_ACCESS_KEY_ID/S3_SECRET_ACCESS_KEY are not all set.`,
      );
    }
    return new S3StorageProvider({
      bucket,
      region,
      accessKeyId,
      secretAccessKey,
      endpoint: config.get<string>('S3_ENDPOINT') || undefined,
      visibility,
      signedUrlExpirySeconds: Number(
        config.get<string>('S3_SIGNED_URL_EXPIRY_SECONDS') ?? 3600,
      ),
    });
  }

  // Default: local disk.
  const publicBaseUrl =
    config.get<string>('PUBLIC_BASE_URL') ?? 'http://localhost:3000';
  return new LocalStorageProvider(publicBaseUrl);
}

const publicStorageProvider: Provider = {
  provide: PUBLIC_STORAGE_SERVICE,
  inject: [ConfigService],
  useFactory: (config: ConfigService) =>
    buildProvider(config, 'PUBLIC_STORAGE_DRIVER', 'S3_PUBLIC_BUCKET', 'PUBLIC'),
};

const protectedStorageProvider: Provider = {
  provide: PROTECTED_STORAGE_SERVICE,
  inject: [ConfigService],
  useFactory: (config: ConfigService) =>
    buildProvider(
      config,
      'PROTECTED_STORAGE_DRIVER',
      'S3_PROTECTED_BUCKET',
      'PROTECTED',
    ),
};

@Global()
@Module({
  providers: [publicStorageProvider, protectedStorageProvider],
  exports: [PUBLIC_STORAGE_SERVICE, PROTECTED_STORAGE_SERVICE],
})
export class StorageModule {}
