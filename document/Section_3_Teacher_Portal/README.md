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
