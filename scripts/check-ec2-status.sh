#!/bin/bash

# EC2 Instance Information
INSTANCE_ID="i-cd2d73cbd14fd6c58"
PUBLIC_IP="54.214.223.198"
KEY_FILE="${KEY_FILE:-../config/my-local-key.pem}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run commands on EC2 instance
run_on_ec2() {
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@"$PUBLIC_IP" "$1" 2>/dev/null
}

# Function to check status with colored output
check_status() {
    local service="$1"
    local command="$2"

    echo -n "Checking $service... "
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Detect OS function
detect_os() {
    run_on_ec2 "cat /etc/os-release" > /tmp/os-release 2>/dev/null
    if grep -q "Amazon Linux" /tmp/os-release; then
        echo "amazon"
    elif grep -q "Ubuntu" /tmp/os-release; then
        echo "ubuntu"
    elif grep -q "CentOS\|Red Hat" /tmp/os-release; then
        echo "centos"
    else
        echo "unknown"
    fi
    rm -f /tmp/os-release 2>/dev/null
}

echo "=========================================="
echo "  🔍 EC2 LAMP Stack Status Check"
echo "=========================================="
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo ""

# Detect OS first
OS_TYPE=$(detect_os)

echo "=== 1. Connection Test ==="
check_status "SSH Connection" "run_on_ec2 'echo Connection OK'"

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Cannot connect to EC2 instance!${NC}"
    echo "Please check:"
    echo "1. LocalStack is running"
    echo "2. EC2 instance is running"
    echo "3. Key file permissions are correct (600)"
    echo "4. Security groups allow SSH (port 22)"
    exit 1
fi

echo ""
echo "=== 2. System Information ==="
echo -e "${BLUE}Operating System:${NC}"
run_on_ec2 "cat /etc/os-release | head -2"
echo ""
echo -e "${BLUE}Detected OS Type:${NC} $OS_TYPE"
echo ""
echo -e "${BLUE}System Uptime:${NC}"
run_on_ec2 "uptime"
echo ""
echo -e "${BLUE}Available Memory:${NC}"
run_on_ec2 "free -h | head -2"

echo ""
echo "=== 3. Service Status ==="

# Check services based on OS type
case $OS_TYPE in
    "amazon"|"centos")
        check_status "Apache (httpd)" "run_on_ec2 'sudo systemctl is-active httpd'"
        check_status "MariaDB" "run_on_ec2 'sudo systemctl is-active mariadb'"
        ;;
    "ubuntu")
        check_status "Apache (apache2)" "run_on_ec2 'sudo systemctl is-active apache2'"
        check_status "MySQL" "run_on_ec2 'sudo systemctl is-active mysql'"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown OS type, checking common service names...${NC}"
        check_status "Apache (httpd)" "run_on_ec2 'sudo systemctl is-active httpd'"
        check_status "Apache (apache2)" "run_on_ec2 'sudo systemctl is-active apache2'"
        check_status "MySQL" "run_on_ec2 'sudo systemctl is-active mysql'"
        check_status "MariaDB" "run_on_ec2 'sudo systemctl is-active mariadb'"
        ;;
esac

echo ""
echo "=== 4. PHP Information ==="
echo -e "${BLUE}PHP Version:${NC}"
run_on_ec2 "php --version | head -1"

echo ""
echo -e "${BLUE}Required PHP Extensions:${NC}"
EXTENSIONS=("mysql" "pdo" "json" "xml" "gd" "mbstring" "bcmath" "zip" "curl" "openssl")
for ext in "${EXTENSIONS[@]}"; do
    if run_on_ec2 "php -m | grep -i $ext" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $ext"
    else
        echo -e "  ${RED}✗${NC} $ext"
    fi
done

echo ""
echo -e "${BLUE}Composer:${NC}"
if run_on_ec2 "composer --version" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Composer is installed"
    run_on_ec2 "composer --version | head -1"
else
    echo -e "${RED}✗${NC} Composer not found"
fi

