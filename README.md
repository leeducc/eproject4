# IELTS Learning Platform

This project is a comprehensive application for IELTS preparation, serving three types of users:
1. **Customers**: Use the Flutter mobile app to learn, practice, and take exams.
2. **Teachers**: Use the React web app to upload learning content and grade student submissions.
3. **Admins**: Manage the platform, users, and view reports.

## Backend Architecture Design: IELTS App (Vertical Slice)

This project utilizes a **Vertical Slice Architecture** for the Spring Boot backend. Code is grouped by feature/use-case rather than technical concern (e.g., all controllers in one folder).

### Folder Structure

```text
src/main/java/com/yourcompany/ieltsapp/
├── IeltsAppApplication.java
├── config/                 # Global configurations (Security, Swagger, WebMvc, Database)
├── shared/                 # Shared components used across multiple slices
│   ├── exception/          # Global error handling & custom exceptions
│   ├── utility/            # Shared helpers (e.g., File upload utils, JWT, Time formatting)
│   ├── domain/             # Shared base entities (e.g., BaseEntity with createdAt, updatedAt)
│   └── enums/              # Shared Enums (e.g., BandScore, UserRole, QuestionType)
│
└── features/               # 🌟 THE VERTICAL SLICES 🌟
    │
    ├── identity/           # Authentication & User Management
    │   ├── login/
    │   ├── register/
    │   └── usermanagement/ # Admin managing customers and teachers
    │
    ├── listening/          # Listening Section (Level-Based Questions)
    │   ├── manage_content/ # Teacher/Admin: Upload audio, define questions by Level (0-4, 5-6, etc.)
    │   ├── take_practice/  # Customer: Fetch questions matching their level, submit answers
    │   └── auto_grade/     # System: Automatically score objective listening tests
    │
    ├── reading/            # Reading Section (Level-Based Questions)
    │   ├── manage_content/ # Teacher/Admin: Upload passages, define questions by Level
    │   ├── take_practice/  # Customer: Fetch passages matching their level, submit answers
    │   └── auto_grade/     # System: Automatically score objective reading tests
    │
    ├── speaking/           # Speaking Section (Prompt & Review)
    │   ├── manage_prompts/ # Teacher: Create speaking topics/prompts
    │   ├── submit_audio/   # Customer: Receive prompt, record & upload audio answer
    │   └── grade_speaking/ # Teacher/AI: Listen to audio, submit band score and feedback
    │
    ├── writing/            # Writing Section (Prompt & Review)
    │   ├── manage_prompts/ # Teacher: Create writing topics/prompts (Task 1 & Task 2)
    │   ├── submit_essay/   # Customer: Receive prompt, type & submit essay
    │   └── grade_writing/  # Teacher/AI: Review essay, submit band score and detailed feedback
    │
    ├── vocabulary/         # Vocabulary Learning (Level-Gated, Uniform Content)
    │   ├── manage_vocab/   # Teacher/Admin: Upload word lists, definitions, examples, assign to levels
    │   └── learn_session/  # Customer: Learn vocab available at their current level (spaced repetition)
    │
    ├── full_exams/         # Real & Simulated Exams (Timed, 4-Skills)
    │   ├── manage_exams/   # Admin/Teacher: Assemble full exam configurations (Reading + Listening + Writing + Speaking)
    │   ├── take_exam/      # Customer: Start timed exam session, submit across 4 skills
    │   └── view_results/   # Customer/Teacher: View aggregated band scores across the 4 skills
    │
    ├── wrong_answers/      # Mistake Tracking & Review
    │   ├── log_mistake/    # Internal Event: Triggered when auto_grade or teacher marks an answer wrong
    │   └── review_bank/    # Customer: Fetch personalized list of past wrong answers to restudy
    │
    └── statistics/         # Admin Reports & Analytics
        ├── user_progress/  # Admin/Teacher: View customer improvement over time
        └── site_usage/     # Admin: View overall platform metrics
```

### Key Design Highlights

1.  **Role-Based Access Control (RBAC):** Slices naturally align with user roles, making security implementation straightforward (e.g., Teacher slices vs. Customer slices).
2.  **Unified Management within Slices:** For Reading and Listening, the `manage_content` slice handles attaching a "Target Band Level" (0-4, 5-6, 7-8, 9) to specific questions or passages.
3.  **Shared Workflow for Speaking & Writing:** Speaking and Writing share the same meta-workflow (`manage_prompts` -> `submit_task` -> `grade_task`), ensuring a consistent workflow for both text (essays) and audio (speaking) submissions.
4.  **Vocabulary Simplification:** The `manage_vocab` slice tags vocab lists by level, but the `learn_session` slice provides the identical set of questions for that vocab list to all users who have unlocked that level.
5.  **Full Exams Orchestration:** The `full_exams` feature is distinct from individual practice sections and acts as an orchestrator managing global timers and sequentially routing the user through the 4 skills.
