## 🔐 Section 1: Authentication & Identity (Mobile)

### 1.1 Login Screen

Handles user authentication via email/password or Google OAuth2.

- **API Calls**:
  - `POST /api/auth/login`: Authenticates user and returns JWT.
  - `POST /api/auth/login/google`: Authenticates via Google ID Token.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `users` | `id` | BIGINT | Primary Key |
  | `users` | `email` | VARCHAR | Unique login identifier |
  | `users` | `password` | VARCHAR | BCrypt hashed password |
  | `users` | `role` | ENUM | CUSTOMER, TEACHER, or ADMIN |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant DB as MySQL Database
      App->>API: POST /api/auth/login {email, password}
      API->>DB: Query User by Email
      DB-->>API: User Record
      API->>API: Verify Password Hash
      API-->>App: 200 OK (JWT Token + User Profile)
  ```

- **Validation**:
  - Email: Required, must follow standard email format.
  - Password: Required, minimum 8 characters.

- **UI Design**: [IMAGE_PLACEHOLDER: LOGIN_SCREEN]

### 1.2 Registration Screen

Allows new students to create an account after verifying their email via OTP.

- **API Calls**:
  - `POST /api/auth/register/send-otp`: Sends a verification code to email.
  - `POST /api/auth/register`: Creates the user account.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `users` | `email` | VARCHAR | Primary identifier |
  | `users` | `is_verified` | BIT | Email verification status |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant Mail as SMTP Server
      App->>API: POST /api/auth/register/send-otp
      API->>Mail: Send Verification Email
      App->>API: POST /api/auth/register {email, password, code}
      API-->>App: 201 Created (Success Message)
  ```

- **Validation**:
  - OTP Code: Must be 6 digits.
  - Password: Must include uppercase, lowercase, and numeric characters.

- **UI Design**: [IMAGE_PLACEHOLDER: REGISTER_SCREEN]
