# 🚀 Quick Start Guide - Laravel LAMP Stack trên LocalStack EC2

## ⚡ Deployment trong 5 phút

### 📋 Prerequisites
- ✅ LocalStack đang chạy
- ✅ EC2 instance đã tạo (i-c4dd20590d3404ed6)
- ✅ Key file `my-local-key.pem` trong thư mục hiện tại
- ✅ Laravel app trong thư mục `laravel/`

### 🎯 Bước 1: Chạy Deployment Script
```bash
# Một lệnh duy nhất để deploy tất cả!
chmod +x deploy-laravel-to-ec2.sh
./deploy-laravel-to-ec2.sh
```

### 🎉 Bước 2: Truy cập Application
```bash
# Mở browser và truy cập:
http://54.214.83.189
```

### 🔍 Bước 3: Kiểm tra Status (nếu cần)
```bash
# Chạy comprehensive health check
./check-ec2-status.sh
```

---

## 🛠️ Troubleshooting nhanh

### ❌ Nếu deployment failed:

#### 1. SSH Connection Issues
```bash
chmod 600 my-local-key.pem
ssh -i my-local-key.pem ec2-user@54.214.83.189 "echo 'test'"
```

#### 2. LAMP Installation Issues
```bash
# Chạy lại setup
./setup-ec2-lamp.sh

# Kiểm tra services
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo systemctl status httpd mariadb"
```

#### 3. Laravel Configuration Issues
```bash
# Chạy lại config
./configure-laravel-ec2.sh

# Check Laravel
ssh -i my-local-key.pem ec2-user@54.214.83.189 "cd /var/www/html/laravel && php artisan --version"
```

#### 4. HTTP 500 Error
```bash
# Fix permissions
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo chown -R apache:apache /var/www/html/laravel && sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache"

# Check logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 "tail -20 /var/www/html/laravel/storage/logs/laravel.log"
```

---

## 📊 Quick Commands

### 🔗 SSH Access
```bash
ssh -i my-local-key.pem ec2-user@54.214.83.189
```

### 🔄 Restart Services
```bash
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo systemctl restart httpd mariadb"
```

### 📋 Laravel Commands
```bash
# SSH vào server và chạy:
cd /var/www/html/laravel
php artisan --version
php artisan migrate:status
php artisan cache:clear
```

### 📈 Monitor Logs
```bash
# Apache logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo tail -f /var/log/httpd/error_log"

# Laravel logs
ssh -i my-local-key.pem ec2-user@54.214.83.189 "tail -f /var/www/html/laravel/storage/logs/laravel.log"
```

---

## 🎯 URLs

| Service | URL |
|---------|-----|
| **Laravel App** | http://54.214.83.189 |
| **PHP Info** | http://54.214.83.189/info.php |

---

## 📞 Support

- 📖 **Full Documentation**: `EC2-DEPLOYMENT-README.md`
- 🔍 **Status Check**: `./check-ec2-status.sh`
- 🛠️ **Manual Setup**: Chạy từng script riêng lẻ

---

**🎉 That's it! Your Laravel app should be running on LocalStack EC2!**
