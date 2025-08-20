#!/bin/bash

# EC2 Instance Information
INSTANCE_ID="i-cd2d73cbd14fd6c58"
PUBLIC_IP="54.214.223.198"
KEY_FILE="${KEY_FILE:-../config/my-local-key.pem}"

# AWS Configuration for LocalStack
export AWS_ACCESS_KEY_ID="LKIAQAAAAAAAHXZXZSHD"
export AWS_SECRET_ACCESS_KEY="h4vZw/IR9WBBRjw3rqAFUZaV3ciEplFIVz4axlqi"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ENDPOINT_URL="https://localhost.localstack.cloud:4566"

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

echo "=== Setting up LAMP Stack on LocalStack EC2 ==="
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "Key File: $KEY_FILE"

# Check if key file exists and set proper permissions
if [ ! -f "$KEY_FILE" ]; then
    log_error "Key file $KEY_FILE not found!"
    exit 1
fi

chmod 600 "$KEY_FILE"

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

echo "=== Step 1: Testing EC2 Connection ==="
if run_on_ec2 "echo 'Connection successful!'" "Testing SSH connection"; then
    log_success "EC2 connection established"
else
    log_error "Failed to connect to EC2 instance"
    echo "Please check:"
    echo "1. LocalStack is running"
    echo "2. EC2 instance is running"
    echo "3. Key file permissions are correct (600)"
    echo "4. Security groups allow SSH (port 22)"
    exit 1
fi

# Detect operating system
log "Detecting operating system..."
OS_TYPE=$(detect_os)
log "Detected OS: $OS_TYPE"

echo "=== Step 2: Installing LAMP Stack ==="

# Update system based on OS
case $OS_TYPE in
    "amazon")
        log "Installing packages for Amazon Linux..."
        run_on_ec2 "sudo yum update -y" "Updating system packages" || exit 1

        # Install Apache
        run_on_ec2 "sudo yum install -y httpd" "Installing Apache" || exit 1
        run_on_ec2 "sudo systemctl start httpd" "Starting Apache" || exit 1
        run_on_ec2 "sudo systemctl enable httpd" "Enabling Apache" || exit 1

        # Install MySQL/MariaDB
        run_on_ec2 "sudo yum install -y mariadb-server mariadb" "Installing MariaDB" || exit 1
        run_on_ec2 "sudo systemctl start mariadb" "Starting MariaDB" || exit 1
        run_on_ec2 "sudo systemctl enable mariadb" "Enabling MariaDB" || exit 1

        # Install PHP 8.1 (more stable than 8.2 on Amazon Linux)
        run_on_ec2 "sudo amazon-linux-extras enable php8.1" "Enabling PHP 8.1 repository" || exit 1
        run_on_ec2 "sudo yum clean metadata" "Cleaning package metadata" || exit 1
        run_on_ec2 "sudo yum install -y php php-cli php-fpm php-mysqlnd php-json php-opcache php-xml php-gd php-devel php-intl php-mbstring php-bcmath php-zip php-curl" "Installing PHP and extensions" || exit 1
        ;;

    "ubuntu")
        log "Installing packages for Ubuntu..."
        run_on_ec2 "sudo apt update -y" "Updating package lists" || exit 1

        # Install Apache
        run_on_ec2 "sudo apt install -y apache2" "Installing Apache" || exit 1
        run_on_ec2 "sudo systemctl start apache2" "Starting Apache" || exit 1
        run_on_ec2 "sudo systemctl enable apache2" "Enabling Apache" || exit 1

        # Install MySQL
        run_on_ec2 "sudo apt install -y mysql-server" "Installing MySQL" || exit 1
        run_on_ec2 "sudo systemctl start mysql" "Starting MySQL" || exit 1
        run_on_ec2 "sudo systemctl enable mysql" "Enabling MySQL" || exit 1

        # Install PHP 8.1
        run_on_ec2 "sudo apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-json php8.1-opcache php8.1-xml php8.1-gd php8.1-dev php8.1-intl php8.1-mbstring php8.1-bcmath php8.1-zip php8.1-curl libapache2-mod-php8.1" "Installing PHP and extensions" || exit 1
        ;;

    *)
        log_error "Unsupported operating system: $OS_TYPE"
        exit 1
        ;;
esac

# Install Composer
log "Installing Composer..."
run_on_ec2 "curl -sS https://getcomposer.org/installer | php" "Downloading Composer" || exit 1
run_on_ec2 "sudo mv composer.phar /usr/local/bin/composer" "Installing Composer globally" || exit 1
run_on_ec2 "sudo chmod +x /usr/local/bin/composer" "Setting Composer permissions" || exit 1

# Restart web server to load PHP
case $OS_TYPE in
    "amazon"|"centos")
        run_on_ec2 "sudo systemctl restart httpd" "Restarting Apache" || exit 1
        ;;
    "ubuntu")
        run_on_ec2 "sudo systemctl restart apache2" "Restarting Apache" || exit 1
        ;;
esac

echo "=== Step 3: Configuring Apache ==="

# Create Apache virtual host configuration based on OS
case $OS_TYPE in
    "amazon"|"centos")
        LOG_DIR="/var/log/httpd"
        CONF_DIR="/etc/httpd/conf.d"
        ;;
    "ubuntu")
        LOG_DIR="/var/log/apache2"
        CONF_DIR="/etc/apache2/sites-available"
        ;;
