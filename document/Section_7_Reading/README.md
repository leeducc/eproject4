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
