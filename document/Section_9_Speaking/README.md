## 🗣️ Section 9: Speaking Skill Practice (Mobile)

### 9.1 1-1 Speaking Tutoring

Students connect with IELTS specialists for real-time speaking practice and feedback.

- **API Calls**:
  - `GET /api/tutoring/slots/available-teachers`: List of teachers with open tutoring slots.
  - `POST /api/tutoring/slots/student/book/{slotId}`: Reserves a specific time slot for a session.
  - `WS /ws-chat/websocket`: Real-time signaling for WebRTC and queue management.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `teacher_slots` | `id` | BIGINT | PK |
  | `teacher_slots` | `start_time` | DATETIME | Slot start time |
  | `teacher_slots` | `status` | ENUM | AVAILABLE, BOOKED, CANCELLED, COMPLETED, ONGOING |
  | `tutoring_sessions` | `coin_amount` | INT | Cost of the session in i-Coins |
  | `tutoring_reviews` | `rating` | INT | Student satisfaction score (1-5) |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant Student as Mobile App
      participant API as Spring Boot API
      participant Teacher as Teacher App/Web
      
      Student->>API: GET /api/tutoring/slots/available-teachers
      API-->>Student: List<TeacherProfile>
      Student->>API: POST /api/tutoring/slots/student/book/{id}
      API-->>Student: 200 OK (Slot Reserved)
      
      Note over Student, Teacher: At scheduled time
      Student->>API: WS Connect (Queue/RTC)
      Teacher->>API: WS Connect (Queue/RTC)
      API-->>Student: Match Found (Room ID)
      Student->>Teacher: WebRTC Handshake (P2P Call)
      Teacher-->>Student: Audio/Video Stream
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: SPEAKING_TUTOR_LIST]
