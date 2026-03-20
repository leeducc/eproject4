# Backend API Endpoints Documentation

This document lists all the backend API endpoints, their HTTP methods, description, and request/response payloads.

## Authentication & Identity

### Send OTP (Register)

- **Endpoint**: `/api/auth/register/send-otp`
- **Method**: `POST`
- **Description**: Sends a verification code to the provided email.
- **Request Payload**:

  ```json
  {
    "email": "string",
    "captchaToken": "string"
  }
  ```

- **Response**: `200 OK` (Verification code sent to email.) or `400 Bad Request`

### Register

- **Endpoint**: `/api/auth/register`
- **Method**: `POST`
- **Description**: Registers a new user.
- **Request Payload**:

  ```json
  {
    "email": "string",
    "password": "string",
    "code": "string"
  }
  ```

- **Response**: `200 OK` (Registration successful. You can now login.) or `400 Bad Request`

### Login

- **Endpoint**: `/api/auth/login`
- **Method**: `POST`
- **Description**: Authenticates a user and returns a JWT token.
- **Request Payload**:

  ```json
  {
    "email": "string",
    "password": "string",
    "role": "string" (optional: CUSTOMER, TEACHER, ADMIN)
  }
  ```

- **Response**: `200 OK`

  ```json
  {
    "id": 1,
    "token": "jwt_token",
    "email": "user@example.com",
    "role": "CUSTOMER",
    "fullName": "Full Name",
    "isPro": false
  }
  ```

### Google Login

- **Endpoint**: `/api/auth/login/google`
- **Method**: `POST`
- **Description**: Authenticates a user using Google ID Token.
- **Request Payload**:

  ```json
  {
    "idToken": "google_id_token"
  }
  ```

- **Response**: `200 OK` (same as login response)

### Forgot Password - Send OTP

- **Endpoint**: `/api/auth/forgot-password/send-otp`
- **Method**: `POST`
- **Description**: Sends a reset password code to the email.
- **Request Payload**:

  ```json
  {
    "email": "string",
    "captchaToken": "string"
  }
  ```

- **Response**: `200 OK`

### Reset Password

- **Endpoint**: `/api/auth/forgot-password/reset`
- **Method**: `POST`
- **Description**: Resets the password using the verification code.
- **Request Payload**:

  ```json
  {
    "email": "string",
    "code": "string",
    "newPassword": "string"
  }
  ```

- **Response**: `200 OK`

---

## Writing & Grading

### Get Topics

- **Endpoint**: `/api/writing/topics`
- **Method**: `GET`
- **Description**: Retrieves all writing topics.
- **Response**: `200 OK` (List of TopicResponse)

### Submit Essay

- **Endpoint**: `/api/writing/submit`
- **Method**: `POST`
- **Description**: Submits an essay for grading (AI or Human).
- **Request Payload**:

  ```json
  {
    "topicId": 1,
    "content": "essay content",
    "gradingType": "AI" (or HUMAN)
  }
  ```

- **Response**: `200 OK` (EssaySubmissionResponse)

### Get All Submissions (Teacher)

- **Endpoint**: `/api/teacher/grading/submissions`
- **Method**: `GET`
- **Description**: Retrieves all submissions for grading.
- **Response**: `200 OK` (List of SubmissionSummaryResponse)

### Claim Submission

- **Endpoint**: `/api/teacher/grading/submissions/{id}/claim`
- **Method**: `POST`
- **Description**: Claims a submission for grading.
- **Response**: `200 OK` (SubmissionSummaryResponse)

### Unclaim Submission

- **Endpoint**: `/api/teacher/grading/submissions/{id}/unclaim`
- **Method**: `POST`
- **Description**: Unclaims a submission.
- **Response**: `200 OK` (SubmissionSummaryResponse)

### Submit Grade

- **Endpoint**: `/api/teacher/grading/submissions/{id}/grade`
- **Method**: `POST`
- **Description**: Submits a grade for a submission.
- **Request Payload**: (GradingRequest)
- **Response**: `200 OK` (SubmissionSummaryResponse)

---

## Quiz Bank (Exams & Questions)

### Get All Exams

- **Endpoint**: `/api/v1/exams`
- **Method**: `GET`
- **Response**: `200 OK` (List of ExamResponse)

### Create Exam

- **Endpoint**: `/api/v1/exams`
- **Method**: `POST`
- **Request Payload**: (ExamRequest)
- **Response**: `200 OK` (ExamResponse)

### Get Questions (Paginated)

- **Endpoint**: `/api/v1/questions/paginated`
- **Method**: `GET`
- **Params**: `skill`, `type`, `difficulty`, `search`, `lastSeenId`, `limit`
- **Response**: `200 OK` (PaginatedResponse of QuestionResponse)

---

## Vocabulary

### Get Vocabulary (Paginated)

- **Endpoint**: `/api/v1/vocabulary`
- **Method**: `GET`
- **Description**: Retrieves a paginated list of vocabulary words or phrases.
- **Params**: `type` (words/phrases), `levelGroup`, `search`, `lastSeenId`, `limit`
- **Response**: `200 OK` (PaginatedResponse of VocabularyItem)

### Generate Word Details (AI)

- **Endpoint**: `/api/v1/vocabulary/{word}/details`
- **Method**: `GET`
- **Description**: Generates a detailed definition, example sentences, and synonyms using AI.
- **Response**: `200 OK` (VocabularyDetail)

### Generate Word Practice (AI)

- **Endpoint**: `/api/v1/vocabulary/{word}/practice`
- **Method**: `GET`
- **Description**: Generates a random practice quiz (Multiple Choice or Fill In The Blank) using AI.
- **Response**: `200 OK` (PracticeQuiz)

### Ensure AI Content

- **Endpoint**: `/api/v1/vocabulary/{word}/ensure-ai-content`
- **Method**: `POST`
- **Description**: Proactively generates AI details and a set of practice quizzes for a word.
- **Response**: `200 OK`

### Get Vocabulary History

- **Endpoint**: `/api/v1/vocabulary/{id}/history`
- **Method**: `GET`
- **Description**: Retrieves the edit history for a specific vocabulary item.
- **Response**: `200 OK` (List of VocabularyHistoryDTO)

### Rollback Vocabulary

- **Endpoint**: `/api/v1/vocabulary/history/{historyId}/rollback`
- **Method**: `POST`
- **Description**: Rolls back a vocabulary item to a previous version.
- **Response**: `200 OK`

### Import Vocabulary (Excel)

- **Endpoint**: `/api/v1/vocabulary/import`
- **Method**: `POST`
- **Description**: Imports vocabulary items from an Excel file.
- **Request**: `MultipartFile` file.
- **Response**: `200 OK` (Import status and count)

---

## ICoin & Subscriptions

### Get Balance

- **Endpoint**: `/api/icoin/balance`
- **Method**: `GET`
- **Response**: `200 OK` (ICoinBalanceResponse)

### Purchase Pro

- **Endpoint**: `/api/subscriptions/purchase`
- **Method**: `POST`
- **Request Payload**:

  ```json
  {
    "months": 1,
    "priceICoins": 100
  }
  ```

- **Response**: `200 OK`

---

## Media

### Upload Media

- **Endpoint**: `/api/media/upload`
- **Method**: `POST`
- **Request**: `MultipartFile` file, optional `context` string.
- **Response**: `200 OK` (MediaFile object)
