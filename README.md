# IELTS Learning Platform

A comprehensive IELTS preparation platform with three primary interfaces:

- **Mobile & Desktop (Flutter)**: For students (Customers) to study and take exams.
- **Admin Portal (React)**: For platform management and reporting.
- **Teacher Portal (React)**: For content creation and grading.

---

## 📂 Project Structure

```text
eproject4/
├── backend/                # Spring Boot Backend (Vertical Slice Architecture)
├── frontend-web/           # Turborepo containing React Applications
│   ├── apps/
│   │   ├── admin/          # Admin Dashboard
│   │   └── teacher/        # Teacher Management Interface
│   └── packages/           # Shared UI components and logic
├── mobile-desktop/         # Flutter Mobile and Desktop Application
├── database/               # Database SQL dumps and export scripts
├── nginx/                  # Nginx configuration for deployment
└── run_all.bat             # Batch script to start core services
```

---

## 🛠️ Prerequisites

Ensure you have the following installed:

- **Java 17+** (for Backend)
- **MySQL 8.0+**
- **Node.js 20+** & **npm** (for Web Frontend)
- **Flutter SDK** (for Mobile/Desktop)
- **Docker & Docker Compose** (for serving Media via Nginx)
- **Ollama** (for AI features, optional but recommended)

---

## ⚙️ Environment Configuration

You will need to set up the following configuration files before running the project.

### 1. Backend (`backend/src/main/resources/application.properties`)

Configure your database and external services:

- `spring.datasource.url`: JDBC URL for your MySQL instance.
- `spring.datasource.username` & `password`: Your MySQL credentials.
- `spring.mail.*`: SMTP settings for email notifications.
- `recaptcha.secret.key`: Google reCAPTCHA v2 secret key.
- `jwt.secret`: Secret key for JWT token generation.
- `google.client.id`: Google OAuth2 Client ID for authentication.

### 2. Flutter App (`mobile-desktop/.env`)

Create a `.env` file in the `mobile-desktop` directory with the following keys:

```env
API_BASE_URL=http://localhost:8080/api
GOOGLE_SERVER_CLIENT_ID=your_google_server_client_id
GOOGLE_CLIENT_ID=your_google_client_id
```

*(Note: Use `10.0.2.2` instead of `localhost` if running on an Android Emulator)*

---

## 🚀 How to Run

### Quick Start (Windows)

You can start the Backend, Web Frontends, and Ollama AI model using the provided batch script:

```bash
./run_all.bat
```

### Manual Start

#### 1. Database Setup

1. Create a database named `eproject4` in MySQL.
2. Import the SQL dump located at `database/eproject4_dump.sql`.

#### 2. Start Backend

```bash
cd backend
./mvnw spring-boot:run
```

#### 3. Start Web Portals (Admin & Teacher)

```bash
cd frontend-web
npm install
npm run dev
```

The apps will typically be available at `http://localhost:3000` (Admin) and `http://localhost:3001` (Teacher), depending on port availability.

#### 4. Start Mobile/Desktop App

```bash
cd mobile-desktop
flutter pub get
flutter run
```

#### 5. Start Media Server (Nginx via Docker)

The platform uses Nginx via Docker to serve user-uploaded media files (images, audio, video) quickly and efficiently, directly from the host machine without taxing the Spring Boot backend.

1. Ensure **Docker Desktop** is installed and running on your system.
2. In the root directory (`eproject4/`), run the following command to build and start the Nginx container:

```bash
docker-compose up -d
```

3. This creates a volume mount mapping the `./backend/uploads` folder to Nginx, making uploaded media available publicly under `http://localhost/...`. Note that `docker-compose.yml` typically binds Nginx to port 80.

#### 6. Start AI Service (Ollama)

The platform uses fine-tuned models for grading and feedback.

```bash
ollama run gemma3:4b
```

---

## 🏗️ Backend Architecture

The backend follows a **Vertical Slice Architecture**. Code is organized by feature rather than layer, making it easier to maintain and scale individual functionalities (e.g., Reading, Writing, Listening slices).

- **`features/`**: Contains the core logic for each functional slice (Controller, Service, Entity, Repository).
- **`shared/`**: Contains common utilities, exceptions, and global configurations.
- **`config/`**: Global system settings (Security, Database, etc.).

---

## 🎨 Frontend (Web) Architecture

The web frontend is managed as a **Turborepo Monorepo**, ensuring consistency and shared logic across different portals.

- **`apps/`**: Contains standalone React applications.
    - `admin/`: Portal for platform administrators.
    - `teacher/`: Portal for content creators and graders.
- **`packages/`**: Shared libraries used by the applications.
    - `api/`: Centralized API service layer.
    - `ui/`: Design system and common UI components.
    - `types/`: Shared TypeScript interfaces and enums.
- **Feature-Based Design**: Each app organizes its logic into `features/` (logic & state) and `pages/` (routing & layout).

---

## 📱 Mobile & Desktop Architecture

The Flutter application utilizes a **Modular Layered Architecture** to handle high complexity across mobile and desktop platforms.

- **`lib/features/`**: Functional modules (Auth, Home, Study Sections, Profile). Each feature is self-contained.
- **`lib/data/`**: Data layer managing API services and local storage.
- **`lib/core/`**: Shared infrastructure including constants, global providers, and reusable widgets.
- **State Management**: Uses a reactive pattern (Providers) to ensure consistent data flow across the UI.

