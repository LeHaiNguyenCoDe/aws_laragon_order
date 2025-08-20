#!/bin/bash

# Laravel LAMP Stack Deployment - Main Entry Point
# This script provides easy access to all deployment functions

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}"
echo "=========================================="
echo "  🚀 Laravel LAMP Stack Deployment"
echo "  📍 LocalStack EC2 - Organized Structure"
echo "=========================================="
echo -e "${NC}"

# Make scripts executable
chmod +x scripts/*.sh

echo -e "${BLUE}📁 Project Structure:${NC}"
echo "  📁 scripts/     - All deployment scripts"
echo "  📁 docs/        - Documentation files"
echo "  📁 config/      - Configuration files"
echo "  📁 laravel/     - Laravel application"
echo ""

echo -e "${YELLOW}🎯 Deployment Options:${NC}"
echo ""
echo "1. 🚀 Full Automatic Deployment"
echo "2. 🔧 Interactive Menu"
echo "3. 🔍 Check System Status"
echo "4. 🧪 Run Tests"
echo "5. 📖 View Documentation"
echo "6. ⚙️  Setup/Make Executable"
echo ""

read -p "Choose option (1-6): " choice

case $choice in
    1)
        echo -e "${GREEN}🚀 Starting automatic deployment...${NC}"
        cd scripts && DOCKER_COMPOSE_FILE="../config/docker-compose-fixed.yml" KEY_FILE="../config/my-local-key.pem" ./deploy-laravel-to-ec2.sh
        ;;
    2)
        echo -e "${GREEN}🔧 Opening interactive menu...${NC}"
        cd scripts && ./run-all.sh
        ;;
    3)
        echo -e "${GREEN}🔍 Checking system status...${NC}"
        cd scripts && ./check-ec2-status.sh
        ;;
    4)
        echo -e "${GREEN}🧪 Running comprehensive tests...${NC}"
        cd scripts && ./test-deployment.sh
        ;;
    5)
        echo -e "${GREEN}📖 Available documentation:${NC}"
        echo ""
        echo "📋 Main Documentation:"
        echo "  cat docs/README.md"
        echo ""
        echo "⚡ Quick Start Guide:"
        echo "  cat docs/QUICK-START.md"
        echo ""
        echo "📖 Detailed Guide:"
        echo "  cat docs/EC2-DEPLOYMENT-README.md"
        echo ""
        echo "📁 Files Overview:"
        echo "  cat docs/FILES-OVERVIEW.md"
        ;;
    6)
        echo -e "${GREEN}⚙️ Setting up scripts...${NC}"
        cd scripts && ./setup.sh
        ;;
    *)
        echo -e "${YELLOW}Invalid choice. Please run again and choose 1-6.${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}🌐 URLs after deployment:${NC}"
echo "  • Primary: http://54.214.223.198"
echo "  • Alternative: http://localhost:8080"
echo ""
echo -e "${PURPLE}🎯 Quick access: ./deploy.sh${NC}"
