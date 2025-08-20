# 🏗️ Terraform Variables for Professional Laravel Infrastructure

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (development, staging, production, demo)"
  type        = string
  validation {
    condition = contains(["development", "staging", "production", "demo"], var.environment)
    error_message = "Environment must be one of: development, staging, production, demo."
  }
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "laravel-app"
}

# 🌐 Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# 🗄️ Database Configuration
variable "database_name" {
  description = "Database name"
  type        = string
  default     = "laravel"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "laravel"
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "RDS maximum allocated storage in GB"
  type        = number
  default     = 100
}

# 📦 Container Configuration
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "laravel-app"
}

variable "ecs_task_cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "ECS task memory in MB"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

# 🔒 Security Configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# 📊 Monitoring Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# 🏷️ Tagging
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# 🌍 Environment-specific configurations
locals {
  environment_configs = {
    development = {
      rds_instance_class    = "db.t3.micro"
      ecs_desired_count     = 1
      enable_deletion_protection = false
      backup_retention_period = 1
      log_retention_days    = 3
    }
    staging = {
      rds_instance_class    = "db.t3.small"
      ecs_desired_count     = 2
      enable_deletion_protection = false
      backup_retention_period = 3
      log_retention_days    = 7
    }
    production = {
      rds_instance_class    = "db.t3.medium"
      ecs_desired_count     = 3
      enable_deletion_protection = true
      backup_retention_period = 7
      log_retention_days    = 30
    }
    demo = {
      rds_instance_class    = "db.t3.micro"
      ecs_desired_count     = 1
      enable_deletion_protection = false
      backup_retention_period = 1
      log_retention_days    = 1
    }
  }
  
  current_config = local.environment_configs[var.environment]
  
  common_tags = merge(
    {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )
}
