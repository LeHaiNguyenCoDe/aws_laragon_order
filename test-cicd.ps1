# 🧪 Test Laravel CI/CD Setup - PowerShell Version
# This script tests the CI/CD pipeline locally before deploying to AWS

Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  🧪 Laravel CI/CD Pipeline Test" -ForegroundColor Magenta
Write-Host "  📍 Local Testing Before AWS Deployment" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

$failedTests = 0

function Test-Status {
    param($message)
    Write-Host "[TEST] $message" -ForegroundColor Blue
}

function Test-Success {
    param($message)
    Write-Host "[PASS] $message" -ForegroundColor Green
}

function Test-Warning {
    param($message)
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Test-Error {
    param($message)
    Write-Host "[FAIL] $message" -ForegroundColor Red
    $script:failedTests++
}

# Test 1: Check Laravel project structure
Test-Status "Testing Laravel project structure..."
if ((Test-Path "laravel\artisan") -and (Test-Path "laravel\composer.json") -and (Test-Path "laravel\app")) {
    Test-Success "Laravel project structure is valid"
} else {
    Test-Error "Invalid Laravel project structure"
}

# Test 2: Check Docker files
Test-Status "Testing Docker configuration..."
if (Test-Path "laravel\Dockerfile") {
    Test-Success "Dockerfile exists"
} else {
    Test-Error "Dockerfile missing"
}

if (Test-Path "laravel\docker-compose.yml") {
    Test-Success "docker-compose.yml exists"
} else {
    Test-Error "docker-compose.yml missing"
}

if (Test-Path "laravel\.docker") {
    Test-Success "Docker configuration directory exists"
} else {
    Test-Error "Docker configuration directory missing"
}

# Test 3: Check GitHub Actions workflow
Test-Status "Testing GitHub Actions workflow..."
if (Test-Path "laravel\.github\workflows\deploy.yml") {
    Test-Success "GitHub Actions workflow exists"
} else {
    Test-Error "GitHub Actions workflow missing"
}

# Test 4: Check AWS configuration
Test-Status "Testing AWS configuration..."
if (Test-Path "laravel\.aws\task-definition.json") {
    Test-Success "ECS task definition exists"
} else {
    Test-Error "ECS task definition missing"
}

if (Test-Path "laravel\terraform") {
    Test-Success "Terraform configuration exists"
} else {
    Test-Error "Terraform configuration missing"
}

# Test 5: Check Makefile
Test-Status "Testing Makefile..."
if (Test-Path "laravel\Makefile") {
    Test-Success "Makefile exists"
} else {
    Test-Error "Makefile missing"
}

# Test 6: Check deployment script
Test-Status "Testing deployment script..."
if (Test-Path "deploy-to-aws.sh") {
    Test-Success "Deployment script exists"
} else {
    Test-Error "Deployment script missing"
}

# Test 7: Check Docker availability
Test-Status "Testing Docker availability..."
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Test-Success "Docker is available: $dockerVersion"
    } else {
        Test-Warning "Docker not available or not in PATH"
    }
} catch {
    Test-Warning "Docker not available"
}

# Test 8: Check AWS CLI
Test-Status "Testing AWS CLI availability..."
try {
    $awsVersion = aws --version 2>$null
    if ($awsVersion) {
        Test-Success "AWS CLI is available"
    } else {
        Test-Warning "AWS CLI not available"
    }
} catch {
    Test-Warning "AWS CLI not available"
}

# Test 9: Check environment files
Test-Status "Testing environment configuration..."
if (Test-Path "laravel\.env.example") {
    Test-Success ".env.example exists"
} else {
    Test-Warning ".env.example missing"
}

if (Test-Path "laravel\.env") {
    Test-Success ".env exists"
} else {
    Test-Warning ".env missing (will be created from .env.example)"
}

# Test 10: Check Laravel dependencies
Test-Status "Testing Laravel dependencies..."
if (Test-Path "laravel\composer.lock") {
    Test-Success "Composer dependencies are locked"
} else {
    Test-Warning "Composer dependencies not locked"
}

if (Test-Path "laravel\package-lock.json") {
    Test-Success "NPM dependencies are locked"
} else {
    Test-Warning "NPM dependencies not locked"
}

# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  📊 Test Results Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ($failedTests -eq 0) {
    Write-Host "🎉 All tests passed! Your CI/CD setup is ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Configure AWS credentials: aws configure"
    Write-Host "2. Run deployment: .\deploy-to-aws.sh (in Git Bash)"
    Write-Host "3. Set up GitHub secrets for CI/CD"
    Write-Host "4. Push to main branch to trigger deployment"
    Write-Host ""
    Write-Host "✅ Ready to deploy!" -ForegroundColor Green
} else {
    Write-Host "❌ $failedTests test(s) failed. Please fix the issues above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Common fixes:" -ForegroundColor Cyan
    Write-Host "- Install missing dependencies"
    Write-Host "- Check Docker is running"
    Write-Host "- Verify file paths and structure"
    exit 1
}
