# Project Structure Tree

```text
.
├── README.md
├── backend/
│   ├── HELP.md
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── groupone/
│                       └── backend/
│                           ├── BackendApplication.java
│                           ├── config/
│                           │   ├── DataSeeder.java
│                           │   ├── GlobalExceptionHandler.java
│                           │   └── SecurityConfig.java
│                           ├── features/
│                           │   ├── icoin/
│                           │   │   ├── AdminICoinController.java
│                           │   │   ├── ICoinController.java
│                           │   │   ├── ICoinService.java
│                           │   │   ├── ICoinTransaction.java
│                           │   │   ├── ICoinTransactionRepository.java
│                           │   │   ├── InsufficientICoinException.java
│                           │   │   ├── TransactionType.java
│                           │   │   └── dto/
│                           │   │       ├── AdminICoinRequest.java
│                           │   │       ├── ICoinBalanceResponse.java
│                           │   │       └── TransactionResponse.md
│                           │   ├── identity/
│                           │   │   ├── User.java
│                           │   │   ├── UserProfile.java
│                           │   │   ├── UserProfileRepository.java
│                           │   │   ├── UserRepository.java
│                           │   │   ├── auth/
│                           │   │   │   ├── AuthService.java
│                           │   │   │   ├── CaptchaVerificationService.java
│                           │   │   │   ├── EmailService.java
│                           │   │   │   └── OtpCacheService.java
│                           │   │   ├── dto/
│                           │   │   │   ├── AuthResponse.java
│                           │   │   │   ├── GoogleLoginRequest.java
│                           │   │   │   ├── LoginRequest.java
│                           │   │   │   ├── RegisterRequest.java
│                           │   │   │   ├── ResetPasswordRequest.java
│                           │   │   │   └── SendOtpRequest.java
│                           │   │   ├── forgotpassword/
│                           │   │   │   └── ForgotPasswordController.java
│                           │   │   ├── login/
│                           │   │   │   └── LoginController.java
│                           │   │   └── register/
│                           │   │       └── RegisterController.java
│                           │   ├── media/
│                           │   │   ├── MediaController.java
│                           │   │   ├── MediaFile.java
│                           │   │   ├── MediaFileRepository.java
│                           │   │   └── MediaService.java
│                           │   └── quizbank/
│                           │       ├── controller/
│                           │       │   ├── ExamController.java
│                           │       │   └── QuestionBankController.java
│                           │       ├── dto/
│                           │       │   ├── ExamRequest.java
│                           │       │   ├── ExamResponse.java
│                           │       │   ├── QuestionRequest.java
│                           │       │   └── QuestionResponse.java
│                           │       ├── entity/
│                           │       │   ├── Exam.java
│                           │       │   └── Question.java
│                           │       └── enums/
│                           │           ├── DifficultyBand.java
│                           │           ├── ExamType.java
│                           │           └── QuestionType.java
│                           └── shared/
├── database/
├── export_database.bat
├── frontend-web/
│   ├── apps/
│   │   ├── admin/
│   │   │   ├── index.html
│   │   │   ├── package.json
│   │   │   └── src/
│   │   │       ├── App.tsx
│   │   │       ├── features/
│   │   │       ├── index.css
│   │   │       ├── main.tsx
│   │   │       └── pages/
│   │   └── teacher/
│   │       ├── index.html
│   │       ├── package.json
│   │       └── src/
│   │           ├── App.tsx
│   │           ├── index.css
│   │           ├── main.tsx
│   │           └── pages/
│   ├── package.json
│   └── packages/
│       ├── api/
│       │   ├── package.json
│       │   └── src/
│       ├── config/
│       ├── types/
│       └── ui/
│           ├── package.json
│           └── src/
├── mobile-desktop/
│   ├── README.md
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   ├── data/
│   │   │   └── services/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── main_layout/
│   │   │   ├── profile/
│   │   │   └── study_sections/
│   │   │       ├── listening/
│   │   │       ├── reading/
│   │   │       ├── real_exam/
│   │   │       ├── simulate_exam/
│   │   │       ├── speaking/
│   │   │       ├── vocabulary/
│   │   │       ├── writing/
│   │   │       │   ├── models/
│   │   │       │   ├── screens/
│   │   │       │   └── services/
│   │   │       └── wrong_answers/
│   │   └── main.dart
│   ├── linux/
│   ├── macos/
│   ├── pubspec.yaml
│   ├── test/
│   ├── web/
│   └── windows/
├── nginx/
│   └── nginx.conf
└── run_all.bat
```
