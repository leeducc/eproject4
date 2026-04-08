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
