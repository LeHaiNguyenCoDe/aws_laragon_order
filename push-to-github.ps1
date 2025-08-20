# 🚀 Push Laravel CI/CD to GitHub
# Replace YOUR_USERNAME and YOUR_REPO_NAME with your actual values

Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  🚀 Push Laravel CI/CD to GitHub" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

# You need to replace these values
$GITHUB_USERNAME = "YOUR_USERNAME"
$REPO_NAME = "laravel-cicd-aws"

Write-Host "📝 Instructions to push to GitHub:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Replace YOUR_USERNAME with your GitHub username in the commands below"
Write-Host "2. Replace YOUR_REPO_NAME if you used a different repository name"
Write-Host ""

Write-Host "🔗 Commands to run:" -ForegroundColor Green
Write-Host ""
Write-Host "# Add GitHub remote (replace YOUR_USERNAME and YOUR_REPO_NAME)"
Write-Host "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
Write-Host ""
Write-Host "# Set main branch"
Write-Host "git branch -M main"
Write-Host ""
Write-Host "# Push to GitHub"
Write-Host "git push -u origin main"
Write-Host ""

Write-Host "📋 Example with sample username:" -ForegroundColor Yellow
Write-Host "git remote add origin https://github.com/johndoe/laravel-cicd-aws.git"
Write-Host "git branch -M main"
Write-Host "git push -u origin main"
Write-Host ""

Write-Host "⚙️ After pushing, setup GitHub Secrets:" -ForegroundColor Cyan
Write-Host "1. Go to your repository on GitHub"
Write-Host "2. Click Settings > Secrets and variables > Actions"
Write-Host "3. Click 'New repository secret' and add:"
Write-Host "   - Name: AWS_ACCESS_KEY_ID"
Write-Host "   - Value: Your AWS access key"
Write-Host "4. Add another secret:"
Write-Host "   - Name: AWS_SECRET_ACCESS_KEY" 
Write-Host "   - Value: Your AWS secret access key"
Write-Host ""

Write-Host "🎯 Trigger CI/CD:" -ForegroundColor Green
Write-Host "- Any push to main branch will trigger the CI/CD pipeline"
Write-Host "- Check the Actions tab to see the pipeline progress"
Write-Host "- First run will setup AWS infrastructure and deploy your app"
Write-Host ""

Write-Host "✅ Ready to push! Follow the commands above." -ForegroundColor Green
