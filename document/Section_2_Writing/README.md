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