echo ""
echo "=== 5. Laravel Application Status ==="
check_status "Laravel Directory" "run_on_ec2 '[ -d /var/www/html/laravel ]'"

if run_on_ec2 "[ -d /var/www/html/laravel ]"; then
    echo ""
    echo -e "${BLUE}Laravel Version:${NC}"
    if run_on_ec2 "cd /var/www/html/laravel && php artisan --version" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Laravel is accessible"
    else
        echo -e "${RED}✗${NC} Laravel command failed"
    fi

    echo ""
    echo -e "${BLUE}Environment:${NC}"
    ENV_STATUS=$(run_on_ec2 "cd /var/www/html/laravel && php artisan env" 2>/dev/null)
    if [ -n "$ENV_STATUS" ]; then
        echo -e "${GREEN}✓${NC} Environment: $ENV_STATUS"
    else
        echo -e "${RED}✗${NC} Cannot determine environment"
    fi

    echo ""
    echo -e "${BLUE}Database Connection:${NC}"
    if run_on_ec2 "cd /var/www/html/laravel && php artisan migrate:status" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Database connection successful"
    else
        echo -e "${RED}✗${NC} Database connection failed"
    fi

    echo ""
    echo -e "${BLUE}Application Key:${NC}"
    if run_on_ec2 "cd /var/www/html/laravel && grep 'APP_KEY=' .env | grep -v 'APP_KEY=$'" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Application key is set"
    else
        echo -e "${RED}✗${NC} Application key not set"
    fi
else
    echo -e "${RED}✗${NC} Laravel directory not found"
fi

echo ""
echo "=== 6. File Permissions ==="
echo -e "${BLUE}Laravel Directory Ownership:${NC}"
LARAVEL_PERMS=$(run_on_ec2 "ls -la /var/www/html/ | grep laravel" 2>/dev/null)
if [ -n "$LARAVEL_PERMS" ]; then
    echo "$LARAVEL_PERMS"
else
    echo -e "${RED}✗${NC} Laravel directory not found"
fi

echo ""
echo -e "${BLUE}Storage Directory Permissions:${NC}"
STORAGE_PERMS=$(run_on_ec2 "ls -la /var/www/html/laravel/ | grep storage" 2>/dev/null)
if [ -n "$STORAGE_PERMS" ]; then
    echo "$STORAGE_PERMS"
else
    echo -e "${RED}✗${NC} Storage directory not found"
fi

echo ""
echo "=== 7. Apache Configuration ==="
echo -e "${BLUE}Virtual Host Configuration:${NC}"
case $OS_TYPE in
    "amazon"|"centos")
        VHOST_CONFIG=$(run_on_ec2 "sudo cat /etc/httpd/conf.d/apache-laravel.conf" 2>/dev/null)
        ;;
    "ubuntu")
        VHOST_CONFIG=$(run_on_ec2 "sudo cat /etc/apache2/sites-available/apache-laravel.conf" 2>/dev/null)
        ;;
esac

if [ -n "$VHOST_CONFIG" ]; then
    echo -e "${GREEN}✓${NC} Virtual host configuration found"
    echo "DocumentRoot: $(echo "$VHOST_CONFIG" | grep DocumentRoot | awk '{print $2}')"
else
    echo -e "${RED}✗${NC} Virtual host configuration not found"
fi

echo ""
echo "=== 8. Log Files ==="
echo -e "${BLUE}Recent Apache Errors:${NC}"
case $OS_TYPE in
    "amazon"|"centos")
        ERROR_LOG=$(run_on_ec2 "sudo tail -5 /var/log/httpd/error_log" 2>/dev/null)
        ;;
    "ubuntu")
        ERROR_LOG=$(run_on_ec2 "sudo tail -5 /var/log/apache2/error.log" 2>/dev/null)
        ;;
esac

if [ -n "$ERROR_LOG" ]; then
    echo "$ERROR_LOG"
else
    echo -e "${GREEN}✓${NC} No recent Apache errors"
fi

