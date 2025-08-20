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

# Logging function
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

# Function to run commands on EC2 instance with error handling
run_on_ec2() {
    local cmd="$1"
    local description="$2"

    if [ -n "$description" ]; then
        log "Executing: $description"
    fi

    if ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=30 ec2-user@"$PUBLIC_IP" "$cmd"; then
        if [ -n "$description" ]; then
            log_success "$description completed"
        fi
        return 0
    else
        if [ -n "$description" ]; then
            log_error "$description failed"
        fi
        return 1
    fi
}

# Function to copy files to EC2 instance with error handling
copy_to_ec2() {
    local src="$1"
    local dest="$2"
    local description="$3"

    if [ -n "$description" ]; then
        log "Copying: $description"
    fi

    if scp -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=30 -r "$src" ec2-user@"$PUBLIC_IP":"$dest"; then
        if [ -n "$description" ]; then
            log_success "$description copied successfully"
        fi
        return 0
    else
        if [ -n "$description" ]; then
            log_error "$description copy failed"
        fi
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
    rm -f /tmp/os-release
}

echo "=== Configuring Laravel Application on EC2 ==="

# Detect OS
OS_TYPE=$(detect_os)
log "Detected OS: $OS_TYPE"

# Set web server user based on OS
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

log "Web server user: $WEB_USER"

# Check if Laravel directory exists locally
if [ ! -d "laravel" ]; then
    log_error "Laravel directory not found in current directory!"
    echo "Please ensure your Laravel application is in the 'laravel' directory."
    exit 1
fi

echo "=== Step 1: Deploying Laravel Application ==="

# Copy Laravel application
log "Copying Laravel application to EC2..."
copy_to_ec2 "laravel/" "/var/www/html/" "Laravel application files" || exit 1

# Create production .env file
log "Creating production environment configuration..."
cat > laravel-production.env << 'EOF'
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://54.214.83.189

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
PHP_CLI_SERVER_WORKERS=4
BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database
MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_SCHEME=null
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=LKIAQAAAAAAAHXZXZSHD
AWS_SECRET_ACCESS_KEY=h4vZw/IR9WBBRjw3rqAFUZaV3ciEplFIVz4axlqi
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=test-bucket
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_ENDPOINT=http://localhost:4566

VITE_APP_NAME="${APP_NAME}"
EOF

echo "=== Step 2: Installing Composer Dependencies ==="
run_on_ec2 "cd /var/www/html/laravel && composer install --no-dev --optimize-autoloader" "Installing Composer dependencies" || exit 1

echo "=== Step 3: Configuring Environment ==="
# Copy production .env file
copy_to_ec2 "laravel-production.env" "/tmp/" "Environment configuration" || exit 1
run_on_ec2 "mv /tmp/laravel-production.env /var/www/html/laravel/.env" "Moving environment file" || exit 1

# Generate application key
run_on_ec2 "cd /var/www/html/laravel && php artisan key:generate --force" "Generating application key" || exit 1

echo "=== Step 4: Setting up Database ==="
# Test database connection first
log "Testing database connection..."
if ! run_on_ec2 "cd /var/www/html/laravel && php artisan migrate:status" "Checking database connection"; then
    log_warning "Database connection failed, attempting to fix..."
    # Try to create database again
    run_on_ec2 "mysql -u root -prootpassword -e 'CREATE DATABASE IF NOT EXISTS laravel_db;'" "Creating database" || exit 1
fi

# Run migrations
run_on_ec2 "cd /var/www/html/laravel && php artisan migrate --force" "Running database migrations" || exit 1

# Seed database (if seeder exists)
if run_on_ec2 "cd /var/www/html/laravel && php artisan db:seed --class=DatabaseSeeder --force" "Seeding database" 2>/dev/null; then
    log_success "Database seeded successfully"
else
    log_warning "Database seeding skipped (no seeders found or failed)"
fi

echo "=== Step 5: Optimizing Laravel ==="
# Clear all caches first
run_on_ec2 "cd /var/www/html/laravel && php artisan cache:clear" "Clearing application cache" || true
run_on_ec2 "cd /var/www/html/laravel && php artisan config:clear" "Clearing config cache" || true
run_on_ec2 "cd /var/www/html/laravel && php artisan route:clear" "Clearing route cache" || true
run_on_ec2 "cd /var/www/html/laravel && php artisan view:clear" "Clearing view cache" || true

