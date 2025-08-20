#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${PURPLE}"
echo "=========================================="
echo "  🚀 Laravel LAMP Stack - Complete Setup"
echo "  📍 LocalStack EC2 Instance"
echo "  🔧 Automated Deployment & Testing v2.0"
echo "=========================================="
echo -e "${NC}"

# Function to print section headers
print_section() {
    echo ""
    echo -e "${CYAN}=========================================="
    echo -e "  $1"
    echo -e "==========================================${NC}"
    echo ""
}

# Function to check if script exists and is executable
check_script() {
    local script="$1"
    if [ ! -f "$script" ]; then
        echo -e "${RED}❌ Error: $script not found!${NC}"
        return 1
    fi
    chmod +x "$script"
    return 0
}

# Check prerequisites
print_section "📋 Checking Prerequisites"

echo -e "${BLUE}Checking required files...${NC}"

# Check key file
if [ ! -f "my-local-key.pem" ]; then
    echo -e "${RED}❌ my-local-key.pem not found!${NC}"
    echo "Please ensure your EC2 key file is in the current directory."
    exit 1
fi
echo -e "${GREEN}✅ Key file found${NC}"

# Check Laravel directory
if [ ! -d "laravel" ]; then
    echo -e "${RED}❌ Laravel directory not found!${NC}"
    echo "Please ensure your Laravel application is in the 'laravel' directory."
    exit 1
fi
echo -e "${GREEN}✅ Laravel directory found${NC}"

# Check scripts
SCRIPTS=("deploy-laravel-to-ec2.sh" "setup-ec2-lamp.sh" "configure-laravel-ec2.sh" "check-ec2-status.sh" "test-deployment.sh")
for script in "${SCRIPTS[@]}"; do
    if check_script "$script"; then
        echo -e "${GREEN}✅ $script ready${NC}"
    else
        echo -e "${RED}❌ $script missing${NC}"
        exit 1
    fi
done

echo -e "${GREEN}🎉 All prerequisites satisfied!${NC}"

# Ask user for deployment option
print_section "🎯 Deployment Options"

echo "Choose your deployment option:"
echo "1. 🚀 Full Automatic Deployment (Recommended)"
echo "2. 🔧 Manual Step-by-Step Deployment"
echo "3. 🧪 Test Existing Deployment"
echo "4. 🔍 Check System Status Only"
echo "5. 📖 Show Documentation"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_section "🚀 Starting Full Automatic Deployment"
        echo -e "${BLUE}This will automatically:${NC}"
        echo "• Install LAMP stack"
        echo "• Deploy Laravel application"
        echo "• Configure database"
        echo "• Optimize for production"
        echo "• Run comprehensive tests"
        echo ""
        read -p "Continue? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${YELLOW}🚀 Running deployment...${NC}"
            if ./deploy-laravel-to-ec2.sh; then
                echo ""
                print_section "🧪 Running Comprehensive Tests"
                ./test-deployment.sh
            else
                echo -e "${RED}❌ Deployment failed!${NC}"
                exit 1
            fi
        else
            echo "Deployment cancelled."
            exit 0
        fi
        ;;
    2)
        print_section "🔧 Manual Step-by-Step Deployment"
        echo -e "${BLUE}Step 1: LAMP Stack Installation${NC}"
        read -p "Install LAMP stack? (y/N): " confirm1
        if [[ $confirm1 =~ ^[Yy]$ ]]; then
            ./setup-ec2-lamp.sh
        fi
        
        echo ""
        echo -e "${BLUE}Step 2: Laravel Configuration${NC}"
        read -p "Configure Laravel application? (y/N): " confirm2
        if [[ $confirm2 =~ ^[Yy]$ ]]; then
            ./configure-laravel-ec2.sh
        fi
        
        echo ""
        echo -e "${BLUE}Step 3: System Status Check${NC}"
        read -p "Run status check? (y/N): " confirm3
        if [[ $confirm3 =~ ^[Yy]$ ]]; then
            ./check-ec2-status.sh
        fi
        
        echo ""
        echo -e "${BLUE}Step 4: Comprehensive Testing${NC}"
        read -p "Run comprehensive tests? (y/N): " confirm4
        if [[ $confirm4 =~ ^[Yy]$ ]]; then
            ./test-deployment.sh
        fi
        ;;
    3)
        print_section "🧪 Testing Existing Deployment"
        echo -e "${BLUE}Running comprehensive test suite...${NC}"
        ./test-deployment.sh
        ;;
    4)
        print_section "🔍 System Status Check"
        echo -e "${BLUE}Checking system status...${NC}"
        ./check-ec2-status.sh
        ;;
    5)
        print_section "📖 Documentation"
        echo -e "${BLUE}Available documentation:${NC}"
        echo ""
        echo "📋 Quick Start Guide:"
        echo "   cat QUICK-START.md"
        echo ""
        echo "📖 Complete Documentation:"
        echo "   cat EC2-DEPLOYMENT-README.md"
        echo ""
        echo "🔧 Individual Scripts:"
        echo "   ./setup-ec2-lamp.sh        - Install LAMP stack"
        echo "   ./configure-laravel-ec2.sh - Configure Laravel"
        echo "   ./check-ec2-status.sh      - Check system status"
        echo "   ./test-deployment.sh       - Run comprehensive tests"
        echo ""
        read -p "Open Quick Start Guide? (y/N): " show_quick
        if [[ $show_quick =~ ^[Yy]$ ]]; then
            echo ""
            cat QUICK-START.md
        fi
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

print_section "🎉 Process Complete"

echo -e "${GREEN}✨ All done!${NC}"
echo ""
echo -e "${BLUE}🌐 Your Laravel application should be accessible at:${NC}"
echo -e "   ${GREEN}http://54.214.83.189${NC}"
echo ""
echo -e "${BLUE}📚 Quick Commands:${NC}"
echo "   ./check-ec2-status.sh      - Check system status"
echo "   ./test-deployment.sh       - Run comprehensive tests"
echo "   ssh -i my-local-key.pem ec2-user@54.214.83.189  - SSH to server"
echo ""
echo -e "${BLUE}📖 Documentation:${NC}"
echo "   QUICK-START.md             - Quick start guide"
echo "   EC2-DEPLOYMENT-README.md   - Complete documentation"
echo ""
echo -e "${PURPLE}🚀 Happy coding!${NC}"
