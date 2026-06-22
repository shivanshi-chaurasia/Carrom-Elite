# Carrom Elite — API Contract (Auth Module v1)

## Base URL

```
Development: http://localhost:8080/api/v1
Production:  https://api.carrompro.example.com/api/v1
```

## Standard Response Envelope

```json
// Success
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }          // payload (can be object, array, or null)
}

// Error
{
  "success": false,
  "message": "Error description",
  "errors": ["field: message"]   // optional, for validation errors
}
```

> **IMPORTANT**: The `/auth/refresh` endpoint is an exception — it returns **flat** `{ accessToken, refreshToken }` without the envelope for compatibility with the Flutter Dio interceptor.

## Auth Endpoints

### POST /auth/register

Register a new user account.

**Request Body:**
```json
{
  "username": "shiva_gamer",          // required, 3-50 chars, alphanumeric + underscore
  "email": "shiva@example.com",       // required, valid email
  "password": "Strong@123",           // required, 8+ chars, must have upper, lower, number, special
  "phone": "+919876543210",           // optional, with country code
  "referralCode": "SHIV99A",          // optional, referrer's code
  "deviceId": "device-uuid-here",     // required, unique device identifier
  "platform": "ANDROID",              // required, ANDROID | IOS | WEB
  "fcmToken": "firebase-token-here"   // optional, for push notifications
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registration successful. Please verify your email.",
  "data": {
    "user": {
      "id": "uuid",
      "username": "shiva_gamer",
      "email": "shiva@example.com",
      "phone": "+919876543210",
      "role": "USER",
      "avatar": null,
      "referralCode": "A1B2C3D4",
      "isEmailVerified": false,
      "isPhoneVerified": false,
      "isKycCompleted": false,
      "isBiometricEnabled": false
    },
    "tokens": {
      "accessToken": "eyJhbG...",
      "refreshToken": "eyJhbG...",
      "expiresIn": 900
    }
  }
}
```

**Notes:**
- Welcome email + OTP are sent asynchronously after registration
- Duplicate email/username/phone returns 409 Conflict

---

### POST /auth/login

Authenticate user with email/phone + password.

**Request Body:**
```json
{
  "email": "shiva@example.com",     // optional, if phone not provided
  "phone": "+919876543210",         // optional, if email not provided
  "password": "Strong@123",         // required
  "deviceId": "device-uuid-here",   // required
  "platform": "ANDROID",            // required
  "fcmToken": "firebase-token"      // optional
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": { /* same as register response */ },
    "tokens": { /* accessToken + refreshToken + expiresIn */ }
  }
}
```

---

### POST /auth/refresh

Refresh expired access token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbG...",     // required
  "deviceId": "device-uuid"         // optional
}
```

**Response (200) — FLAT (no envelope):**
```json
{
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG..."
}
```

> **Frontend Integration Note**: The Flutter `ApiService._refreshAndRetry()` method reads `res.data['accessToken']` directly. With this flat response, the existing interceptor code works without changes:
```dart
// Current code — works as-is:
final data = Map<String, dynamic>.from(res.data as Map);
await storage.saveTokens(data['accessToken'] ?? '', data['refreshToken'] ?? refresh);
```

---

### POST /auth/logout

Revoke current session.

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "refreshToken": "eyJhbG...",     // required
  "deviceId": "device-uuid"         // optional
}
```

**Response (200):**
```json
{ "success": true, "message": "Logout successful.", "data": null }
```

---

### POST /auth/send-otp

Send OTP to email or phone.

**Request Body:**
```json
{
  "email": "shiva@example.com",     // optional, if phone not provided
  "phone": "+919876543210",         // optional, if email not provided
  "purpose": "email_verification"   // required: email_verification | phone_verification | password_reset | withdrawal
}
```

**Response (200):**
```json
{ "success": true, "message": "OTP sent successfully.", "data": null }
```

**Rate Limit:** Max 3 requests per 60 seconds.

---

### POST /auth/verify-email

Verify email address with OTP.

