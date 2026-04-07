# 📱 IELTS Learning Platform - Full Screen Technical Documentation

This document provides a detailed technical breakdown of every screen in the IELTS Learning Platform, including API interactions, database models, sequence flows, and validation rules.

---

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

---

## ✍️ Section 2: Writing Skill Practice (Mobile)

### 2.1 Writing Topic Selection

Students can choose from Task 1 (Academic/General) and Task 2 (Essay) topics.

- **API Calls**:
  - `GET /api/writing/topics`: Retrieves all active writing topics.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `writing_topic` | `id` | BIGINT | PK |
  | `writing_topic` | `title` | VARCHAR | Topic title |
  | `writing_topic` | `description` | TEXT | Prompt details |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      App->>API: GET /api/writing/topics
      API-->>App: List<TopicResponse>
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: WRITING_TOPIC_GALLERY]

### 2.2 Writing Workspace & Submission

The main editor where students write their essays and submit for grading.

- **API Calls**:
  - `POST /api/writing/submit`: Submits the essay for AI or Human review.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `writing_submission` | `id` | BIGINT | PK |
  | `writing_submission` | `content` | TEXT | Student's essay content |
  | `writing_submission` | `grading_type` | ENUM | AI or HUMAN |
  | `writing_submission` | `band_score` | DOUBLE | Final assigned score |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant AI as Ollama (Gemma)
      App->>API: POST /api/writing/submit {content, type: AI}
      API->>AI: Generate Feedback Prompt
      AI-->>API: Band Score + Improvement Tips
      API-->>App: Submission Result (Real-time feedback)
  ```

- **Validation**:
  - Content: Minimum 50 words for Task 1, 150 words for Task 2.

- **UI Design**: [IMAGE_PLACEHOLDER: WRITING_SUBMISSION_WORKSPACE]

---

## 🎓 Section 3: Teacher Portal (Web)

### 3.1 Grading Dashboard

Teachers view and manage pending human-grading requests.

- **API Calls**:
  - `GET /api/teacher/grading/submissions`: Fetches all submissions awaiting review.
  - `POST /api/teacher/grading/submissions/{id}/claim`: Assigns a submission to the teacher.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `writing_submission` | `teacher_id` | BIGINT | FK to User (Teacher) |
  | `writing_submission` | `status` | VARCHAR | PENDING, IN_PROGRESS, COMPLETED |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant Web as Teacher Portal
      participant API as Spring Boot API
      Web->>API: GET /api/teacher/grading/submissions
      API-->>Web: List showing pending student essays
      Web->>API: POST /.../{id}/claim
      API-->>Web: 200 OK (Submission locked for grading)
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: TEACHER_DASHBOARD]

---

## 💰 Section 4: Economy & i-Coins (Mobile)

### 4.1 Shop & Balance

Users can purchase i-Coins or exchange them for PRO subscriptions.

- **API Calls**:
  - `GET /api/icoin/balance`: Current wallet balance.
  - `POST /api/subscriptions/purchase`: Spends coins to upgrade account.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `icoin_transactions` | `id` | BIGINT | PK |
  | `icoin_transactions` | `amount` | INT | Coins added/removed |
  | `icoin_transactions` | `type` | VARCHAR | PURCHASE, REWARD, SPEND |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      App->>API: GET /api/icoin/balance
      API-->>App: {balance: 500}
      App->>API: POST /api/subscriptions/purchase {months: 1}
      API-->>App: 200 OK (Account status updated to PRO)
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: ICOIN_SHOP_SCREEN]

---

## 📊 Section 5: Quiz Bank & Exams (Mobile)

### 5.1 Full Mock Exam

Large-scale exam simulations.

- **API Calls**:
  - `GET /api/v1/exams/{id}`: Fetches exam structure and questions.
  - `POST /api/v1/exams/submit`: Submits all answers for final scoring.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `exams` | `id` | BIGINT | PK |
  | `questions` | `exam_id` | BIGINT | FK to Exam |
  | `exam_submissions` | `id` | BIGINT | PK |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      App->>API: GET /api/v1/exams/1
      API-->>App: JSON containing sections (Reading, etc)
      App->>API: POST /api/v1/exams/submit {answers}
      API-->>App: Exam Result (Overall Band Score)
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: FULL_EXAM_ENGINE]

---

## 📖 Section 7: Reading Skill Practice (Mobile)

### 7.1 Reading Passage & Question View

Students read passages and answer multiple-choice, matching, or fill-in-the-gap questions.

- **API Calls**:
  - `GET /api/v1/exams/{id}`: Retrieves the reading exam structure.
  - `GET /api/media/{id}`: Fetches any images embedded in the passage.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `questions` | `content` | TEXT | Passage content or question text |
  | `questions` | `skill` | VARCHAR | Always 'READING' for this section |
  | `questions` | `type` | VARCHAR | MULTIPLE_CHOICE, MATCHING, etc. |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant Nginx as Media Server
      App->>API: GET /api/v1/exams/reading_id
      API-->>App: Exam JSON structure
      App->>Nginx: GET /passages/images/img.png
      Nginx-->>App: Passage Image (Static)
  ```

- **Validation**:
  - Selection: Every question must contain at least one answer attempt.

- **UI Design**: [IMAGE_PLACEHOLDER: READING_PASSAGE_VIEW]

---

## 🎧 Section 8: Listening Skill Practice (Mobile)

### 8.1 Audio Player & Question Tracking

Students listen to audio clips and answer questions in real-time.

