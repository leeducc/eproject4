@echo off
REM Script to export the eproject4 MySQL database to the database folder

set DB_USER=root
set DB_PASS=12345678
set DB_NAME=eproject4
set HOST=localhost
set PORT=3306
set OUTPUT_DIR=database
set OUTPUT_FILE=%OUTPUT_DIR%\%DB_NAME%_dump.sql

echo =======================================================
echo Exporting MySQL Database: %DB_NAME%
echo Host: %HOST%:%PORT%
echo User: %DB_USER%
echo Destination: %OUTPUT_FILE%
echo =======================================================

if not exist "%OUTPUT_DIR%" (
    echo Creating directory %OUTPUT_DIR%...
    mkdir "%OUTPUT_DIR%"
)

echo Running mysqldump...
mysqldump -h %HOST% -P %PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% > "%OUTPUT_FILE%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Database exported successfully to %OUTPUT_FILE%.
) else (
    echo.
    echo [ERROR] Failed to export database.
    echo Please ensure that MySQL is running and 'mysqldump' is available in your PATH.
)

echo.
pause
