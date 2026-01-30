# HustleXP Storage Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Backend Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All file storage implementation must follow this specification.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Storage Architecture](#2-storage-architecture)
3. [Buckets](#3-buckets)
4. [Upload Flow](#4-upload-flow)
5. [Security](#5-security)
6. [URL Patterns](#6-url-patterns)
7. [Retention & Cleanup](#7-retention--cleanup)
8. [Implementation](#8-implementation)

---

## 1. Overview

### Storage Provider

HustleXP uses **Cloudflare R2** for object storage.

**Why R2:**
- S3-compatible API
- Zero egress fees
- Edge caching via Cloudflare CDN
- Automatic geographic distribution

### File Types Stored

| Type | Purpose | Max Size | Formats |
|------|---------|----------|---------|
| Proof Photos | Task completion evidence | 10 MB | JPEG, PNG, HEIC |
| Profile Avatars | User profile images | 5 MB | JPEG, PNG |
| Verification Docs | License/insurance uploads | 25 MB | JPEG, PNG, PDF |
| Message Photos | In-task communication | 5 MB | JPEG, PNG |

---

## 2. Storage Architecture

### Bucket Structure

```
hustlexp-storage/
├── proofs/
│   └── {task_id}/
│       └── {proof_id}/
│           ├── photo_1.jpg
│           ├── photo_2.jpg
│           └── photo_3.jpg
│
├── avatars/
│   └── {user_id}/
│       ├── original.jpg
│       ├── 128.jpg      # Thumbnail
│       └── 256.jpg      # Medium
│
├── verifications/
│   └── {user_id}/
│       └── {verification_id}/
│           └── document.pdf
│
└── messages/
    └── {task_id}/
        └── {message_id}/
            └── photo_1.jpg
```

### Environments

| Environment | Bucket Name | Public URL |
|-------------|-------------|------------|
| Development | `hustlexp-dev` | `https://dev-storage.hustlexp.com` |
| Staging | `hustlexp-staging` | `https://staging-storage.hustlexp.com` |
| Production | `hustlexp-prod` | `https://storage.hustlexp.com` |

---

## 3. Buckets

### Proofs Bucket

**Purpose:** Store task completion proof photos

**Access:** Private (signed URLs for access)

**Structure:**
```
proofs/{task_id}/{proof_id}/{upload_order}.{ext}
```

**Metadata:**
```typescript
interface ProofPhotoMetadata {
  task_id: string;
  proof_id: string;
  user_id: string;  // Uploader
  upload_order: number;
  mime_type: string;
  file_size: number;
  gps_latitude?: number;
  gps_longitude?: number;
  capture_timestamp?: string;  // From EXIF
  uploaded_at: string;
}
```

### Avatars Bucket

**Purpose:** User profile photos

**Access:** Public (CDN cached)

**Structure:**
```
avatars/{user_id}/{size}.{ext}
```

**Sizes Generated:**
- `original` - Full resolution (max 2048px)
- `256` - Profile display (256x256)
- `128` - List items (128x128)
- `64` - Tiny (64x64)

### Verifications Bucket

**Purpose:** License, insurance, background check documents

**Access:** Private (admin + owner only)

**Structure:**
```
verifications/{user_id}/{verification_id}/{filename}.{ext}
```

**Retention:** 7 years (legal requirement)

### Messages Bucket

**Purpose:** Photos shared in task messages

**Access:** Private (task participants only)

**Structure:**
```
messages/{task_id}/{message_id}/{upload_order}.{ext}
```

**Retention:** 90 days after task completion

---

## 4. Upload Flow

### 4.1 Presigned URL Flow

```
┌─────────┐     ┌─────────────┐     ┌─────────┐
│ Client  │────▶│   Backend   │────▶│   R2    │
└─────────┘     └─────────────┘     └─────────┘
     │                │                   │
     │  1. Request    │                   │
     │  presigned URL │                   │
     │──────────────▶ │                   │
     │                │  2. Generate URL  │
     │                │──────────────────▶│
     │  3. Return URL │                   │
     │◀────────────── │                   │
     │                │                   │
     │  4. Direct     │                   │
     │     upload     │                   │
     │─────────────────────────────────▶  │
     │                │                   │
     │  5. Confirm    │                   │
     │  upload        │                   │
     │──────────────▶ │                   │
     │                │  6. Verify exists │
     │                │──────────────────▶│
```

### 4.2 Request Presigned URL

**Endpoint:** `POST /api/storage/presigned-url`

**Request:**
```typescript
interface PresignedURLRequest {
  bucket: 'proofs' | 'avatars' | 'verifications' | 'messages';
  filename: string;
  content_type: string;
  content_length: number;
  // Context (varies by bucket)
  task_id?: string;
  proof_id?: string;
  verification_id?: string;
  message_id?: string;
}
```

**Response:**
```typescript
interface PresignedURLResponse {
  upload_url: string;      // Presigned PUT URL
  public_url: string;      // Final public URL
  expires_at: string;      // URL expiry (15 min)
  key: string;             // Object key
}
```

### 4.3 Upload Validation

**Before generating presigned URL:**

1. **Authentication** - User must be logged in
2. **Authorization** - User must have permission
   - Proofs: Must be task worker
   - Avatars: Must be own profile
   - Verifications: Must be own documents
   - Messages: Must be task participant
3. **Content Type** - Must be allowed MIME type
4. **Content Length** - Must be under size limit
5. **Rate Limit** - Max 10 uploads per minute per user

### 4.4 Confirm Upload

**Endpoint:** `POST /api/storage/confirm-upload`

**Request:**
```typescript
interface ConfirmUploadRequest {
  key: string;
  content_type: string;
  content_length: number;
}
```

**Backend Actions:**
1. Verify object exists in R2
2. Verify metadata matches request
3. Update database record with URL
4. Return success

---

## 5. Security

### 5.1 Access Control

| Bucket | Public Read | Auth Required | Additional |
|--------|-------------|---------------|------------|
| Proofs | No | Yes | Task participant or admin |
| Avatars | Yes | No | CDN cached |
| Verifications | No | Yes | Owner or admin only |
| Messages | No | Yes | Task participant only |

### 5.2 Signed URLs

**For private buckets:**

```typescript
async function generateSignedURL(key: string, expiresIn: number = 3600) {
  const command = new GetObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
  });

  return getSignedUrl(s3Client, command, { expiresIn });
}
```

**Expiry Times:**
- Proof photos: 1 hour
- Verification docs: 15 minutes
- Message photos: 1 hour

### 5.3 Content Validation

**Image Upload Validation:**

```typescript
async function validateImage(file: File): Promise<boolean> {
  // 1. Check MIME type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/heic'];
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type');
  }

  // 2. Check file size
  const maxSize = 10 * 1024 * 1024; // 10 MB
  if (file.size > maxSize) {
    throw new Error('File too large');
  }

  // 3. Verify it's actually an image (magic bytes)
  const buffer = await file.arrayBuffer();
  const header = new Uint8Array(buffer.slice(0, 4));

  const signatures = {
    jpeg: [0xFF, 0xD8, 0xFF],
    png: [0x89, 0x50, 0x4E, 0x47],
  };

  // ... validate magic bytes

  return true;
}
```

### 5.4 Content Scanning

**All uploads are scanned for:**
- Malware (ClamAV)
- NSFW content (AI moderation - A2 authority)
- Personal information (phone numbers, SSN patterns)

**Scanning Flow:**
```
Upload → Quarantine → Scan → Approve/Reject → Move to final location
```

---

## 6. URL Patterns

### Public URLs (Avatars)

```
https://storage.hustlexp.com/avatars/{user_id}/256.jpg
```

CDN cached with:
- Cache-Control: public, max-age=86400
- Automatic invalidation on update

### Private URLs (Proofs, Verifications, Messages)

```
https://storage.hustlexp.com/proofs/{task_id}/{proof_id}/1.jpg
  ?X-Amz-Algorithm=AWS4-HMAC-SHA256
  &X-Amz-Credential=...
  &X-Amz-Date=...
  &X-Amz-Expires=3600
  &X-Amz-Signature=...
```

### Database Storage

```sql
-- Store only the key, not full URL
proof_photos {
  storage_key: 'proofs/task-123/proof-456/1.jpg',
  -- NOT: 'https://storage.hustlexp.com/proofs/...'
}
```

Generate signed URLs at request time.

---

## 7. Retention & Cleanup

### Retention Policies

| Bucket | Retention | After Expiry |
|--------|-----------|--------------|
| Proofs | 90 days after task terminal | Soft delete, archive |
| Avatars | Until account deletion | Hard delete |
| Verifications | 7 years (legal) | Archive to cold storage |
| Messages | 90 days after task terminal | Hard delete |

### Cleanup Jobs

**Daily Cleanup Job:**

```typescript
async function cleanupExpiredFiles() {
  // 1. Find tasks in terminal state > 90 days
  const { data: expiredTasks } = await supabase
    .from('tasks')
    .select('id')
    .in('state', ['COMPLETED', 'CANCELLED', 'EXPIRED'])
    .lt('updated_at', ninetyDaysAgo);

  // 2. Delete associated proof photos
  for (const task of expiredTasks) {
    await r2.deleteObjects({
      Bucket: BUCKET_NAME,
      Delete: {
        Objects: await listObjectsWithPrefix(`proofs/${task.id}/`),
      },
    });
  }

  // 3. Update database (mark as deleted, not hard delete)
  await supabase
    .from('proof_photos')
    .update({ deleted_at: new Date() })
    .in('task_id', expiredTasks.map(t => t.id));
}
```

### Archival

Verification documents after 2 years:
1. Move to Cloudflare R2 Infrequent Access
2. Update storage_class in metadata
3. Retain for remaining 5 years

---

## 8. Implementation

### 8.1 R2 Client Setup

```typescript
// src/config/storage.ts
import { S3Client } from '@aws-sdk/client-s3';

export const r2Client = new S3Client({
  region: 'auto',
  endpoint: `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: env.R2_ACCESS_KEY,
    secretAccessKey: env.R2_SECRET_KEY,
  },
});

export const BUCKET_NAME = env.R2_BUCKET;
export const PUBLIC_URL = env.R2_PUBLIC_URL;
```

### 8.2 Upload Service

```typescript
// src/services/storage.service.ts
import { PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { r2Client, BUCKET_NAME } from '@/config/storage';

export class StorageService {
  async createPresignedUploadURL(
    key: string,
    contentType: string,
    contentLength: number
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      ContentType: contentType,
      ContentLength: contentLength,
    });

    return getSignedUrl(r2Client, command, { expiresIn: 900 }); // 15 min
  }

  async createPresignedReadURL(key: string): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
    });

    return getSignedUrl(r2Client, command, { expiresIn: 3600 }); // 1 hour
  }

  async deleteObject(key: string): Promise<void> {
    await r2Client.send(new DeleteObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
    }));
  }

  generateKey(
    bucket: string,
    ...parts: string[]
  ): string {
    return [bucket, ...parts].join('/');
  }
}
```

### 8.3 Image Processing

**For avatars, generate multiple sizes:**

```typescript
import sharp from 'sharp';

