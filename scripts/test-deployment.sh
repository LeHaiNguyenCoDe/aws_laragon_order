#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# EC2 Instance Information
INSTANCE_ID="i-cd2d73cbd14fd6c58"
PUBLIC_IP="54.214.223.198"
KEY_FILE="${KEY_FILE:-../config/my-local-key.pem}"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run commands on EC2 instance
run_on_ec2() {
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@"$PUBLIC_IP" "$1" 2>/dev/null
}

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Banner
echo -e "${PURPLE}"
echo "=========================================="
echo "  🧪 Laravel LAMP Stack Test Suite"
echo "  📍 LocalStack EC2 Instance"
echo "=========================================="
echo -e "${NC}"

echo -e "${BLUE}Instance: $INSTANCE_ID${NC}"
echo -e "${BLUE}IP: $PUBLIC_IP${NC}"
echo ""

# Test 1: SSH Connection
echo -e "${YELLOW}=== 1. Connection Tests ===${NC}"
run_test "SSH Connection" "run_on_ec2 'echo test'"

# Test 2: System Information
echo ""
echo -e "${YELLOW}=== 2. System Tests ===${NC}"
run_test "Operating System" "run_on_ec2 'cat /etc/os-release'"
run_test "System Uptime" "run_on_ec2 'uptime'"
run_test "Available Memory" "run_on_ec2 'free -m'"

# Test 3: Service Status
echo ""
echo -e "${YELLOW}=== 3. Service Tests ===${NC}"
run_test "Apache Service" "run_on_ec2 'sudo systemctl is-active httpd || sudo systemctl is-active apache2'"
run_test "Database Service" "run_on_ec2 'sudo systemctl is-active mariadb || sudo systemctl is-active mysql'"

# Test 4: Software Installation
echo ""
echo -e "${YELLOW}=== 4. Software Tests ===${NC}"
run_test "PHP Installation" "run_on_ec2 'php --version'"
run_test "Composer Installation" "run_on_ec2 'composer --version'"
run_test "MySQL Client" "run_on_ec2 'mysql --version'"

# Test 5: PHP Extensions
echo ""
echo -e "${YELLOW}=== 5. PHP Extension Tests ===${NC}"
EXTENSIONS=("mysql" "pdo" "json" "xml" "gd" "mbstring" "bcmath" "zip" "curl")
for ext in "${EXTENSIONS[@]}"; do
    run_test "PHP Extension: $ext" "run_on_ec2 'php -m | grep -i $ext'"
done

# Test 6: Database Connection
echo ""
echo -e "${YELLOW}=== 6. Database Tests ===${NC}"
run_test "Database Connection" "run_on_ec2 'mysql -u laravel_user -plaravel_password -e \"SELECT 1;\"'"
run_test "Database Exists" "run_on_ec2 'mysql -u laravel_user -plaravel_password -e \"USE laravel_db;\"'"

# Test 7: Laravel Application
echo ""
echo -e "${YELLOW}=== 7. Laravel Tests ===${NC}"
run_test "Laravel Directory" "run_on_ec2 'test -d /var/www/html/laravel'"
run_test "Laravel Artisan" "run_on_ec2 'cd /var/www/html/laravel && php artisan --version'"
run_test "Laravel Environment" "run_on_ec2 'cd /var/www/html/laravel && php artisan env'"
run_test "Laravel Database" "run_on_ec2 'cd /var/www/html/laravel && php artisan migrate:status'"

# Test 8: File Permissions
echo ""
echo -e "${YELLOW}=== 8. Permission Tests ===${NC}"
run_test "Laravel Directory Permissions" "run_on_ec2 'test -r /var/www/html/laravel'"
run_test "Storage Directory Writable" "run_on_ec2 'test -w /var/www/html/laravel/storage'"
run_test "Cache Directory Writable" "run_on_ec2 'test -w /var/www/html/laravel/bootstrap/cache'"

# Test 9: Web Server Tests
echo ""
echo -e "${YELLOW}=== 9. Web Server Tests ===${NC}"
run_test "HTTP Response" "curl -s -o /dev/null -w '%{http_code}' 'http://$PUBLIC_IP' | grep -E '^(200|500)$'"
run_test "PHP Info Page" "curl -s -o /dev/null -w '%{http_code}' 'http://$PUBLIC_IP/info.php' | grep '^200$'"

# Test 10: Configuration Files
echo ""
echo -e "${YELLOW}=== 10. Configuration Tests ===${NC}"
run_test "Apache Virtual Host" "run_on_ec2 'sudo test -f /etc/httpd/conf.d/apache-laravel.conf || sudo test -f /etc/apache2/sites-available/apache-laravel.conf'"
run_test "Laravel Environment File" "run_on_ec2 'test -f /var/www/html/laravel/.env'"
run_test "Laravel Application Key" "run_on_ec2 'cd /var/www/html/laravel && grep \"APP_KEY=\" .env | grep -v \"APP_KEY=$\"'"

# Test Results Summary
echo ""
echo -e "${PURPLE}"
echo "=========================================="
echo "  📊 Test Results Summary"
echo "=========================================="
echo -e "${NC}"

echo -e "${BLUE}Total Tests: $TOTAL_TESTS${NC}"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! Your Laravel LAMP stack is working perfectly!${NC}"
    echo ""
    echo -e "${BLUE}✅ Your application should be accessible at:${NC}"
    echo -e "   🌐 http://$PUBLIC_IP"
    echo ""
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed. Please check the issues above.${NC}"
    echo ""
    echo -e "${BLUE}🔧 Troubleshooting steps:${NC}"
    echo "   1. Run: ./check-ec2-status.sh"
    echo "   2. Check logs: ssh -i $KEY_FILE ec2-user@$PUBLIC_IP 'sudo tail -20 /var/log/httpd/error_log'"
    echo "   3. Restart services: ssh -i $KEY_FILE ec2-user@$PUBLIC_IP 'sudo systemctl restart httpd mariadb'"
    echo ""
    exit 1
fi
