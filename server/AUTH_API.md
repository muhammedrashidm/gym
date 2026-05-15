# Gym Auth API Documentation

## Overview

Phone-based OTP authentication with JWT tokens. Multi-tenant gym roles, refresh token rotation, auto profile claiming.

**Base URL:** `/api/v1/auth`

---

## Endpoints Summary

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/request-otp` | Public | Request OTP to phone |
| POST | `/auth/verify-otp` | Public | Verify OTP, get tokens |
| POST | `/auth/refresh` | Bearer refresh | Get new access token |
| POST | `/auth/logout` | Bearer access | Revoke refresh token |
| GET | `/auth/me` | Bearer access | Get current user |

---

## 1. Request OTP

Send verification code to phone number.

### Request
```http
POST /api/v1/auth/request-otp
Content-Type: application/json

{
  "phoneNumber": "+1234567890"
}
```

### Schema (RequestOtpDto)
```typescript
{
  phoneNumber: string;  // Pattern: /^\+?[1-9]\d{6,14}$/
}
```

### Response (200 OK)
```json
{ "success": true }
```

### Errors
| Status | Message |
|--------|---------|
| 400 | Invalid phone number format |

**Dev Mode:** OTP is always `1234` and logged to console.

---

## 2. Verify OTP

Verify code, authenticate user. Creates user if not exists.

### Request
```http
POST /api/v1/auth/verify-otp
Content-Type: application/json

{
  "phoneNumber": "+1234567890",
  "code": "1234"
}
```

### Schema (VerifyOtpDto)
```typescript
{
  phoneNumber: string;  // Pattern: /^\+?[1-9]\d{6,14}$/
  code: string;        // Length: 4-6
}
```

### Response (200 OK)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "uuid-here",
  "user": {
    "id": "usr_abc123",
    "phoneNumber": "+1234567890",
    "isActive": true,
    "roles": [
      {
        "roleId": "rol_def456",
        "roleName": "SUBSCRIBER",
        "gymId": "gym_ghi789"
      }
    ]
  },
  "claimedProfile": { ... }
}
```

### Schema (Response)
```typescript
interface VerifyOtpResponse {
  accessToken: string;     // JWT, 15 min expiry
  refreshToken: string;    // UUID, 30 days
  user: {
    id: string;
    phoneNumber: string;
    isActive: boolean;
    roles: UserRoleClaim[];
  };
  claimedProfile: Profile | null;
}

interface UserRoleClaim {
  roleId: string;
  roleName: string;    // "SUBSCRIBER" | "ADMIN" | "TRAINER"
  gymId: string | null; // null = system-wide
}
```

### Errors
| Status | Message | When |
|--------|---------|------|
| 401 | Invalid or expired OTP | No valid OTP found |
| 401 | Invalid OTP | Code mismatch |

---

## 3. Refresh Token

Get new access token. Rotates refresh token.

### Request
```http
POST /api/v1/auth/refresh
Authorization: Bearer {refreshToken}
```

### Response (200 OK)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "new-uuid-here"
}
```

### Schema
```typescript
{
  accessToken: string;
  refreshToken: string;
}
```

### Errors
| Status | Message |
|--------|---------|
| 401 | Invalid refresh token |
| 401 | User not found or inactive |

---

## 4. Logout

Revoke refresh token.

### Request
```http
POST /api/v1/auth/logout
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "refreshToken": "uuid-to-revoke"
}
```

### Schema
```typescript
{ refreshToken: string }
```

### Response (200 OK)
```json
{ "success": true }
```

---

## 5. Get Current User

### Request
```http
GET /api/v1/auth/me
Authorization: Bearer {accessToken}
```

### Response (200 OK)
```json
{
  "id": "usr_abc123",
  "phoneNumber": "+1234567890",
  "isActive": true,
  "roles": [...]
}
```

---

## Token Specifications

### Access Token (JWT)
| Property | Value |
|----------|-------|
| Type | JWT HS256 |
| Header | `Authorization: Bearer {token}` |
| Expiry | 15 minutes (JWT_EXPIRES_IN) |

**JWT Payload:**
```json
{
  "sub": "usr_abc123",
  "phone": "+1234567890",
  "roles": [{ "roleId", "roleName", "gymId" }],
  "iat": 1714588800,
  "exp": 1714589700
}
```

### Refresh Token
| Property | Value |
|----------|-------|
| Type | UUID v4 (SHA256 hashed in DB) |
| Storage | HttpOnly cookie / Secure storage |
| Expiry | 30 days (REFRESH_TOKEN_EXPIRES_DAYS) |
| Rotation | Yes - new token on each refresh |

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_SECRET` | HS256 signing key | (required) |
| `JWT_EXPIRES_IN` | Access expiry | `15m` |
| `REFRESH_TOKEN_EXPIRES_DAYS` | Refresh expiry | `30` |
| `NODE_ENV` | Dev mode | `development` |

