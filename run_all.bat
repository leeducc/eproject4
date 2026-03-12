@echo off
echo Starting Project Components...

echo Starting Spring Boot Backend...
:: Using start to open a new command prompt window for the backend
start "Spring Backend" cmd /c "cd backend\backend && ./mvnw spring-boot:run"

echo Starting React Frontend...
:: Start React web app
start "React Frontend" cmd /c "cd frontend-web && npm run dev"

:: ollama run gemma3:4b
echo start ollama Ai model api
Start "Ollama" cmd /c "ollama run gemma3:4b"

echo start nginx
start "Nginx" cmd /c "docker-compose up -d --build"

echo All components started!
