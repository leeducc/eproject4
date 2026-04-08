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
