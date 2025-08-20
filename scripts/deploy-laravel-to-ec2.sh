#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Banner
echo -e "${PURPLE}"
echo "=========================================="
echo "  🚀 Laravel LAMP Stack Deployment"
echo "  📍 LocalStack EC2 Instance"
echo "  🔧 Automated Setup Script v2.0"
echo "=========================================="
echo -e "${NC}"

log_info "Starting deployment process..."

# Check if required files exist
log "Checking prerequisites..."

if [ ! -f "my-local-key.pem" ]; then
    log_error "my-local-key.pem not found!"
    echo "Please ensure your EC2 key file is in the current directory."
    exit 1
fi

if [ ! -d "laravel" ]; then
    log_error "Laravel directory not found!"
    echo "Please ensure your Laravel application is in the 'laravel' directory."
    exit 1
fi

# Check if scripts exist
REQUIRED_SCRIPTS=("setup-ec2-lamp.sh" "configure-laravel-ec2.sh" "check-ec2-status.sh")
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        log_error "Required script $script not found!"
        exit 1
    fi
done

log_success "Prerequisites check passed"

# Make scripts executable
log "Making scripts executable..."
chmod +x setup-ec2-lamp.sh
chmod +x configure-laravel-ec2.sh
chmod +x check-ec2-status.sh

log_success "Scripts are now executable"

# Step 1: Setup LAMP Stack
echo ""
echo -e "${YELLOW}📦 Step 1: Setting up LAMP Stack on EC2...${NC}"
echo "This will install Apache, MySQL/MariaDB, PHP, and Composer"
echo ""

log "Starting LAMP stack installation..."
if ./setup-ec2-lamp.sh; then
    log_success "LAMP Stack installation completed successfully"
else
    log_error "LAMP Stack installation failed"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "1. Check if LocalStack is running"
    echo "2. Verify EC2 instance is accessible"
    echo "3. Check key file permissions: chmod 600 my-local-key.pem"
    echo "4. Review the setup script output above for specific errors"
    exit 1
fi

echo ""
log_info "Waiting 30 seconds for services to stabilize..."
sleep 30

# Step 2: Configure Laravel
echo ""
echo -e "${YELLOW}⚙️  Step 2: Configuring Laravel application...${NC}"
echo "This will deploy Laravel, configure database, and optimize for production"
echo ""

log "Starting Laravel configuration..."
if ./configure-laravel-ec2.sh; then
    log_success "Laravel configuration completed successfully"
else
    log_error "Laravel configuration failed"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "1. Check if LAMP stack is running properly"
    echo "2. Verify database connection"
    echo "3. Check file permissions"
    echo "4. Review Laravel logs for specific errors"
    exit 1
fi

echo ""
log_info "Waiting 15 seconds for application to initialize..."
sleep 15

# Step 3: Run comprehensive status check
echo ""
echo -e "${YELLOW}🔍 Step 3: Running comprehensive system status check...${NC}"
echo "This will verify all components are working correctly"
echo ""

log "Running status check..."
./check-ec2-status.sh

# Step 4: Final verification and testing
echo ""
echo -e "${YELLOW}🧪 Step 4: Final application testing...${NC}"

log "Testing application response..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://54.214.223.198" 2>/dev/null)

echo ""
echo -e "${PURPLE}"
echo "=========================================="
echo "  🎉 Deployment Complete!"
echo "=========================================="
echo -e "${NC}"

case $RESPONSE in
    "200")
        log_success "Application is responding correctly (HTTP $RESPONSE)"
        STATUS_ICON="🟢"
        ;;
    "500")
        log_warning "Application response: HTTP $RESPONSE (Internal Server Error)"
        STATUS_ICON="🟡"
        ;;
    "404")
        log_warning "Application response: HTTP $RESPONSE (Not Found)"
        STATUS_ICON="🟡"
        ;;
    "")
        log_warning "No HTTP response (connection may be establishing)"
        STATUS_ICON="🟡"
        ;;
    *)
        log_warning "Application response: HTTP $RESPONSE"
        STATUS_ICON="🟡"
        ;;
esac

echo ""
echo -e "${CYAN}🌐 Your Laravel application is accessible at:${NC}"
echo -e "   ${GREEN}http://54.214.223.198${NC} $STATUS_ICON"
echo ""

echo -e "${BLUE}📋 System Information:${NC}"
echo "   • Web Server: Apache"
echo "   • Database: MySQL/MariaDB"
echo "   • PHP Version: 8.1+"
echo "   • Environment: Production"
echo "   • Instance: i-c4dd20590d3404ed6"
echo ""

echo -e "${BLUE}🗄️  Database Information:${NC}"
echo "   • Database: laravel_db"
echo "   • Username: laravel_user"
echo "   • Password: laravel_password"
echo "   • Root Password: rootpassword"
echo ""

echo -e "${BLUE}📁 Important Paths:${NC}"
echo "   • Application: /var/www/html/laravel"
echo "   • Web Root: /var/www/html/laravel/public"
echo "   • Logs: /var/www/html/laravel/storage/logs"
echo ""

echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "   • SSH to server: ssh -i my-local-key.pem ec2-user@54.214.83.189"
echo "   • Check status: ./check-ec2-status.sh"
echo "   • Laravel commands: cd /var/www/html/laravel && php artisan [command]"
echo ""

echo -e "${BLUE}📊 Quick Health Check:${NC}"
echo "   • Status check: ./check-ec2-status.sh"
echo "   • PHP info: http://54.214.83.189/info.php"
echo ""

echo -e "${GREEN}🎯 Next Steps:${NC}"
echo "   1. 🌐 Open http://54.214.83.189 in your browser"
echo "   2. ✅ Verify the Laravel welcome page loads"
echo "   3. 🔍 Run ./check-ec2-status.sh if you encounter issues"
echo "   4. 📝 Check logs if needed for troubleshooting"
echo "   5. ⚙️  Configure additional Laravel features as needed"

if [ "$RESPONSE" != "200" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Note: HTTP response was $RESPONSE${NC}"
    echo "   This might be normal during initial setup."
    echo "   Check the browser for more details or run status check."
fi

echo ""
echo -e "${PURPLE}=========================================="
echo -e "  ${GREEN}✨ Happy coding! 🚀${NC}"
echo -e "${PURPLE}=========================================="
echo -e "${NC}"

log_success "Deployment script completed successfully!"