async function processAvatar(buffer: Buffer, userId: string) {
  const sizes = [64, 128, 256];
  const uploads = [];

  // Original (resized to max 2048)
  const original = await sharp(buffer)
    .resize(2048, 2048, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 85 })
    .toBuffer();

  uploads.push({
    key: `avatars/${userId}/original.jpg`,
    buffer: original,
  });

  // Generate thumbnails
  for (const size of sizes) {
    const resized = await sharp(buffer)
      .resize(size, size, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toBuffer();

    uploads.push({
      key: `avatars/${userId}/${size}.jpg`,
      buffer: resized,
    });
  }

  // Upload all versions
  await Promise.all(
    uploads.map(({ key, buffer }) =>
      r2Client.send(new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: key,
        Body: buffer,
        ContentType: 'image/jpeg',
        CacheControl: 'public, max-age=86400',
      }))
    )
  );

  return `${PUBLIC_URL}/avatars/${userId}/256.jpg`;
}
```

### 8.4 EXIF Extraction

**For proof photos, extract GPS and timestamp:**

```typescript
import ExifReader from 'exifreader';

async function extractExif(buffer: Buffer): Promise<ExifData> {
  const tags = ExifReader.load(buffer);

  return {
    gps_latitude: tags.GPSLatitude?.description,
    gps_longitude: tags.GPSLongitude?.description,
    capture_timestamp: tags.DateTime?.description,
    camera_make: tags.Make?.description,
    camera_model: tags.Model?.description,
  };
}
```

---

## Environment Variables

```bash
# Cloudflare R2
R2_ACCOUNT_ID=your-account-id
R2_ACCESS_KEY=your-access-key
R2_SECRET_KEY=your-secret-key
R2_BUCKET=hustlexp-prod
R2_PUBLIC_URL=https://storage.hustlexp.com
```

---

## Quick Reference

### Upload Size Limits

| Type | Max Size |
|------|----------|
| Proof Photo | 10 MB |
| Avatar | 5 MB |
| Verification Doc | 25 MB |
| Message Photo | 5 MB |

### Allowed MIME Types

| Bucket | Types |
|--------|-------|
| Proofs | image/jpeg, image/png, image/heic |
| Avatars | image/jpeg, image/png |
| Verifications | image/jpeg, image/png, application/pdf |
| Messages | image/jpeg, image/png |

---

**END OF STORAGE_SPEC v1.0.0**
