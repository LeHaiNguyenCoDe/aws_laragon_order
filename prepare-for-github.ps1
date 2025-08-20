# 🚀 Prepare Laravel CI/CD for GitHub
# This script prepares your Laravel project for GitHub deployment

Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  🚀 Preparing Laravel CI/CD for GitHub" -ForegroundColor Magenta
Write-Host "  📍 Setup Repository and Push Code" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

function Write-Status {
    param($message)
    Write-Host "[INFO] $message" -ForegroundColor Blue
}

function Write-Success {
    param($message)
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Warning {
    param($message)
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error {
    param($message)
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Step 1: Check if we're in the right directory
Write-Status "Checking project structure..."
if (-not (Test-Path "laravel")) {
    Write-Error "Laravel directory not found. Please run this script from the dockerLocalStack directory."
    exit 1
}

if (-not (Test-Path "laravel\.github\workflows\deploy.yml")) {
    Write-Error "GitHub Actions workflow not found. CI/CD setup incomplete."
    exit 1
}

Write-Success "Project structure verified"

# Step 2: Navigate to Laravel directory
Set-Location laravel
Write-Status "Moved to Laravel directory"

# Step 3: Check Git status
Write-Status "Checking Git repository status..."
try {
    $gitStatus = git status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Initializing Git repository..."
        git init
        Write-Success "Git repository initialized"
    } else {
        Write-Success "Git repository already exists"
    }
} catch {
    Write-Status "Initializing Git repository..."
    git init
    Write-Success "Git repository initialized"
}

# Step 4: Create/update .env.example
Write-Status "Creating .env.example for production..."
if (Test-Path ".env") {
    Copy-Item ".env" ".env.example"
    Write-Success ".env.example created from .env"
} else {
    Write-Warning ".env not found, creating basic .env.example"
    @"
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=https://your-domain.com

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
APP_MAINTENANCE_STORE=database

BCRYPT_ROUNDS=12

LOG_CHANNEL=stderr
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

SESSION_DRIVER=redis
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis

CACHE_STORE=redis
CACHE_PREFIX=

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME="${APP_NAME}"
"@ | Out-File -FilePath ".env.example" -Encoding UTF8
    Write-Success "Basic .env.example created"
}

# Step 5: Update task definition with placeholder
Write-Status "Updating task definition..."
if (Test-Path ".aws\task-definition.json") {
    $taskDef = Get-Content ".aws\task-definition.json" -Raw
    $taskDef = $taskDef -replace "YOUR_ACCOUNT_ID", "123456789012"
    $taskDef | Out-File ".aws\task-definition.json" -Encoding UTF8
    Write-Success "Task definition updated with placeholder account ID"
}

# Step 6: Show files to be committed
Write-Status "Files to be committed:"
Write-Host ""
Write-Host "📁 Essential CI/CD Files:" -ForegroundColor Cyan
Write-Host "  ✅ .github/workflows/deploy.yml    # GitHub Actions CI/CD pipeline"
Write-Host "  ✅ .docker/                        # Docker configuration files"
Write-Host "  ✅ .aws/task-definition.json       # ECS task definition"
Write-Host "  ✅ terraform/main.tf               # Infrastructure as Code"
Write-Host "  ✅ Dockerfile                      # Multi-stage Docker build"
Write-Host "  ✅ docker-compose.yml              # Local development"
Write-Host "  ✅ Makefile                        # Development commands"
Write-Host ""
Write-Host "📁 Laravel Application:" -ForegroundColor Cyan
Write-Host "  ✅ app/                            # Laravel application code"
Write-Host "  ✅ config/                         # Laravel configuration"
Write-Host "  ✅ database/                       # Migrations and seeders"
Write-Host "  ✅ resources/                      # Views, assets, lang files"
Write-Host "  ✅ routes/                         # Application routes"
Write-Host "  ✅ tests/                          # PHPUnit tests"
Write-Host "  ✅ composer.json                   # PHP dependencies"
Write-Host "  ✅ package.json                    # Node.js dependencies"
Write-Host ""
Write-Host "📁 Documentation:" -ForegroundColor Cyan
Write-Host "  ✅ CI-CD-README.md                 # Complete CI/CD documentation"
Write-Host "  ✅ README.md                       # Project documentation"
Write-Host ""

# Step 7: Add files to Git
Write-Status "Adding files to Git..."
git add .
Write-Success "Files added to Git staging area"

# Step 8: Show Git status
Write-Status "Current Git status:"
git status --short

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  📋 Next Steps to Deploy" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host "1. 📝 Commit your changes:" -ForegroundColor Cyan
Write-Host "   git commit -m 'Setup Laravel CI/CD pipeline with AWS deployment'"
Write-Host ""

Write-Host "2. 🌐 Create GitHub repository:" -ForegroundColor Cyan
Write-Host "   • Go to https://github.com/new"
Write-Host "   • Repository name: laravel-cicd-aws (or your choice)"
Write-Host "   • Make it Public or Private"
Write-Host "   • Don't initialize with README (we already have files)"
Write-Host ""

Write-Host "3. 🔗 Connect to GitHub:" -ForegroundColor Cyan
Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
Write-Host "   git branch -M main"
Write-Host ""

Write-Host "4. 🚀 Push to GitHub:" -ForegroundColor Cyan
Write-Host "   git push -u origin main"
Write-Host ""

Write-Host "5. ⚙️ Setup GitHub Secrets:" -ForegroundColor Cyan
Write-Host "   • Go to your repo > Settings > Secrets and variables > Actions"
Write-Host "   • Add these secrets:"
Write-Host "     - AWS_ACCESS_KEY_ID: Your AWS access key"
Write-Host "     - AWS_SECRET_ACCESS_KEY: Your AWS secret key"
Write-Host ""

Write-Host "6. 🎯 Trigger Deployment:" -ForegroundColor Cyan
Write-Host "   • Any push to main branch will trigger CI/CD"
Write-Host "   • Check Actions tab to see pipeline progress"
Write-Host ""

Write-Host "🎉 Ready to deploy! Follow the steps above to push your Laravel CI/CD to GitHub!" -ForegroundColor Green
Write-Host ""

# Return to original directory
Set-Location ..
