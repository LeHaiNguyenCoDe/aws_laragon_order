# 🚀 Laravel LAMP Stack on LocalStack EC2

**Automated deployment solution for Laravel applications on LocalStack EC2 with complete LAMP stack setup.**

## ⚡ Quick Start

```bash
# One command to deploy everything!
./deploy.sh
```

**Choose option 1 for automatic deployment**

---

## 📁 Project Structure

```
📁 dockerLocalStack/
├── 🚀 deploy.sh                    # Main entry point
├── 📁 scripts/                     # All deployment scripts
│   ├── setup.sh                    # Setup script
│   ├── run-all.sh                  # Interactive menu
│   ├── deploy-laravel-to-ec2.sh    # Main deployment
│   ├── setup-ec2-lamp.sh           # LAMP installation
│   ├── configure-laravel-ec2.sh    # Laravel configuration
│   ├── check-ec2-status.sh         # Status check
│   └── test-deployment.sh          # Comprehensive testing
├── 📁 docs/                        # Documentation
│   ├── README.md                   # Detailed documentation
│   ├── QUICK-START.md              # Quick start guide
│   ├── EC2-DEPLOYMENT-README.md    # Technical guide
│   └── FILES-OVERVIEW.md           # Files overview
├── 📁 config/                      # Configuration files
│   ├── docker-compose-fixed.yml    # LocalStack config
│   └── my-local-key.pem           # SSH key
└── 📁 laravel/                     # Laravel application
```

---

## 🎯 Usage Options

### 1. 🚀 Quick Deployment
```bash
./deploy.sh
# Choose option 1
```

### 2. 🔧 Interactive Menu
```bash
./deploy.sh
# Choose option 2
```

### 3. 🔍 Check Status
```bash
./deploy.sh
# Choose option 3
```

### 4. 📖 View Documentation
```bash
./deploy.sh
# Choose option 5
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

## 🌐 URLs

| URL | Description |
|-----|-------------|
| **http://54.214.223.198** | 🎯 Primary Laravel Application |
| **http://localhost:8080** | 🔄 Alternative access via LocalStack |

---

## ✨ Features

- ✅ **Organized Structure** - Clean folder organization
- ✅ **One-Click Deployment** - Single command deployment
- ✅ **Multi-OS Support** (Amazon Linux, Ubuntu, CentOS)
- ✅ **Interactive Menu** - Easy-to-use interface
- ✅ **Comprehensive Testing** - Full validation suite
- ✅ **Detailed Documentation** - Complete guides
- ✅ **Error Handling** - Robust error management
- ✅ **Status Monitoring** - Real-time status checks

---

## 🛠️ Troubleshooting

### Quick Commands
```bash
# Check system status
./deploy.sh  # Choose option 3

# Run comprehensive tests  
./deploy.sh  # Choose option 4

# SSH to server
ssh -i config/my-local-key.pem ec2-user@54.214.223.198
```

### Common Issues
- **SSH Connection Failed**: Check key permissions
- **HTTP 500 Error**: Check file permissions and Laravel logs
- **LocalStack Issues**: Restart with `docker-compose -f config/docker-compose-fixed.yml restart`

---

## 📖 Documentation

- **📋 Main Docs**: `docs/README.md`
- **⚡ Quick Start**: `docs/QUICK-START.md`
- **📖 Technical Guide**: `docs/EC2-DEPLOYMENT-README.md`
- **📁 Files Overview**: `docs/FILES-OVERVIEW.md`

---

## 🎉 Success Indicators

✅ **HTTP 200 Response** from http://54.214.223.198  
✅ **All Services Running** (Apache, MySQL/MariaDB)  
✅ **Laravel Artisan Working**  
✅ **Database Connected**  
✅ **Proper File Permissions**  

---

**🚀 Ready to deploy? Run `./deploy.sh` and choose your option!**
