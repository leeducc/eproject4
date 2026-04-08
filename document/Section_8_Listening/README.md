## 🎧 Section 8: Listening Skill Practice (Mobile)

### 8.1 Audio Player & Question Tracking

Students listen to audio clips and answer questions in real-time.

- **API Calls**:
  - `GET /api/v1/exams/{id}`: Exam metadata.
  - `GET /api/media/{id}`: Fetches the audio file.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `media_file` | `file_path` | VARCHAR | URL to the .mp3 or .wav file |
  | `media_file` | `context` | VARCHAR | Reference (e.g., 'LISTENING_EXAM_1') |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant Nginx as Media Server
      App->>App: Initialize Audio Controller
      App->>Nginx: GET /uploads/listening/audio_01.mp3
      Nginx-->>App: Audio Stream
      App->>App: Auto-submit after audio ends
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: LISTENING_AUDIO_PLAYER]
