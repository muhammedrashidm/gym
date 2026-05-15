# Gym Users & Profile API Documentation

## Overview

Manage user profiles, physical metrics, and experience levels. Supports both member self-onboarding and staff-assisted registration.

**Base URL:** `/api/v1/users`

---

## Endpoints Summary

### Member Self-Service (Authenticated)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/users/profile` | Bearer access | Create own profile |
| PUT | `/users/profile` | Bearer access | Update own profile |
| DELETE | `/users/profile` | Bearer access | Deactivate own profile |

### Staff/Admin Management
| Method | Path | Auth | Roles Required | Description |
|--------|------|------|----------------|-------------|
| POST | `/users/manage/members` | Bearer access | `staff`, `owner`, `admin` | Create a member profile |
| PUT | `/users/manage/members/:profileId` | Bearer access | `staff`, `owner`, `admin` | Update any member profile |
| DELETE | `/users/manage/members/:profileId` | Bearer access | `staff`, `owner`, `admin` | Deactivate any member profile |

---

## 1. Create Profile (Member)

Used by a member to set up their initial profile after OTP verification.

### Request
```http
POST /api/v1/users/profile
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "fullName": "Aisha Khan",
  "age": 28,
  "sex": "FEMALE",
  "expLevel": "BEGINNER",
  "avatarUrl": "https://example.com/avatar.jpg",
  "weight": 72.5,
  "height": 175
}
```

### Response (201 Created)
```json
{
  "id": "prof-uuid-123",
  "userId": "user-uuid-456",
  "phoneNumber": "+1234567890",
  "fullName": "Aisha Khan",
  "age": 28,
  "sex": "FEMALE",
  "expLevel": "BEGINNER",
  "isKinetic": false,
  "isClaimed": true,
  "avatarUrl": "https://example.com/avatar.jpg",
  "isActive": true,
  "createdAt": "2026-05-04T22:00:00Z",
  "bodyMetrics": []
}
```

---

## 2. Staff Create Profile

Used by gym staff to register a member (e.g., walk-in). Requires a `phoneNumber` since the member might not have an account yet.

### Request
```http
POST /api/v1/users/manage/members
Authorization: Bearer {staffAccessToken}
Content-Type: application/json

{
  "phoneNumber": "+919876543210",
  "fullName": "John Doe",
  "sex": "MALE",
  "expLevel": "INTERMEDIATE"
}
```

### Response (201 Created)
Returns the `ProfileModel` (same as Member Create).

---

## 3. Data Structures

### CreateProfileDto / UpdateProfileDto
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `fullName` | string | Yes* | Full display name (Optional for Update) |
| `age` | number | No | Age in years |
| `sex` | enum | No | `MALE`, `FEMALE`, `OTHER` |
| `expLevel` | enum | No | `BEGINNER`, `INTERMEDIATE`, `PRO` |
| `avatarUrl` | string | No | URL to profile image |
| `weight` | number | No | Body weight in kg |
| `height` | number | No | Height in cm |
| `muscleMass` | number | No | Muscle mass percentage |
| `bodyFatPct` | number | No | Body fat percentage |

### StaffCreateProfileDto
Inherits all properties from `CreateProfileDto` but **requires** `phoneNumber`.

---

## 4. Enums

### Sex
- `MALE`
- `FEMALE`
- `OTHER`

### ExpLevel (Training Experience)
- `BEGINNER`: Just starting out.
- `INTERMEDIATE`: Regular training history.
- `PRO`: Advanced/Competitive level.

---

## 5. Client Implementation (Flutter)

### Creating a Profile
```dart
Future<void> createProfile(Map<String, dynamic> data) async {
  final token = await storage.read(key: 'accessToken');
  final response = await http.post(
    Uri.parse('$baseUrl/users/profile'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 201) {
    print('Profile created successfully');
  } else {
    print('Error: ${response.body}');
  }
}
```

### Example Payload for Flutter
```dart
final profileData = {
  "fullName": "Rahul Sharma",
  "sex": "MALE",
  "expLevel": "INTERMEDIATE",
  "weight": 85.0,
  "height": 182.0
};
```

---

## 6. Error Responses

| Status | Code | Meaning |
|--------|------|---------|
| 400 | `Bad Request` | Validation failed (e.g., invalid enum value or missing fullName) |
| 401 | `Unauthorized` | Missing or invalid Bearer token |
| 403 | `Forbidden` | User does not have staff/owner roles for management endpoints |
| 404 | `Not Found` | Profile not found for update/delete |
| 409 | `Conflict` | Profile already exists for this user or phone number |
