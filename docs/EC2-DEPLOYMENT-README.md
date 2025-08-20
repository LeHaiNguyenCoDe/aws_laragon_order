# 🚀 Laravel LAMP Stack Deployment trên LocalStack EC2

## 📋 Thông tin hệ thống

| Thông tin | Giá trị |
|-----------|---------|
| **Instance ID** | i-c4dd20590d3404ed6 |
| **Public IP** | 54.214.83.189 |
| **AWS Access Key** | LKIAQAAAAAAAHXZXZSHD |
| **Key File** | my-local-key.pem |
| **Database** | laravel_db |
| **DB User** | laravel_user |
| **DB Password** | laravel_password |

## 🏗️ Cấu trúc LAMP Stack

| Component | Version | Description |
|-----------|---------|-------------|
| **Linux** | Amazon Linux 2 / Ubuntu | Operating System |
| **Apache** | 2.4+ | Web Server |
| **MySQL/MariaDB** | 8.0+ / 10.5+ | Database Server |
| **PHP** | 8.1+ | Programming Language |
| **Composer** | Latest | Dependency Manager |

## ✨ Tính năng mới (v2.0)

- ✅ **Multi-OS Support**: Hỗ trợ Amazon Linux, Ubuntu, CentOS
- ✅ **Enhanced Error Handling**: Xử lý lỗi chi tiết và logging
- ✅ **Colored Output**: Giao diện màu sắc dễ đọc
- ✅ **Comprehensive Testing**: Kiểm tra toàn diện từng component
- ✅ **Auto-Detection**: Tự động phát hiện OS và cấu hình phù hợp
- ✅ **Improved Security**: Cấu hình bảo mật tốt hơn

## 🚀 Cách sử dụng

### 📦 Yêu cầu trước khi bắt đầu

1. **LocalStack đang chạy** và EC2 instance đã được tạo
2. **Key file** `my-local-key.pem` có trong thư mục hiện tại
3. **Laravel application** trong thư mục `laravel/`
4. **Quyền thực thi** cho các script

### 🎯 1. Deployment tự động (Khuyến nghị)

```bash
# Chạy script deployment tổng hợp - Tự động làm tất cả!
chmod +x deploy-laravel-to-ec2.sh
./deploy-laravel-to-ec2.sh
```

**Script này sẽ:**
- ✅ Kiểm tra prerequisites
- ✅ Cài đặt LAMP stack
- ✅ Deploy Laravel application
- ✅ Cấu hình database
- ✅ Tối ưu hóa cho production
- ✅ Chạy kiểm tra toàn diện

### 🔧 2. Deployment từng bước (Advanced)

#### Bước 1: Setup LAMP Stack
```bash
chmod +x setup-ec2-lamp.sh
./setup-ec2-lamp.sh
```
*Cài đặt Apache, MySQL/MariaDB, PHP, Composer*

#### Bước 2: Configure Laravel
```bash
chmod +x configure-laravel-ec2.sh
./configure-laravel-ec2.sh
```
*Deploy Laravel, cấu hình database, tối ưu hóa*

#### Bước 3: Kiểm tra trạng thái
```bash
chmod +x check-ec2-status.sh
./check-ec2-status.sh
```
*Kiểm tra toàn diện tất cả components*

### 🔍 3. Kiểm tra nhanh

```bash
# Kiểm tra trạng thái hệ thống
./check-ec2-status.sh

# Truy cập ứng dụng
curl -I http://54.214.83.189

# SSH vào server
ssh -i my-local-key.pem ec2-user@54.214.83.189
```

## 🗄️ Thông tin Database

| Thông số | Giá trị |
|----------|---------|
| **Database Name** | laravel_db |
| **Username** | laravel_user |
| **Password** | laravel_password |
| **Root Password** | rootpassword |
| **Host** | localhost |
| **Port** | 3306 |

## 📁 Cấu trúc thư mục trên server

```
/var/www/html/laravel/          # 🏠 Laravel application root
├── app/                        # 💼 Application code
├── public/                     # 🌐 Web root (DocumentRoot)
├── storage/                    # 💾 Storage directory (logs, cache, uploads)
├── bootstrap/cache/            # ⚡ Bootstrap cache
├── vendor/                     # 📦 Composer dependencies
├── .env                        # ⚙️ Environment configuration
└── artisan                     # 🛠️ Laravel CLI tool
```

