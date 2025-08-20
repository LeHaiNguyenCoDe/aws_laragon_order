# 🚀 Laravel LAMP Stack on LocalStack EC2

**Automated deployment solution for Laravel applications on LocalStack EC2 with complete LAMP stack setup.**

## 🎯 Quick Start

```bash
# One command to deploy everything!
chmod +x run-all.sh
./run-all.sh
```

**Your Laravel app will be running at: http://54.214.83.189**

---

## 📋 What's Included

| Component | Description |
|-----------|-------------|
| **🔧 Automated Scripts** | Complete deployment automation |
| **🏗️ LAMP Stack** | Apache, MySQL/MariaDB, PHP 8.1+ |
| **⚙️ Laravel Setup** | Production-ready configuration |
| **🧪 Testing Suite** | Comprehensive validation tests |
| **📖 Documentation** | Detailed guides and troubleshooting |

---

## 📁 Project Structure

```
├── 🚀 run-all.sh                    # Main deployment script
├── 📦 deploy-laravel-to-ec2.sh      # Automated deployment
├── 🔧 setup-ec2-lamp.sh             # LAMP stack installation
├── ⚙️ configure-laravel-ec2.sh      # Laravel configuration
├── 🔍 check-ec2-status.sh           # System status check
├── 🧪 test-deployment.sh            # Comprehensive testing
├── 📖 EC2-DEPLOYMENT-README.md      # Complete documentation
├── ⚡ QUICK-START.md                # Quick start guide
├── 🔑 my-local-key.pem              # EC2 key file
└── 📁 laravel/                      # Your Laravel application
```

---

## 🎯 Usage Options

### 1. 🚀 Fully Automated (Recommended)
```bash
./run-all.sh
# Choose option 1 for full automation
```

### 2. ⚡ Quick Deployment
```bash
./deploy-laravel-to-ec2.sh
```

### 3. 🔧 Manual Step-by-Step
```bash
./setup-ec2-lamp.sh        # Install LAMP
./configure-laravel-ec2.sh # Configure Laravel
./check-ec2-status.sh      # Check status
```

### 4. 🧪 Test Existing Setup
```bash
./test-deployment.sh
```

---

## 🏗️ System Information

| Setting | Value |
|---------|-------|
| **Instance ID** | i-cd2d73cbd14fd6c58 |
| **Public IP** | 54.214.223.198 |
| **Database** | laravel_db |
| **DB User** | laravel_user |
| **Web Server** | Apache |
| **PHP Version** | 8.1+ |

---

## ✨ Features

- ✅ **Multi-OS Support** (Amazon Linux, Ubuntu, CentOS)
- ✅ **Automated LAMP Installation**
- ✅ **Laravel Production Setup**
- ✅ **Database Configuration**
- ✅ **Security Hardening**
- ✅ **Performance Optimization**
- ✅ **Comprehensive Testing**
- ✅ **Detailed Logging**
- ✅ **Error Handling**
- ✅ **Troubleshooting Tools**

---

## 📖 Documentation

- **⚡ Quick Start**: [QUICK-START.md](QUICK-START.md)
- **📖 Complete Guide**: [EC2-DEPLOYMENT-README.md](EC2-DEPLOYMENT-README.md)

---

## 🛠️ Troubleshooting

### Quick Fixes
```bash
# Check system status
./check-ec2-status.sh

# Run comprehensive tests
./test-deployment.sh

# SSH to server
ssh -i my-local-key.pem ec2-user@54.214.83.189

# Restart services
ssh -i my-local-key.pem ec2-user@54.214.83.189 "sudo systemctl restart httpd mariadb"
```

### Common Issues
- **SSH Connection Failed**: Check key permissions (`chmod 600 my-local-key.pem`)
- **HTTP 500 Error**: Check file permissions and Laravel logs
- **Database Connection**: Verify MySQL/MariaDB service status

---

## 🎉 Success Indicators

✅ **HTTP 200 Response** from http://54.214.83.189
✅ **All Services Running** (Apache, MySQL/MariaDB)
✅ **Laravel Artisan Working**
✅ **Database Connected**
✅ **Proper File Permissions**

---

## 📞 Support

1. 🔍 Run diagnostic: `./check-ec2-status.sh`
2. 🧪 Run tests: `./test-deployment.sh`
3. 📖 Check documentation: `EC2-DEPLOYMENT-README.md`
4. 🔧 Manual troubleshooting steps in docs

---

## 🌐 **URLs sau khi deploy:**

| URL | Mô tả |
|-----|-------|
| **http://54.214.223.198** | 🎯 Primary Laravel Application |
| **http://localhost:8080** | 🔄 Alternative access via LocalStack |

---

## 🎯 **Quick Commands:**

```bash
# Deploy everything
bash deploy-laravel-to-ec2.sh

# Check status
bash check-ec2-status.sh

# Run tests
bash test-deployment.sh

# SSH to server
ssh -i my-local-key.pem ec2-user@54.214.223.198
```

---

**🚀 Happy coding with Laravel on LocalStack EC2!**