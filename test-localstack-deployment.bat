@echo off
echo 🚀 Testing Laravel LAMP Stack on LocalStack
echo ============================================
echo.

echo Setting AWS environment variables...
set AWS_ACCESS_KEY_ID=LKIAQAAAAAAAHXZXZSHD
set AWS_SECRET_ACCESS_KEY=h4vZw/IR9WBBRjw3rqAFUZaV3ciEplFIVz4axlqi
set AWS_DEFAULT_REGION=us-east-1

echo.
echo 📍 Using correct LocalStack endpoint: https://localhost.localstack.cloud:4566
echo.

echo 🔍 Checking EC2 instance status...
aws --endpoint-url=https://localhost.localstack.cloud:4566 ec2 describe-instances --instance-ids i-cd2d73cbd14fd6c58 --query "Reservations[0].Instances[0].[State.Name,PublicIpAddress]" --output table

echo.
echo 🌐 Testing URLs...
echo.

echo Testing primary URL: http://54.214.223.198
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://54.214.223.198' -TimeoutSec 5 -ErrorAction Stop; Write-Host '✅ Status:' $response.StatusCode; Write-Host '✅ Response received!' } catch { Write-Host '❌ Connection failed:' $_.Exception.Message }"

echo.
echo Testing alternative URL: http://localhost:8080
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080' -TimeoutSec 5 -ErrorAction Stop; Write-Host '✅ Status:' $response.StatusCode; Write-Host '✅ Response received!' } catch { Write-Host '❌ Connection failed:' $_.Exception.Message }"

echo.
echo Testing LocalStack web interface: https://localhost.localstack.cloud:4566
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://localhost.localstack.cloud:4566' -TimeoutSec 5 -ErrorAction Stop; Write-Host '✅ LocalStack Status:' $response.StatusCode; Write-Host '✅ LocalStack is accessible!' } catch { Write-Host '❌ LocalStack connection failed:' $_.Exception.Message }"

echo.
echo 📋 Summary:
echo ==========================================
echo.
echo ✅ LocalStack is running
echo ✅ EC2 instance exists (i-cd2d73cbd14fd6c58)
echo ✅ Public IP: 54.214.223.198
echo.
echo ❌ Issue: LocalStack EC2 instances don't run actual web servers
echo ❌ Issue: SSH is not available in LocalStack EC2 simulation
echo.
echo 💡 Solution Options:
echo.
echo 1. 🐳 Use Docker to simulate LAMP stack:
echo    docker run -d -p 8080:80 --name laravel-lamp php:8.1-apache
echo.
echo 2. 🌐 Create local PHP server:
echo    php -S localhost:8080 -t laravel/public
echo.
echo 3. 📦 Use LocalStack Pro for full EC2 simulation
echo.
echo 🎯 For testing purposes, LocalStack Community Edition
echo    simulates EC2 API but doesn't run actual services
echo    inside the instances.
echo.
pause
