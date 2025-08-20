#!/bin/bash

# 🚀 Laravel CI/CD Deployment to AWS
# This script sets up complete CI/CD pipeline for Laravel application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-1"
APP_NAME="laravel-app"
ENVIRONMENT="production"
ECR_REPOSITORY="laravel-app"

echo -e "${PURPLE}"
echo "=========================================="
echo "  🚀 Laravel CI/CD Setup for AWS"
echo "  📍 Complete Infrastructure Deployment"
echo "=========================================="
echo -e "${NC}"

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Get AWS Account ID
get_aws_account_id() {
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_status "AWS Account ID: $AWS_ACCOUNT_ID"
}

# Create ECR repository
create_ecr_repository() {
    print_status "Creating ECR repository..."
    
    if aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION &> /dev/null; then
        print_warning "ECR repository $ECR_REPOSITORY already exists"
    else
        aws ecr create-repository \
            --repository-name $ECR_REPOSITORY \
            --region $AWS_REGION \
            --image-scanning-configuration scanOnPush=true
        print_success "ECR repository created: $ECR_REPOSITORY"
    fi
}

# Update task definition with account ID
update_task_definition() {
    print_status "Updating ECS task definition..."
    
    sed -i.bak "s/YOUR_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" laravel/.aws/task-definition.json
    print_success "Task definition updated with account ID"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd laravel/terraform
    
    # Initialize Terraform
    terraform init
    
    # Plan deployment
    terraform plan -var="aws_region=$AWS_REGION" -var="app_name=$APP_NAME" -var="environment=$ENVIRONMENT"
    
    # Ask for confirmation
    echo -e "${YELLOW}Do you want to deploy the infrastructure? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        terraform apply -var="aws_region=$AWS_REGION" -var="app_name=$APP_NAME" -var="environment=$ENVIRONMENT" -auto-approve
        print_success "Infrastructure deployed successfully!"
    else
        print_warning "Infrastructure deployment skipped"
    fi
    
    cd ../..
}

# Build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    # Login to ECR
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    
    # Build image
    cd laravel
    docker build -t $ECR_REPOSITORY:latest .
    
    # Tag image
    docker tag $ECR_REPOSITORY:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest
    
    # Push image
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest
    
    print_success "Docker image built and pushed successfully!"
    cd ..
}

# Setup GitHub secrets
setup_github_secrets() {
    print_status "Setting up GitHub secrets..."
    
    echo -e "${CYAN}Please add the following secrets to your GitHub repository:${NC}"
    echo "AWS_ACCESS_KEY_ID: Your AWS access key"
    echo "AWS_SECRET_ACCESS_KEY: Your AWS secret key"
    echo ""
    echo -e "${CYAN}Repository Settings > Secrets and variables > Actions${NC}"
    echo ""
    echo "Press Enter when done..."
    read
}

# Display deployment information
display_info() {
    echo -e "${GREEN}"
    echo "=========================================="
    echo "  🎉 Deployment Setup Complete!"
    echo "=========================================="
    echo -e "${NC}"
    
    echo -e "${CYAN}📋 Infrastructure Details:${NC}"
    echo "• AWS Region: $AWS_REGION"
    echo "• Application: $APP_NAME"
    echo "• Environment: $ENVIRONMENT"
    echo "• ECR Repository: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY"
    echo ""
    
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo "1. Push your code to GitHub main/master branch"
    echo "2. GitHub Actions will automatically:"
    echo "   • Run tests"
    echo "   • Build Docker image"
    echo "   • Deploy to AWS ECS"
    echo ""
    
    echo -e "${CYAN}🌐 Access your application:${NC}"
    echo "• Load Balancer URL will be available after first deployment"
    echo "• Check ECS console for service status"
    echo ""
    
    echo -e "${CYAN}📖 Useful commands:${NC}"
    echo "• Check ECS service: aws ecs describe-services --cluster laravel-cluster --services laravel-service"
    echo "• View logs: aws logs tail /ecs/laravel-app --follow"
    echo "• Update infrastructure: cd laravel/terraform && terraform apply"
}

# Main execution
main() {
    check_prerequisites
    get_aws_account_id
    create_ecr_repository
    update_task_definition
    deploy_infrastructure
    build_and_push_image
    setup_github_secrets
    display_info
}

# Run main function
main "$@"
