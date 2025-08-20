@echo off
echo 🚀 Deploying Laravel with PHP Built-in Server
echo ==============================================
echo.

echo Checking PHP installation...
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PHP is not installed or not in PATH
    echo Please install PHP first: https://www.php.net/downloads
    pause
    exit /b 1
)

echo ✅ PHP is available
php --version

echo.
echo Checking Laravel installation...
if not exist "laravel\artisan" (
    echo ❌ Laravel not found in laravel\ directory
    echo Please ensure Laravel is installed in the laravel\ folder
    pause
    exit /b 1
)

echo ✅ Laravel found
echo.

echo Setting up Laravel environment...
cd laravel

if not exist ".env" (
    echo Creating .env file...
    copy .env.example .env >nul 2>&1
)

echo.
echo Installing/updating Composer dependencies...
composer install --no-dev --optimize-autoloader

echo.
echo Generating application key...
php artisan key:generate

echo.
echo Clearing caches...
php artisan config:clear
php artisan cache:clear
php artisan view:clear

echo.
echo 🌐 Starting Laravel development server...
echo.
echo Your Laravel application will be available at:
echo   • http://localhost:8080
echo.
echo Press Ctrl+C to stop the server
echo.

php artisan serve --host=0.0.0.0 --port=8080