echo ""
echo -e "${BLUE}Recent Laravel Logs:${NC}"
LARAVEL_LOG=$(run_on_ec2 "tail -3 /var/www/html/laravel/storage/logs/laravel.log" 2>/dev/null)
if [ -n "$LARAVEL_LOG" ]; then
    echo "$LARAVEL_LOG"
else
    echo -e "${GREEN}✓${NC} No recent Laravel logs"
fi

echo ""
echo "=== 9. Network Test ==="
echo -e "${BLUE}HTTP Response Test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$PUBLIC_IP" 2>/dev/null)
case $HTTP_CODE in
    "200")
        echo -e "${GREEN}✓${NC} HTTP response OK (200)"
        ;;
    "500")
        echo -e "${YELLOW}⚠️${NC} HTTP response: Internal Server Error (500)"
        ;;
    "404")
        echo -e "${YELLOW}⚠️${NC} HTTP response: Not Found (404)"
        ;;
    "")
        echo -e "${RED}✗${NC} No HTTP response (connection failed)"
        ;;
    *)
        echo -e "${YELLOW}⚠️${NC} HTTP response: $HTTP_CODE"
        ;;
esac

echo ""
echo "=== 10. Database Test ==="
echo -e "${BLUE}Database Connection Test:${NC}"
check_status "MySQL/MariaDB Connection" "run_on_ec2 'mysql -u laravel_user -plaravel_password -e \"SELECT 1;\"'"

echo ""
echo "=========================================="
echo "  📊 Status Check Summary"
echo "=========================================="

# Count successful checks
TOTAL_CHECKS=10
PASSED_CHECKS=0

# This is a simplified summary - in a real implementation, you'd track each check result
echo -e "${BLUE}System Status:${NC}"
echo "• Operating System: $OS_TYPE"
echo "• Instance ID: $INSTANCE_ID"
echo "• Public IP: $PUBLIC_IP"

echo ""
echo -e "${BLUE}Quick Access URLs:${NC}"
echo "• Application: http://$PUBLIC_IP"
echo "• PHP Info: http://$PUBLIC_IP/info.php"

echo ""
echo "=========================================="
echo "  🛠️  Troubleshooting Commands"
echo "=========================================="

echo -e "${BLUE}SSH Access:${NC}"
echo "ssh -i $KEY_FILE ec2-user@$PUBLIC_IP"

echo ""
echo -e "${BLUE}Service Management:${NC}"
case $OS_TYPE in
    "amazon"|"centos")
        echo "sudo systemctl restart httpd mariadb"
        echo "sudo systemctl status httpd mariadb"
        ;;
    "ubuntu")
        echo "sudo systemctl restart apache2 mysql"
        echo "sudo systemctl status apache2 mysql"
        ;;
esac

echo ""
echo -e "${BLUE}Log Monitoring:${NC}"
case $OS_TYPE in
    "amazon"|"centos")
        echo "sudo tail -f /var/log/httpd/error_log"
        ;;
    "ubuntu")
        echo "sudo tail -f /var/log/apache2/error.log"
        ;;
esac
echo "tail -f /var/www/html/laravel/storage/logs/laravel.log"

echo ""
echo -e "${BLUE}Laravel Commands:${NC}"
echo "cd /var/www/html/laravel"
echo "php artisan --version"
echo "php artisan migrate:status"
echo "php artisan config:clear"
echo "php artisan cache:clear"

echo ""
echo -e "${BLUE}File Permissions Fix:${NC}"
case $OS_TYPE in
    "amazon"|"centos")
        WEB_USER="apache"
        ;;
    "ubuntu")
        WEB_USER="www-data"
        ;;
    *)
        WEB_USER="apache"
        ;;
esac
echo "sudo chown -R $WEB_USER:$WEB_USER /var/www/html/laravel"
echo "sudo chmod -R 755 /var/www/html/laravel"
echo "sudo chmod -R 775 /var/www/html/laravel/storage"
echo "sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache"

echo ""
echo "=========================================="
echo -e "  ${GREEN}✅ Status check completed!${NC}"
echo "=========================================="

# Clean up
rm -f /tmp/os-release 2>/dev/null
