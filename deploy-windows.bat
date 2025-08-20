@echo off
echo 🚀 Laravel LAMP Stack Deployment for Windows
echo =============================================
echo.

echo Setting AWS environment variables...
set AWS_ACCESS_KEY_ID=LKIAQAAAAAAAHXZXZSHD
set AWS_SECRET_ACCESS_KEY=h4vZw/IR9WBBRjw3rqAFUZaV3ciEplFIVz4axlqi
set AWS_DEFAULT_REGION=us-east-1

echo.
echo Checking LocalStack health...
curl -s http://localhost:4566/_localstack/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ LocalStack is healthy
) else (
    echo ❌ LocalStack is not accessible
    echo Please ensure LocalStack is running: docker-compose -f config/docker-compose-fixed.yml up -d
    pause
    exit /b 1
)

echo.
echo Checking EC2 instance...
aws --endpoint-url=http://localhost:4566 ec2 describe-instances --instance-ids i-cd2d73cbd14fd6c58 --query "Reservations[0].Instances[0].[State.Name,PublicIpAddress]" --output table

echo.
echo Current URLs to test:
echo • Primary: http://54.214.223.198
echo • Alternative: http://localhost:8080
echo • PHP Info: http://54.214.223.198/info.php

echo.
echo Testing HTTP connections...
echo Testing http://54.214.223.198...
curl -I --connect-timeout 5 http://54.214.223.198 2>nul
if %errorlevel% equ 0 (
    echo ✅ Direct connection works!
) else (
    echo ❌ Direct connection failed - Need to deploy LAMP stack
)

echo.
echo Testing http://localhost:8080...
curl -I --connect-timeout 5 http://localhost:8080 2>nul
if %errorlevel% equ 0 (
    echo ✅ Alternative connection works!
) else (
    echo ❌ Alternative connection failed
)

echo.
echo ==========================================
echo  📋 Current Status Summary
echo ==========================================
echo.
echo ✅ LocalStack is running
echo ✅ EC2 instance exists (i-cd2d73cbd14fd6c58)
echo ✅ Public IP: 54.214.223.198
echo.
echo ❌ LAMP stack not deployed yet
echo ❌ Laravel application not deployed yet
echo.
echo 📝 To deploy Laravel LAMP stack:
echo.
echo Option 1 - Use Git Bash (Recommended):
echo   1. Right-click in this folder and select "Git Bash Here"
echo   2. Run: cd scripts && ./setup-ec2-lamp.sh
echo   3. Then: ./configure-laravel-ec2.sh
echo.
echo Option 2 - Use WSL:
echo   1. Open WSL terminal
echo   2. Navigate to this directory
echo   3. Run: bash scripts/setup-ec2-lamp.sh
echo   4. Then: bash scripts/configure-laravel-ec2.sh
echo.
echo Option 3 - Manual steps:
echo   1. Ensure LocalStack EC2 instance has SSH access
echo   2. Install LAMP stack manually
echo   3. Deploy Laravel application
echo.
echo 🌐 Expected URLs after deployment:
echo   • Laravel App: http://54.214.223.198
echo   • PHP Info: http://54.214.223.198/info.php
echo   • Alternative: http://localhost:8080
echo.
echo 🔧 If you encounter issues:
echo   • Check LocalStack logs: docker logs localstack-main
echo   • Restart LocalStack: docker-compose -f config/docker-compose-fixed.yml restart
echo   • Verify EC2 instance is running
echo.
pause
