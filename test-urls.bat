@echo off
echo 🔍 Testing Laravel Application URLs
echo ===================================
echo.

echo Current URLs to test:
echo • Primary: http://54.214.223.198
echo • Alternative: http://localhost:8080
echo • PHP Info: http://54.214.223.198/info.php
echo.

echo Testing connections...
echo.

echo 1. Testing primary URL: http://54.214.223.198
curl -I --connect-timeout 10 http://54.214.223.198
echo.

echo 2. Testing alternative URL: http://localhost:8080
curl -I --connect-timeout 10 http://localhost:8080
echo.

echo 3. Testing PHP info: http://54.214.223.198/info.php
curl -I --connect-timeout 10 http://54.214.223.198/info.php
echo.

echo ===================================
echo 📋 Summary:
echo.
echo If all URLs return HTTP 200 OK:
echo ✅ Laravel application is working!
echo.
echo If URLs return connection errors:
echo ❌ Need to deploy LAMP stack first
echo.
echo 🚀 To deploy:
echo 1. Use Git Bash: Right-click → "Git Bash Here"
echo 2. Run: cd scripts && ./setup-ec2-lamp.sh
echo 3. Then: ./configure-laravel-ec2.sh
echo.
pause
