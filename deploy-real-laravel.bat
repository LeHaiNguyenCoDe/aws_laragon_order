@echo off
echo 🚀 Deploying Real Laravel LAMP Stack
echo =====================================
echo.

echo 🐳 Creating Laravel LAMP Stack with Docker...
echo.

echo Step 1: Stopping any existing containers...
docker stop laravel-lamp 2>nul
docker rm laravel-lamp 2>nul

echo.
echo Step 2: Creating Laravel container with Apache + PHP...
docker run -d ^
  --name laravel-lamp ^
  -p 8080:80 ^
  -v "%CD%\laravel:/var/www/html" ^
  php:8.1-apache

echo.
echo Step 3: Installing Laravel dependencies in container...
docker exec laravel-lamp bash -c "apt-get update && apt-get install -y libzip-dev zip unzip git"
docker exec laravel-lamp bash -c "docker-php-ext-install zip pdo pdo_mysql"
docker exec laravel-lamp bash -c "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"

echo.
echo Step 4: Configuring Apache for Laravel...
docker exec laravel-lamp bash -c "echo '<VirtualHost *:80>
    DocumentRoot /var/www/html/public
    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf"

docker exec laravel-lamp bash -c "a2enmod rewrite"
docker exec laravel-lamp bash -c "service apache2 restart"

echo.
echo Step 5: Setting permissions...
docker exec laravel-lamp bash -c "chown -R www-data:www-data /var/www/html"
docker exec laravel-lamp bash -c "chmod -R 755 /var/www/html/storage"
docker exec laravel-lamp bash -c "chmod -R 755 /var/www/html/bootstrap/cache"

echo.
echo ✅ Laravel LAMP Stack deployed successfully!
echo.
echo 🌐 Your Laravel application is now running at:
echo   • http://localhost:8080
echo.
echo 🔧 Container info:
echo   • Container name: laravel-lamp
echo   • PHP version: 8.1
echo   • Web server: Apache
echo   • Document root: /var/www/html/public
echo.
echo 📋 Useful commands:
echo   • View logs: docker logs laravel-lamp
echo   • Access container: docker exec -it laravel-lamp bash
echo   • Stop container: docker stop laravel-lamp
echo   • Remove container: docker rm laravel-lamp
echo.
echo 🧪 Testing the deployment...
timeout /t 5 /nobreak >nul
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080' -TimeoutSec 10; Write-Host '✅ HTTP Status:' $response.StatusCode; Write-Host '✅ Laravel is accessible!' } catch { Write-Host '❌ Test failed:' $_.Exception.Message }"

echo.
pause
