# 🚀 Deploy Professional CI/CD Pipeline Script

Write-Host "🚀 Deploying Professional Laravel CI/CD Pipeline..." -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "laravel")) {
    Write-Host "❌ Error: laravel directory not found. Please run this script from the project root." -ForegroundColor Red
    exit 1
}

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# Check git status
Write-Host "📋 Checking Git status..." -ForegroundColor Cyan
git status

# Add all files
Write-Host "📦 Adding all files to Git..." -ForegroundColor Cyan
git add .

# Check if there are changes to commit
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-Host "✅ No changes to commit. Repository is up to date." -ForegroundColor Green
    exit 0
}

# Commit changes
$commitMessage = "🚀 Add Professional Laravel CI/CD Pipeline

✨ Features Added:
- 🏗️ Complete Infrastructure as Code with Terraform
- 🧪 Comprehensive Testing (Unit, Feature, Integration, E2E)
- 🔒 Security Scanning (Container, Dependencies, Code Quality)
- 📊 Monitoring & Alerting with CloudWatch
- 🚀 Professional Deployment with ECS
- 🌍 Multi-Environment Support (dev, staging, production, demo)
- 📋 Health Checks & Rollback Capabilities
- 🎭 E2E Testing with Playwright
- 📚 Complete Documentation

🎯 Pipeline Stages:
1. Pre-flight Checks
2. Infrastructure Provisioning
3. Code Analysis & Security
4. Comprehensive Testing
5. Build & Package
6. Professional Deployment
7. Post-Deployment Testing
8. Monitoring Setup
9. Deployment Summary

Ready for production deployment! 🎉"

Write-Host "💾 Committing changes..." -ForegroundColor Cyan
git commit -m $commitMessage

# Check if remote origin exists
$remoteUrl = git remote get-url origin 2>$null
if (-not $remoteUrl) {
    Write-Host "⚠️  No remote origin found." -ForegroundColor Yellow
    Write-Host "📝 To add a remote origin, run:" -ForegroundColor Cyan
    Write-Host "   git remote add origin https://github.com/yourusername/your-repo.git" -ForegroundColor White
    Write-Host "   git push -u origin main" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Or create a new repository on GitHub and follow the instructions." -ForegroundColor Cyan
} else {
    Write-Host "🚀 Pushing to remote repository..." -ForegroundColor Cyan
    Write-Host "Remote URL: $remoteUrl" -ForegroundColor Gray
    
    try {
        git push origin main
        Write-Host "✅ Successfully pushed to remote repository!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 CI/CD Pipeline Deployment Complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Cyan
        Write-Host "1. 🔐 Add GitHub Secrets:" -ForegroundColor White
        Write-Host "   - AWS_ACCESS_KEY_ID" -ForegroundColor Gray
        Write-Host "   - AWS_SECRET_ACCESS_KEY" -ForegroundColor Gray
        Write-Host "   - DATABASE_PASSWORD" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. 🏗️ Create S3 buckets for Terraform state:" -ForegroundColor White
        Write-Host "   - terraform-state-staging" -ForegroundColor Gray
        Write-Host "   - terraform-state-production" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. 🚀 Pipeline will automatically trigger on push to:" -ForegroundColor White
        Write-Host "   - main/master (production)" -ForegroundColor Gray
        Write-Host "   - staging (staging environment)" -ForegroundColor Gray
        Write-Host "   - develop (development environment)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4. 📊 Monitor deployment in GitHub Actions tab" -ForegroundColor White
        Write-Host ""
        Write-Host "🔗 Pipeline Features:" -ForegroundColor Cyan
        Write-Host "   ✅ Infrastructure as Code" -ForegroundColor Green
        Write-Host "   ✅ Comprehensive Testing" -ForegroundColor Green
        Write-Host "   ✅ Security Scanning" -ForegroundColor Green
        Write-Host "   ✅ Professional Deployment" -ForegroundColor Green
        Write-Host "   ✅ Monitoring & Alerting" -ForegroundColor Green
        Write-Host "   ✅ Multi-Environment Support" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 Ready for Enterprise Production! 🚀" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Error pushing to remote repository:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Try:" -ForegroundColor Yellow
        Write-Host "   git pull origin main --rebase" -ForegroundColor White
        Write-Host "   git push origin main" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   - CI/CD Guide: laravel/docs/CICD_GUIDE.md" -ForegroundColor White
Write-Host "   - Terraform: laravel/terraform/" -ForegroundColor White
Write-Host "   - Monitoring: laravel/monitoring/" -ForegroundColor White
Write-Host "   - E2E Tests: laravel/tests/e2e/" -ForegroundColor White
Write-Host ""
Write-Host "🆘 Support: Check the documentation for troubleshooting and best practices." -ForegroundColor Cyan
