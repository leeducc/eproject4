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
