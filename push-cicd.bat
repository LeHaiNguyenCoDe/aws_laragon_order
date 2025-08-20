@echo off
echo 🚀 Pushing Professional Laravel CI/CD Pipeline...

echo 📦 Adding all files...
git add .

echo 💾 Committing changes...
git commit -m "🚀 Add Professional Laravel CI/CD Pipeline with comprehensive testing, security, and monitoring"

echo 🚀 Pushing to GitHub...
git push origin main

echo ✅ CI/CD Pipeline deployed! Check GitHub Actions for pipeline execution.
echo 📋 Don't forget to add GitHub Secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, DATABASE_PASSWORD

pause