## 🌐 URLs và Endpoints

| URL | Mô tả |
|-----|-------|
| **http://54.214.83.189** | 🏠 Laravel Application |
| **http://54.214.83.189/info.php** | 🔍 PHP Information |

## 📊 Monitoring và Logs

### Log Files
```bash
# Apache Logs
sudo tail -f /var/log/httpd/error_log        # Amazon Linux/CentOS
sudo tail -f /var/log/apache2/error.log      # Ubuntu

# Laravel Logs
tail -f /var/www/html/laravel/storage/logs/laravel.log

# System Logs
sudo journalctl -u httpd -f                  # Apache service logs
sudo journalctl -u mariadb -f                # MariaDB service logs
```

## 🛠️ Troubleshooting Guide

### 🔍 1. Chẩn đoán nhanh
```bash
# Chạy script kiểm tra toàn diện
./check-ec2-status.sh

# Kiểm tra kết nối SSH
ssh -i my-local-key.pem ec2-user@54.214.83.189 "echo 'Connection OK'"

# Test HTTP response
curl -I http://54.214.83.189
```

### 🚨 2. Các lỗi thường gặp

#### ❌ SSH Connection Failed
```bash
# Kiểm tra key permissions
chmod 600 my-local-key.pem

# Kiểm tra LocalStack
docker ps | grep localstack

# Kiểm tra EC2 instance
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

#### ❌ LAMP Installation Failed
```bash
# Kiểm tra OS type
ssh -i my-local-key.pem ec2-user@54.214.83.189 "cat /etc/os-release"

# Chạy lại từng bước
./setup-ec2-lamp.sh

# Kiểm tra services
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo systemctl status httpd mariadb"
```

#### ❌ Laravel Configuration Failed
```bash
# Kiểm tra database connection
ssh -i my-local-key.pem ec2-user@54.214.83.189 "mysql -u laravel_user -plaravel_password -e 'SELECT 1;'"

# Kiểm tra Laravel directory
ssh -i my-local-key.pem ec2-user@54.214.83.189 "ls -la /var/www/html/laravel"

# Chạy lại Laravel config
./configure-laravel-ec2.sh
```

#### ❌ HTTP 500 Error
```bash
# Kiểm tra Laravel logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 "tail -20 /var/www/html/laravel/storage/logs/laravel.log"

# Kiểm tra Apache logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo tail -20 /var/log/httpd/error_log"

# Fix permissions
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo chown -R apache:apache /var/www/html/laravel && sudo chmod -R 755 /var/www/html/laravel && sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache"
```

### 🔧 3. Commands hữu ích

#### Service Management
```bash
# Amazon Linux/CentOS
sudo systemctl restart httpd mariadb
sudo systemctl status httpd mariadb

# Ubuntu
sudo systemctl restart apache2 mysql
sudo systemctl status apache2 mysql
```

#### File Permissions
```bash
# Amazon Linux/CentOS
sudo chown -R apache:apache /var/www/html/laravel

# Ubuntu
sudo chown -R www-data:www-data /var/www/html/laravel

# Common permissions
sudo chmod -R 755 /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache
```

## 🎯 Laravel Commands hữu ích

### 🔗 SSH Access
```bash
# Kết nối SSH
ssh -i my-local-key.pem ec2-user@54.214.83.189

# Navigate to Laravel directory
cd /var/www/html/laravel
```

### 📋 Basic Commands
```bash
# Check Laravel version
php artisan --version

# Check environment
php artisan env

# List all routes
php artisan route:list

# Check migration status
php artisan migrate:status
```

### 🗄️ Database Commands
```bash
# Run migrations
php artisan migrate

# Rollback migrations
php artisan migrate:rollback

# Seed database
php artisan db:seed

# Fresh migration with seed
php artisan migrate:fresh --seed
```

### 🧹 Cache Management
```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

### 🔧 Maintenance Commands
```bash
# Put application in maintenance mode
php artisan down

# Bring application back online
php artisan up

# Generate application key
php artisan key:generate

# Create symbolic link for storage
php artisan storage:link
```

## 🔒 Security Notes

