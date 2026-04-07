# 🎧 Instant Tutoring (Speaking Practice) Feature Walkthrough

This update implements the core backend infrastructure for the **Instant Tutoring** feature, enabling real-time 1-1 speaking practice between students (Flutter) and teachers (ReactJS).

## 🌟 Key Features

### 1. Session Lifecycle Management

- **Status Tracking**: Sessions transition through `PENDING`, `ONGOING`, `COMPLETED`, and `CANCELLED`.
- **Timing**: Automatic tracking of start and end times for 30-minute sessions.

### 2. Secure "Hold-Commit-Refund" Coin Mechanism

- **Hold**: When a session starts, the required "Xu" (Coins) are frozen, preventing double-spending while the session is active.
- **Commit**: Upon successful completion, the coins are permanently deducted from the student's balance.
- **Refund**: If a session is cancelled (after being started), the "frozen" coins are returned to the student's available balance.

### 3. Integrated Review & Feedback

- **Public Student Reviews**: Students can rate teachers (1-5 stars), add tags (e.g., "Clear feedback"), and leave public comments.
- **Private Teacher Feedback**: Teachers can provide private, constructive feedback to students to help them improve their speaking skills.

### 4. WebSocket Smart Queue (Real-time Matching)

- **Student Queueing**: Students join an in-memory queue to wait for available teachers.
- **Teacher Availability**: Teachers signal readiness, triggering an immediate match search.
- **Optimized Matching**: The first student in the queue is automatically matched with the first available teacher.
- **Dual Confirmation**: Both parties are notified of a match via WebSocket topics.
- **EWT (Estimated Wait Time)**: Students receive real-time updates on their queue position and estimated waiting time.
- **60s Acceptance Window**: Students have exactly 60 seconds to accept a match before it is voided and the teacher is returned to the pool.

### 5. WebRTC Audio/Video Signaling

- **Signaling Hub**: Spring Boot acts as the intermediary for WebRTC handshakes.
- **Signal Types**: Support for `offer`, `answer`, and `ice-candidate` exchange.
- **Secure Routing**: Signals are routed directly to specific user STOMP queues using `SimpMessagingTemplate.convertAndSendToUser`, ensuring no leakage between tutoring sessions.

## 🛠️ Technical Implementation

### Backend (Spring Boot)

- **Entities**:

  - `TutoringSession`: Core entity managing the relationship between student, teacher, timing, and status.
  - `TutoringReview`: Handles post-session feedback logic.
  - `User`: Extended with `heldICoinBalance` to support the financial holding mechanism.

- **Services**:

  - `TutoringSessionService`: Handles business logic for starting, ending, and cancelling sessions with transactional integrity.
  - `ICoinService`: Extended with `holdCoins`, `commitHeldCoins`, and `refundHeldCoins` to manage session-related transactions.
  - `TutoringQueueService`: Manages in-memory queues, matching logic, and 60-second confirmation timeouts.

- **Controller**:

  - `TutoringController`: Provides REST API endpoints for session management and review submission.
  - `TutoringWebSocketController`: STOMP endpoints for queue joining, teacher status reporting, and match acceptance.
  - `TutoringWebRtcController`: Handles the end-to-end signaling (SDP/ICE) for P2P connection establishment.

- **Event Listeners**:

  - `WebSocketEventListener`: Automatically cleans up the queue when users disconnect.

## 🚀 Future Improvements & Suggestions

- **WebSocket Signaling**: Implement the signaling logic to alert teachers in real-time when a "Speaking Screen" call is initiated from Flutter.
- **Session Expiry**: Add a background task (Scheduled) to automatically `CANCEL` or `COMPLETE` sessions that exceed the 30-minute limit.
- **Teacher Availability**: Implement a "Duty Status" for teachers (Online/Offline/Busy) to prevent students from calling teachers who aren't ready.
- **Media Recording**: Integrate AWS S3 or a media server to record session audio/video for later review by students.
- **Advanced Payment Distribution**: Implement logic to credit the teacher's wallet (e.g., in USD or credit points) after a session is `COMPLETED`.
- **Push Notifications**: Integrate Firebase Cloud Messaging (FCM) to notify students when a teacher accepts their tutoring request.

---

> [!IMPORTANT]
> All coin transactions are wrapped in `@Transactional` blocks to ensure data consistency. Any failure during the "Commit" or "Refund" phase will roll back changes to maintain the integrity of the user's balance.
