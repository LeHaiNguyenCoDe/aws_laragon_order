#!/bin/bash

# 🧪 Test Laravel CI/CD Setup
# This script tests the CI/CD pipeline locally before deploying to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}"
echo "=========================================="
echo "  🧪 Laravel CI/CD Pipeline Test"
echo "  📍 Local Testing Before AWS Deployment"
echo "=========================================="
echo -e "${NC}"

# Function to print status
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test 1: Check Laravel project structure
test_laravel_structure() {
    print_status "Testing Laravel project structure..."
    
    cd laravel
    
    if [[ -f "artisan" && -f "composer.json" && -d "app" ]]; then
        print_success "Laravel project structure is valid"
    else
        print_error "Invalid Laravel project structure"
        return 1
    fi
    
    cd ..
}

# Test 2: Check Docker files
test_docker_files() {
    print_status "Testing Docker configuration..."
    
    if [[ -f "laravel/Dockerfile" ]]; then
        print_success "Dockerfile exists"
    else
        print_error "Dockerfile missing"
        return 1
    fi
    
    if [[ -f "laravel/docker-compose.yml" ]]; then
        print_success "docker-compose.yml exists"
    else
        print_error "docker-compose.yml missing"
        return 1
    fi
    
    if [[ -d "laravel/.docker" ]]; then
        print_success "Docker configuration directory exists"
    else
        print_error "Docker configuration directory missing"
        return 1
    fi
}

# Test 3: Check GitHub Actions workflow
test_github_actions() {
    print_status "Testing GitHub Actions workflow..."
    
    if [[ -f "laravel/.github/workflows/deploy.yml" ]]; then
        print_success "GitHub Actions workflow exists"
    else
        print_error "GitHub Actions workflow missing"
        return 1
    fi
    
    # Validate YAML syntax
    if command -v yamllint &> /dev/null; then
        if yamllint laravel/.github/workflows/deploy.yml &> /dev/null; then
            print_success "GitHub Actions workflow YAML is valid"
        else
            print_warning "GitHub Actions workflow YAML has issues"
        fi
    else
        print_warning "yamllint not installed, skipping YAML validation"
    fi
}

# Test 4: Check AWS configuration
test_aws_config() {
    print_status "Testing AWS configuration..."
    
    if [[ -f "laravel/.aws/task-definition.json" ]]; then
        print_success "ECS task definition exists"
    else
        print_error "ECS task definition missing"
        return 1
    fi
    
    if [[ -d "laravel/terraform" ]]; then
        print_success "Terraform configuration exists"
    else
        print_error "Terraform configuration missing"
        return 1
    fi
}

# Test 5: Build Docker image locally
test_docker_build() {
    print_status "Testing Docker image build..."
    
    cd laravel
    
    if docker build -t laravel-test:latest . &> /dev/null; then
        print_success "Docker image builds successfully"
        
        # Clean up test image
        docker rmi laravel-test:latest &> /dev/null || true
    else
        print_error "Docker image build failed"
        cd ..
        return 1
    fi
    
    cd ..
}

# Test 6: Test local development environment
test_local_environment() {
    print_status "Testing local development environment..."
    
    cd laravel
    
    # Check if we can start the environment
    if docker-compose config &> /dev/null; then
        print_success "Docker Compose configuration is valid"
    else
        print_error "Docker Compose configuration is invalid"
        cd ..
        return 1
    fi
    
    # Try to start services (without actually running them)
    print_status "Validating service definitions..."
    
    if docker-compose ps &> /dev/null; then
        print_success "Docker Compose services are properly defined"
    else
        print_warning "Docker Compose services may have issues"
    fi
    
    cd ..
}

# Test 7: Check Laravel dependencies
test_laravel_dependencies() {
    print_status "Testing Laravel dependencies..."
    
    cd laravel
    
    if [[ -f "composer.lock" ]]; then
        print_success "Composer dependencies are locked"
    else
        print_warning "Composer dependencies not locked (run composer install)"
    fi
    
    if [[ -f "package-lock.json" ]]; then
        print_success "NPM dependencies are locked"
    else
        print_warning "NPM dependencies not locked (run npm install)"
    fi
    
    cd ..
}

# Test 8: Check Makefile commands
test_makefile() {
    print_status "Testing Makefile commands..."
    
    cd laravel
    
    if [[ -f "Makefile" ]]; then
        print_success "Makefile exists"
        
        # Test if make help works
        if make help &> /dev/null; then
            print_success "Makefile help command works"
        else
            print_warning "Makefile help command has issues"
        fi
    else
        print_error "Makefile missing"
        cd ..
        return 1
    fi
    
    cd ..
}

# Test 9: Check environment files
test_environment_files() {
    print_status "Testing environment configuration..."
    
    cd laravel
    
    if [[ -f ".env.example" ]]; then
        print_success ".env.example exists"
    else
        print_warning ".env.example missing"
    fi
    
    if [[ -f ".env" ]]; then
        print_success ".env exists"
    else
        print_warning ".env missing (will be created from .env.example)"
    fi
    
    cd ..
}

# Test 10: Validate deployment script
test_deployment_script() {
    print_status "Testing deployment script..."
    
    if [[ -f "deploy-to-aws.sh" ]]; then
        print_success "Deployment script exists"
        
        if [[ -x "deploy-to-aws.sh" ]]; then
            print_success "Deployment script is executable"
        else
            print_warning "Deployment script is not executable (run chmod +x deploy-to-aws.sh)"
        fi
    else
        print_error "Deployment script missing"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    local failed_tests=0
    
    test_laravel_structure || ((failed_tests++))
    test_docker_files || ((failed_tests++))
    test_github_actions || ((failed_tests++))
    test_aws_config || ((failed_tests++))
    test_docker_build || ((failed_tests++))
    test_local_environment || ((failed_tests++))
    test_laravel_dependencies || ((failed_tests++))
    test_makefile || ((failed_tests++))
    test_environment_files || ((failed_tests++))
    test_deployment_script || ((failed_tests++))
    
    echo ""
    echo -e "${CYAN}=========================================="
    echo "  📊 Test Results Summary"
    echo "==========================================${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! Your CI/CD setup is ready.${NC}"
        echo ""
        echo -e "${CYAN}🚀 Next steps:${NC}"
        echo "1. Configure AWS credentials: aws configure"
        echo "2. Run deployment: ./deploy-to-aws.sh"
        echo "3. Set up GitHub secrets for CI/CD"
        echo "4. Push to main branch to trigger deployment"
    else
        echo -e "${RED}❌ $failed_tests test(s) failed. Please fix the issues above.${NC}"
        echo ""
        echo -e "${CYAN}🔧 Common fixes:${NC}"
        echo "• Run: chmod +x deploy-to-aws.sh"
        echo "• Install missing dependencies"
        echo "• Check Docker is running"
        echo "• Verify file paths and structure"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${CYAN}Starting CI/CD pipeline tests...${NC}"
    echo ""
    
    run_all_tests
}

# Run main function
main "$@"