# Cache configurations for production
run_on_ec2 "cd /var/www/html/laravel && php artisan config:cache" "Caching configuration" || exit 1
run_on_ec2 "cd /var/www/html/laravel && php artisan route:cache" "Caching routes" || exit 1
run_on_ec2 "cd /var/www/html/laravel && php artisan view:cache" "Caching views" || exit 1

echo "=== Step 6: Setting File Permissions ==="
run_on_ec2 "sudo chown -R $WEB_USER:$WEB_USER /var/www/html/laravel" "Setting ownership to $WEB_USER" || exit 1
run_on_ec2 "sudo chmod -R 755 /var/www/html/laravel" "Setting base permissions" || exit 1
run_on_ec2 "sudo chmod -R 775 /var/www/html/laravel/storage" "Setting storage permissions" || exit 1
run_on_ec2 "sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache" "Setting cache permissions" || exit 1

# Set SELinux contexts (if SELinux is enabled)
if run_on_ec2 "getenforce" 2>/dev/null | grep -q "Enforcing"; then
    log "SELinux is enforcing, setting contexts..."
    run_on_ec2 "sudo setsebool -P httpd_can_network_connect 1" "Allowing HTTP network connections" || true
    run_on_ec2 "sudo chcon -R -t httpd_exec_t /var/www/html/laravel" "Setting SELinux context" || true
fi

echo "=== Step 7: Restarting Services ==="
case $OS_TYPE in
    "amazon"|"centos")
        run_on_ec2 "sudo systemctl restart httpd" "Restarting Apache" || exit 1
        run_on_ec2 "sudo systemctl restart mariadb" "Restarting MariaDB" || exit 1
        ;;
    "ubuntu")
        run_on_ec2 "sudo systemctl restart apache2" "Restarting Apache" || exit 1
        run_on_ec2 "sudo systemctl restart mysql" "Restarting MySQL" || exit 1
        ;;
esac

# Final verification
echo "=== Step 8: Final Verification ==="
log "Running final verification checks..."

# Check if Laravel is accessible
if run_on_ec2 "cd /var/www/html/laravel && php artisan --version" "Checking Laravel installation"; then
    log_success "Laravel is properly installed"
else
    log_error "Laravel installation verification failed"
    exit 1
fi

# Check database connection
if run_on_ec2 "cd /var/www/html/laravel && php artisan migrate:status" "Checking database connection"; then
    log_success "Database connection is working"
else
    log_warning "Database connection issues detected"
fi

# Test web server response
log "Testing web server response..."
sleep 5  # Wait for services to fully restart

log_success "Laravel Configuration Complete!"
echo ""
echo "🎉 Your Laravel application is now configured and should be accessible at:"
echo "🌐 http://$PUBLIC_IP"
echo ""
echo "📋 Application Details:"
echo "   • Environment: Production"
echo "   • Database: MySQL/MariaDB (laravel_db)"
echo "   • Web Server: Apache"
echo "   • PHP Version: 8.1+"
echo "   • Operating System: $OS_TYPE"
echo ""
echo "🔧 Useful Commands:"
echo "   • SSH to server: ssh -i $KEY_FILE ec2-user@$PUBLIC_IP"
echo "   • Laravel directory: cd /var/www/html/laravel"
echo "   • Check version: php artisan --version"
echo "   • Migration status: php artisan migrate:status"
echo "   • View logs: tail -f storage/logs/laravel.log"
echo ""
echo "🗄️  Database Information:"
echo "   • Database: laravel_db"
echo "   • Username: laravel_user"
echo "   • Password: laravel_password"
echo "   • Root Password: rootpassword"
echo ""
echo "📁 Important Paths:"
echo "   • Application: /var/www/html/laravel"
echo "   • Web Root: /var/www/html/laravel/public"
echo "   • Logs: /var/www/html/laravel/storage/logs"
echo "   • Apache Logs: /var/log/httpd/ (Amazon/CentOS) or /var/log/apache2/ (Ubuntu)"
echo ""
echo "🚀 Next Steps:"
echo "   1. Open http://$PUBLIC_IP in your browser"
echo "   2. Verify the Laravel welcome page loads"
echo "   3. Check application logs if needed"
echo "   4. Configure any additional Laravel features"

# Clean up temporary files
rm -f laravel-production.env /tmp/os-release 2>/dev/null

log_success "Configuration script completed successfully!"