esac

cat > apache-laravel.conf << EOF
<VirtualHost *:80>
    ServerName laravel.local
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/laravel/public>
        AllowOverride All
        Options Indexes FollowSymLinks
        Require all granted
    </Directory>

    ErrorLog $LOG_DIR/laravel_error.log
    CustomLog $LOG_DIR/laravel_access.log combined
</VirtualHost>
EOF

# Copy and enable virtual host
copy_to_ec2 "apache-laravel.conf" "/tmp/" "Apache virtual host configuration" || exit 1

case $OS_TYPE in
    "amazon"|"centos")
        run_on_ec2 "sudo mv /tmp/apache-laravel.conf $CONF_DIR/" "Moving virtual host configuration" || exit 1
        run_on_ec2 "sudo systemctl restart httpd" "Restarting Apache" || exit 1
        ;;
    "ubuntu")
        run_on_ec2 "sudo mv /tmp/apache-laravel.conf $CONF_DIR/" "Moving virtual host configuration" || exit 1
        run_on_ec2 "sudo a2ensite apache-laravel.conf" "Enabling virtual host" || exit 1
        run_on_ec2 "sudo a2enmod rewrite" "Enabling mod_rewrite" || exit 1
        run_on_ec2 "sudo systemctl restart apache2" "Restarting Apache" || exit 1
        ;;
esac

echo "=== Step 4: Setting up Database ==="

# Setup database based on what was installed
case $OS_TYPE in
    "amazon"|"centos")
        # MariaDB setup
        log "Configuring MariaDB..."
        run_on_ec2 "sudo mysql -e \"SET PASSWORD FOR 'root'@'localhost' = PASSWORD('rootpassword');\"" "Setting root password" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"CREATE DATABASE IF NOT EXISTS laravel_db;\"" "Creating database" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"CREATE USER IF NOT EXISTS 'laravel_user'@'localhost' IDENTIFIED BY 'laravel_password';\"" "Creating database user" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'localhost';\"" "Granting privileges" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"FLUSH PRIVILEGES;\"" "Flushing privileges" || exit 1
        ;;
    "ubuntu")
        # MySQL setup
        log "Configuring MySQL..."
        run_on_ec2 "sudo mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';\"" "Setting root password" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"CREATE DATABASE IF NOT EXISTS laravel_db;\"" "Creating database" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"CREATE USER IF NOT EXISTS 'laravel_user'@'localhost' IDENTIFIED BY 'laravel_password';\"" "Creating database user" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'localhost';\"" "Granting privileges" || exit 1
        run_on_ec2 "sudo mysql -u root -prootpassword -e \"FLUSH PRIVILEGES;\"" "Flushing privileges" || exit 1
        ;;
esac

echo "=== Step 5: Preparing for Laravel Deployment ==="

# Create web directory
run_on_ec2 "sudo mkdir -p /var/www/html" "Creating web directory" || exit 1
run_on_ec2 "sudo chown -R ec2-user:ec2-user /var/www/html" "Setting directory ownership" || exit 1

# Test PHP installation
log "Testing PHP installation..."
run_on_ec2 "php --version" "Checking PHP version" || exit 1

# Test database connection
log "Testing database connection..."
run_on_ec2 "mysql -u laravel_user -plaravel_password -e 'SELECT 1;'" "Testing database connection" || exit 1

# Test Composer installation
log "Testing Composer installation..."
run_on_ec2 "composer --version" "Checking Composer version" || exit 1

# Create PHP info file for testing
run_on_ec2 "echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/info.php" "Creating PHP info file" || exit 1

# Set proper web server user based on OS
case $OS_TYPE in
    "amazon"|"centos")
        WEB_USER="apache"
        ;;
    "ubuntu")
        WEB_USER="www-data"
        ;;
esac

run_on_ec2 "sudo chown -R $WEB_USER:$WEB_USER /var/www/html" "Setting web directory permissions" || exit 1

log_success "LAMP Stack installation completed successfully!"
echo ""
echo "=== Installation Summary ==="
echo "✅ Operating System: $OS_TYPE"
echo "✅ Web Server: Apache"
echo "✅ Database: MySQL/MariaDB"
echo "✅ PHP: Installed with extensions"
echo "✅ Composer: Installed"
echo ""
echo "🌐 Test URLs:"
echo "   • PHP Info: http://$PUBLIC_IP/info.php"
echo "   • Laravel (after deployment): http://$PUBLIC_IP"
echo ""
echo "🗄️  Database Information:"
echo "   • Database: laravel_db"
echo "   • Username: laravel_user"
echo "   • Password: laravel_password"
echo "   • Root Password: rootpassword"
echo ""
echo "📋 Next Steps:"
echo "   1. Run the Laravel configuration script"
echo "   2. Deploy your Laravel application"
echo "   3. Configure Laravel environment"
echo ""
echo "🔧 Useful Commands:"
echo "   • SSH: ssh -i $KEY_FILE ec2-user@$PUBLIC_IP"
echo "   • Check services: sudo systemctl status httpd mysqld"
echo "   • View logs: sudo tail -f /var/log/httpd/error_log"

# Clean up temporary files
rm -f apache-laravel.conf /tmp/os-release 2>/dev/null

log_success "Setup script completed successfully!"