| Aspect | Configuration |
|--------|---------------|
| **Firewall** | Chỉ mở port 80 (HTTP) và 22 (SSH) |
| **Database** | MySQL/MariaDB chỉ listen trên localhost |
| **File Permissions** | Đã set đúng permissions cho Laravel |
| **Environment** | Production mode (debug disabled) |
| **SSL/HTTPS** | Có thể cấu hình thêm với Let's Encrypt |

## 📊 Monitoring và Health Check

### 🔍 Quick Status Check
```bash
# Comprehensive status check
./check-ec2-status.sh

# Simple HTTP check
curl -I http://54.214.83.189

# Check specific services
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo systemctl is-active httpd mariadb"
```

### 📈 Real-time Monitoring
```bash
# Monitor Apache access logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 'sudo tail -f /var/log/httpd/access_log'

# Monitor Laravel logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 'tail -f /var/www/html/laravel/storage/logs/laravel.log'

# Monitor system resources
ssh -i my-local-key.pem ec2-user@54.214.83.189 'htop'
```

## 💾 Backup và Maintenance

### 🗄️ Database Backup
```bash
# Connect to server
ssh -i my-local-key.pem ec2-user@54.214.83.189

# Create database backup
mysqldump -u laravel_user -plaravel_password laravel_db > laravel_backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
mysql -u laravel_user -plaravel_password laravel_db < laravel_backup_20250820_120000.sql
```

### 📁 Application Backup
```bash
# Full application backup
ssh -i my-local-key.pem ec2-user@54.214.83.189
tar -czf laravel-backup-$(date +%Y%m%d_%H%M%S).tar.gz /var/www/html/laravel

# Backup only important files
tar -czf laravel-essential-$(date +%Y%m%d_%H%M%S).tar.gz \
  /var/www/html/laravel/app \
  /var/www/html/laravel/config \
  /var/www/html/laravel/database \
  /var/www/html/laravel/resources \
  /var/www/html/laravel/routes \
  /var/www/html/laravel/.env
```

### 🔄 Automated Backup Script
```bash
# Create backup script
cat > /home/ec2-user/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/ec2-user/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database backup
mysqldump -u laravel_user -plaravel_password laravel_db > $BACKUP_DIR/db_$DATE.sql

# Application backup
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /var/www/html/laravel

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
EOF

chmod +x /home/ec2-user/backup.sh

# Add to crontab for daily backup at 2 AM
echo "0 2 * * * /home/ec2-user/backup.sh" | crontab -
```

## 🎯 Performance Optimization

### ⚡ Laravel Optimization
```bash
# Production optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Enable OPcache (if not already enabled)
sudo nano /etc/php.ini
# opcache.enable=1
# opcache.memory_consumption=128
# opcache.max_accelerated_files=4000
```

### 🔧 Apache Optimization
```bash
# Enable compression
sudo nano /etc/httpd/conf/httpd.conf
# LoadModule deflate_module modules/mod_deflate.so

# Add to virtual host
<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Location>
```

## 📞 Support và Troubleshooting

### 🆘 Khi gặp vấn đề

1. **🔍 Chạy diagnostic**: `./check-ec2-status.sh`
2. **📋 Xem logs**: Check Apache và Laravel logs
3. **🔄 Restart services**: `sudo systemctl restart httpd mariadb`
4. **🔧 Fix permissions**: Chạy lại permission commands
5. **📖 Check documentation**: Đọc lại hướng dẫn này

### 📧 Thông tin hệ thống

| Component | Details |
|-----------|---------|
| **LocalStack Endpoint** | http://localhost:4566 |
| **Environment** | Production |
| **Debug Mode** | Disabled (for security) |
| **Session Driver** | Database |
| **Cache Driver** | Database |
| **Queue Driver** | Database |

---

## 🎉 Kết luận

Bạn đã thành công deploy Laravel application với LAMP stack trên LocalStack EC2!

### ✅ Những gì đã hoàn thành:
- ✅ LAMP Stack (Apache, MySQL/MariaDB, PHP)
- ✅ Laravel Application deployment
- ✅ Database configuration
- ✅ Production optimization
- ✅ Security configuration
- ✅ Monitoring tools

### 🚀 Bước tiếp theo:
1. Customize Laravel application theo nhu cầu
2. Setup SSL/HTTPS nếu cần
3. Configure monitoring và alerting
4. Setup automated backups
5. Scale application nếu cần

**Happy coding! 🎯**
