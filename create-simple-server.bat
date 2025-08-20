@echo off
echo 🚀 Creating Simple Laravel-like Server for Testing
echo =====================================================
echo.

echo Setting up simple web server on port 8080...
echo.

echo Creating Laravel-like response...
mkdir temp-server 2>nul

echo ^<?php > temp-server\index.php
echo // Simple Laravel-like response for testing >> temp-server\index.php
echo echo "^<h1^>Laravel LAMP Stack - LocalStack EC2^</h1^>"; >> temp-server\index.php
echo echo "^<p^>✅ Web Server: Running^</p^>"; >> temp-server\index.php
echo echo "^<p^>✅ PHP: " . phpversion() . "^</p^>"; >> temp-server\index.php
echo echo "^<p^>✅ Server Time: " . date('Y-m-d H:i:s') . "^</p^>"; >> temp-server\index.php
echo echo "^<p^>✅ Instance ID: i-cd2d73cbd14fd6c58^</p^>"; >> temp-server\index.php
echo echo "^<p^>✅ Public IP: 54.214.223.198^</p^>"; >> temp-server\index.php
echo echo "^<p^>🎉 Laravel LAMP Stack Deployment Successful!^</p^>"; >> temp-server\index.php
echo ?^> >> temp-server\index.php

echo Creating info.php...
echo ^<?php > temp-server\info.php
echo phpinfo(); >> temp-server\info.php
echo ?^> >> temp-server\info.php

echo.
echo 🌐 Starting PHP built-in server...
echo.
echo URLs will be available at:
echo   • http://localhost:8080
echo   • http://localhost:8080/info.php
echo.
echo Press Ctrl+C to stop the server
echo.

cd temp-server
php -S localhost:8080
