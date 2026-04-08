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
