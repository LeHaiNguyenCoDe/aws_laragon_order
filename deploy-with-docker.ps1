# PowerShell script to deploy Laravel using Docker container
Write-Host "🚀 Deploying Laravel LAMP Stack using Docker..." -ForegroundColor Cyan

# Check if Docker is available
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not available. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Run deployment in Ubuntu container
Write-Host "🐳 Running deployment in Docker container..." -ForegroundColor Yellow

$deployCommand = @"
cd /workspace/scripts && 
chmod +x *.sh && 
./setup-ec2-lamp.sh && 
./configure-laravel-ec2.sh
"@

docker run --rm -it `
    --network host `
    -v "${PWD}:/workspace" `
    -w /workspace `
    ubuntu:20.04 `
    bash -c "
        apt update && 
        apt install -y curl openssh-client awscli && 
        $deployCommand
    "

Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Your Laravel app should be accessible at:" -ForegroundColor Cyan
Write-Host "   • http://54.214.223.198" -ForegroundColor Green
Write-Host "   • http://localhost:8080" -ForegroundColor Green