- **API Calls**:
  - `GET /api/v1/exams/{id}`: Exam metadata.
  - `GET /api/media/{id}`: Fetches the audio file.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `media_file` | `file_path` | VARCHAR | URL to the .mp3 or .wav file |
  | `media_file` | `context` | VARCHAR | Reference (e.g., 'LISTENING_EXAM_1') |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant Nginx as Media Server
      App->>App: Initialize Audio Controller
      App->>Nginx: GET /uploads/listening/audio_01.mp3
      Nginx-->>App: Audio Stream
      App->>App: Auto-submit after audio ends
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: LISTENING_AUDIO_PLAYER]

---

## 🗣️ Section 9: Speaking Skill Practice (Mobile)

### 9.1 AI-Driven Speaking Prompts

Students practice recorded speaking sessions with AI voice-to-text feedback.

- **API Calls**:
  - `GET /api/speaking/topics`: List of speaking prompts.
  - `POST /api/speaking/submit`: Submits the recording for transcription and analysis.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `speaking_submission` | `audio_url` | VARCHAR | Link to the stored recording |
  | `speaking_submission` | `transcript` | TEXT | AI-generated transcript |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant STT as AI (Speech-to-Text)
      App->>App: Record Voice Sample
      App->>API: POST /api/speaking/submit {audio_file}
      API->>STT: Process Audio
      STT-->>API: Transcript + Fluency Score
      API-->>App: Detailed Result View
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: SPEAKING_PRACTICE_RECORDING]

---

## 📚 Section 10: Vocabulary Builder (Mobile)

### 10.1 Word Dashboard & Search

A searchable list of words with AI-generated definitions and examples.

- **API Calls**:
  - `GET /api/v1/vocabulary`: List of words with pagination.
  - `GET /api/v1/vocabulary/{word}/details`: Fetches AI definitions and synonyms.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `vocabulary_entity` | `id` | BIGINT | PK |
  | `vocabulary_entity` | `word` | VARCHAR | The term being learned |
  | `vocabulary_entity` | `level_group` | VARCHAR | Beginner, Intermediate, Advanced |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant AI as Ollama (Gemma)
      App->>API: GET /api/v1/vocabulary/serendipity/details
      API->>AI: Fetch definition from context
      AI-->>API: Definition, Example, Synonyms
      API-->>App: Word Detail Page
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: VOCABULARY_SEARCH_LIST]

---

## 🧠 Section 11: Smart Test (Student)

### 11.1 AI-Generated Adaptive Testing

Tests that adapt difficulty based on previous student performance.

- **API Calls**:
  - `GET /api/v1/smart-test/generate`: Generates a personalized set of questions.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `user_test_session` | `id` | BIGINT | PK |
  | `user_test_session` | `current_difficulty` | INT | Dynamic level |

- **UI Design**: [IMAGE_PLACEHOLDER: SMART_TEST_INTERFACE]

---

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

---

## 🏆 Section 14: Ranking & Leaderboards (Mobile)

### 14.1 Global and Skill-Specific Rankings

Students can see their rank compared to others based on study points or band scores.

- **API Calls**:
  - `GET /api/v1/ranking/global`: Fetches top students globally.
  - `GET /api/v1/ranking/skill/{skill}`: Ranking for a specific skill (e.g., WRITING).

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `user_stats` | `total_points` | INT | Aggregate study points |
  | `user_stats` | `avg_band_score` | DOUBLE | Mean IELTS score across tests |

- **UI Design**: [IMAGE_PLACEHOLDER: RANKING_LEADERBOARD]

---

## ❓ Section 15: FAQ & Help Center (Mobile)

### 15.1 Frequently Asked Questions

A searchable interface for common platform and IELTS questions.

- **API Calls**:
  - `GET /api/v1/faq`: Returns a list of FAQ categories and items.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `faq` | `question` | VARCHAR | User query |
  | `faq` | `answer` | TEXT | Detailed explanation |
  | `faq` | `category` | VARCHAR | e.g., 'Payment', 'Exam Rules' |

- **UI Design**: [IMAGE_PLACEHOLDER: FAQ_SCREEN]

---

## 🛡️ Section 16: Moderation (Admin Portal)

### 16.1 Content Moderation & Reporting

Administrators review reported content (comments, profiles, or essays).

- **API Calls**:
  - `GET /api/v1/moderation/reports`: List of active reports.
  - `POST /api/v1/moderation/reports/{id}/resolve`: Closes a report case.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `report` | `target_id` | BIGINT | ID of the content being reported |
  | `report` | `reason` | VARCHAR | Spam, Abusive, etc. |
  | `report` | `status` | ENUM | OPEN, RESOLVED, DISMISSED |

- **UI Design**: [IMAGE_PLACEHOLDER: ADMIN_MODERATION_DASHBOARD]

---

## 🔔 Section 17: Notification Center (Mobile)

### 17.1 User and System Alerts

Bell icon menu showing personalized notifications and system announcements.

- **API Calls**:
  - `GET /api/v1/notifications`: List of notifications for the current user.
  - `POST /api/v1/notifications/{id}/read`: Marks a notification as read.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `user_notification` | `title` | VARCHAR | Brief alert title |
  | `user_notification` | `message` | TEXT | Full notification body |
  | `user_notification` | `read` | BIT | Viewed status |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant API as Backend API
      participant FB as Firebase (FCM)
      participant App as Mobile App
      API->>FB: Trigger Push Notification
      FB-->>App: Push Delivery (Background)
      App->>API: GET /api/v1/notifications (On Open)
      API-->>App: List showing new alerts
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: NOTIFICATION_CENTER]

---

> [!IMPORTANT]
> Documentation generated by **Antigravity AI** on April 6, 2026. Last updated: v1.2.