---

## Client Implementation (React/Remix)

```typescript
const API_URL = process.env.API_URL || 'http://localhost:3000';

export async function requestOtp(phoneNumber: string) {
  const res = await fetch(`${API_URL}/auth/request-otp`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phoneNumber }),
  });
  return res.json();
}

export async function verifyOtp(phoneNumber: string, code: string) {
  const res = await fetch(`${API_URL}/auth/verify-otp`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phoneNumber, code }),
  });
  const data = await res.json();
  localStorage.setItem('accessToken', data.accessToken);
  localStorage.setItem('refreshToken', data.refreshToken);
  return data;
}

export async function refreshToken() {
  const refreshToken = localStorage.getItem('refreshToken');
  const res = await fetch(`${API_URL}/auth/refresh`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${refreshToken}` },
  });
  const data = await res.json();
  localStorage.setItem('accessToken', data.accessToken);
  localStorage.setItem('refreshToken', data.refreshToken);
  return data.accessToken;
}

export async function fetchWithAuth(url: string, options: RequestInit = {}) {
  let token = localStorage.getItem('accessToken');
  let res = await fetch(url, {
    ...options,
    headers: { ...options.headers, 'Authorization': `Bearer ${token}` },
  });
  
  if (res.status === 401) {
    token = await refreshToken();
    res = await fetch(url, {
      ...options,
      headers: { ...options.headers, 'Authorization': `Bearer ${token}` },
    });
  }
  return res;
}
```

---

## Client Implementation (Flutter)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _apiUrl = 'http://localhost:3000';
  
  static Future<void> requestOtp(String phoneNumber) async {
    final res = await http.post(
      Uri.parse('$_apiUrl/auth/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );
    if (res.statusCode != 200) throw Exception('Failed');
  }
  
  static Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String code) async {
    final res = await http.post(
      Uri.parse('$_apiUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'code': code}),
    );
    final data = jsonDecode(res.body);
    await _storage.write(key: 'accessToken', value: data['accessToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    return data;
  }
  
  static Future<String> refreshToken() async {
    final refresh = await _storage.read(key: 'refreshToken');
    final res = await http.post(
      Uri.parse('$_apiUrl/auth/refresh'),
      headers: {'Authorization': 'Bearer $refresh'},
    );
    final data = jsonDecode(res.body);
    await _storage.write(key: 'accessToken', value: data['accessToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    return data['accessToken'];
  }
  
  static Future<void> logout() async {
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');
    await http.post(
      Uri.parse('$_apiUrl/auth/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    await _storage.deleteAll();
  }
}
```

---

## Database Schema (Prisma)

```prisma
model User {
  id           String    @id @default(cuid())
  phoneNumber  String    @unique
  isActive     Boolean   @default(true)
  otpRequests  OtpRequest[]
  refreshTokens RefreshToken[]
  roles        UserRole[]
  profile      Profile?
}

model OtpRequest {
  id          String   @id @default(cuid())
  phoneNumber String
  code        String
  verified    Boolean  @default(false)
  expiresAt   DateTime
  createdAt   DateTime @default(now())
}

model RefreshToken {
  id        String   @id @default(cuid())
  token     String   @unique // SHA256 hash
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  isRevoked Boolean  @default(false)
  expiresAt DateTime
}

model Role {
  id        String   @id @default(cuid())
  name      String   @unique // "ADMIN" | "TRAINER" | "SUBSCRIBER"
  userRoles UserRole[]
}

model UserRole {
  id     String @id @default(cuid())
  userId String
  roleId String
  gymId  String?
  @@unique([userId, roleId, gymId])
}

model Profile {
  id          String  @id @default(cuid())
  userId      String  @unique
  user        User    @relation(fields: [userId], references: [id])
  phoneNumber String
  isClaimed   Boolean @default(false)
  createdAtGymId String?
}
```

---

## Testing (Development)

```bash
# Request OTP
curl -X POST http://localhost:3000/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890"}'
# Console: [OTP Stub] Code for +1234567890: 1234

# Verify with 1234
curl -X POST http://localhost:3000/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890", "code": "1234"}'

# Refresh
curl -X POST http://localhost:3000/auth/refresh \
  -H "Authorization: Bearer {refreshToken}"

# Get me
curl http://localhost:3000/auth/me \
  -H "Authorization: Bearer {accessToken}"

# Logout
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "{refreshToken}"}'
```

---

## Security Notes

1. **HTTPS Only** — Never use HTTP in production
2. **HttpOnly Cookies** — Store refresh tokens in HttpOnly cookies (web)
3. **Secure Storage** — Use Keychain/Keystore on mobile
4. **Token Rotation** — Always use new refresh token after refresh
5. **Rate Limiting** — Implement rate limiting on OTP endpoints
6. **OTP Expiry** — Codes expire after 10 minutes
