## 👤 Section 12: Profile & Social Features

### 12.1 Settings & Profile Management (Mobile & Web)

Update user information, avatar, and security preferences.

- **API Calls**:
  - `GET /api/profile`: Fetch current user profile (Name, Bio, Address, Birthday, Phone, Avatar).
  - `PUT /api/profile`: Update basic profile information.
  - `POST /api/profile/change-password`: Securely update user password.
  - `POST /api/media/upload`: Upload new avatar image via Multi-part file.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `user_profiles` | `full_name` | VARCHAR | User's display name |
  | `user_profiles` | `avatar_url` | VARCHAR | Profile picture served via /media/avatars/ |
  | `user_profiles` | `bio` | TEXT | Short biography |
  | `user_profiles` | `address` | VARCHAR | Home/Work address |
  | `user_profiles` | `birthday` | DATE | Date of birth |
  | `user_profiles` | `phone_number`| VARCHAR | Contact number |
  | `users` | `password_hash` | VARCHAR | BCrypt hashed password |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant UI as Frontend (Web/Mobile)
      participant API as Spring Boot API
      participant MS as Media Service
      participant DB as MySQL Database
      
      UI->>API: GET /api/profile
      API-->>UI: UserProfileDTO {fullName, avatarUrl...}
      
      Note over UI, MS: Avatar Update Flow
      UI->>MS: POST /api/media/upload (File)
      MS-->>UI: {storedPath: '/media/avatars/uuid.jpg'}
      UI->>API: PUT /api/profile {avatarUrl: '...'}
      API->>DB: Save Profile
      API-->>UI: 200 OK
      
      Note over UI, DB: Password Update Flow
      UI->>API: POST /api/profile/change-password {old, new}
      API->>DB: Verify & Update Hash
      DB-->>UI: 200 OK
  ```

- **Validation**:
  - Phone: Must be 10-12 digits.
  - Bio: Max 1000 characters.
  - New Password: Minimum 8 characters, must match confirmation.

- **UI Design**: [IMAGE_PLACEHOLDER: USER_PROFILE_EDIT_WEB_AND_MOBILE]

---

### 12.2 Chat Support (Student-Admin)

In-app communication for technical support and study questions.

- **API Calls**:
  - `GET /api/chat/history`: Previous messages.
  - `WS (WebSocket) /ws-chat`: Real-time message exchange protocol.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `chat_message` | `id` | BIGINT | PK |
  | `chat_message` | `sender_id` | BIGINT | FK to User |
  | `chat_message` | `content` | TEXT | Message body |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Student App
      participant WS as WebSocket Broker
      participant Admin as Admin Dashboard
      App->>WS: SEND {to: admin, text: 'Hello'}
      WS->>Admin: BROADCAST Message
      Admin->>WS: SEND {to: student, text: 'Hi!'}
      WS->>App: BROADCAST Reply
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: CHAT_SUPPORT_VIEW]