**Request Body:**
```json
{
  "email": "shiva@example.com",    // required
  "otp": "483921"                   // required, 6 digits
}
```

**Response (200):**
```json
{ "success": true, "message": "Email verified successfully.", "data": null }
```

---

### POST /auth/verify-phone

Verify phone number with OTP.

**Request Body:**
```json
{
  "phone": "+919876543210",        // required
  "otp": "483921"                   // required, 6 digits
}
```

**Response (200):**
```json
{ "success": true, "message": "OTP verified successfully.", "data": null }
```

---

### POST /auth/verify-otp

Generic OTP verification (use when you only need to check validity without completing a specific action).

**Request Body:**
```json
{
  "email": "shiva@example.com",     // optional
  "phone": "+919876543210",         // optional
  "otp": "483921",                  // required, 6 digits
  "purpose": "email_verification"   // required
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP verified successfully.",
  "data": { "verified": true }
}
```

---

### POST /auth/forgot-password

Send password reset link to email.

**Request Body:**
```json
{ "email": "shiva@example.com" }
```

**Response (200):**
```json
{ "success": true, "message": "Password reset link sent to your email.", "data": null }
```

> Always returns success (does not reveal if email exists in system).

---

### POST /auth/reset-password

Reset password using token from email.

**Request Body:**
```json
{
  "token": "eyJhbG...",           // JWT token from email link
  "password": "NewStrong@456"      // new password, same complexity rules
}
```

**Response (200):**
```json
{ "success": true, "message": "Password reset successfully.", "data": null }
```

> All existing sessions are revoked after password reset.

---

### POST /auth/biometric/register

Enable biometric authentication for device.

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "password": "Strong@123",       // current password for verification
  "deviceId": "device-uuid-here"  // device to enable biometric for
}
```

**Response (200):**
```json
{ "success": true, "message": "Biometric key registered successfully.", "data": null }
```

---

### POST /auth/biometric/login

Login using registered biometric device.

**Request Body:**
```json
{
  "biometricKey": "key-here",     // required
  "deviceId": "device-uuid-here", // required
  "platform": "ANDROID",          // required
  "fcmToken": "firebase-token"    // optional
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": { /* same as register */ },
    "tokens": { /* accessToken + refreshToken + expiresIn */ }
  }
}
```

## Error Codes

| HTTP | Code | Meaning |
|------|------|---------|
| 400 | BAD_REQUEST | Invalid input (e.g., wrong OTP) |
| 401 | UNAUTHORIZED | Missing/invalid token or credentials |
| 403 | FORBIDDEN | Account banned or inactive |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Duplicate email, username, or phone |
| 422 | UNPROCESSABLE_ENTITY | Validation errors (field-level) |
| 429 | TOO_MANY_REQUESTS | Rate limit exceeded |

**Error Response Shape:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": ["email: Invalid email address"],
  "correlationId": "uuid"
}
```

## ⚡ Socket.IO Events

**Connection:** `wss://api.carrompro.example.com` with auth `{ token: <JWT> }`

### Frontend listens to:
| Event | Payload | When |
|---|---|---|
| `join_room` | `{ roomId, userId }` | Player joined a match room |
| `match_assigned` | `{ matchId, opponent, roomCode }` | Matchmaking found opponent |
| `score_update` | `{ matchId, player1Score, player2Score }` | Live score change |
| `new_match_notification` | `{ matchId, type, message }` | New match event |

### Frontend emits:
| Event | Payload | When |
|---|---|---|
| `match_emoji` | `{ emoji: "😎" }` | Send emoji during match |

## 👣 Frontend Adaptation Needed

The Flutter `ApiService._refreshAndRetry()` currently reads `res.data['accessToken']`. Since the refresh endpoint now returns flat tokens, **no changes needed** for the interceptor. 

For all other endpoints where the response is `{ success, data, message }`, the frontend should access `res.data['data']` to get the payload. Example:

```dart
// Current (works for refresh):
final data = Map<String, dynamic>.from(res.data as Map);

// For other endpoints, get nested data:
final body = Map<String, dynamic>.from(res.data as Map);
final payload = body['data'];
```
