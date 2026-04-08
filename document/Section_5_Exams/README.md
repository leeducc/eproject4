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
