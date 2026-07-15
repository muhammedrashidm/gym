export interface UploadResult {
  storageKey: string;
  mimeType: string;
  sizeBytes: number;
}

/**
 * Abstraction over where media files physically live. Two independently
 * configured instances exist (see storage.module.ts): one PUBLIC profile
 * for avatars/logos (stable, directly-linkable URLs) and one PROTECTED
 * profile for task media (signed, expiring URLs resolved fresh on every
 * read). Callers never persist the resolved URL — they store only the
 * `storageKey` and call `getUrl` again on each read.
 */
export interface StorageService {
  upload(
    buffer: Buffer,
    originalName: string,
    mimeType: string,
  ): Promise<UploadResult>;

  getUrl(storageKey: string): Promise<string>;
}

/** DI tokens for the two configured storage profiles. */
export const PUBLIC_STORAGE_SERVICE = Symbol('PUBLIC_STORAGE_SERVICE');
export const PROTECTED_STORAGE_SERVICE = Symbol('PROTECTED_STORAGE_SERVICE');

export type StorageVisibility = 'PUBLIC' | 'PROTECTED';
