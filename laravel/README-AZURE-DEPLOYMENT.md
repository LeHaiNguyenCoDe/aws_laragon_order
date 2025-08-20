# 🚀 Laravel Azure AKS Deployment Guide

## 📋 Overview

This repository contains a complete CI/CD pipeline for deploying Laravel applications to Azure Kubernetes Service (AKS) using GitHub Actions, Terraform, and Azure Container Registry (ACR).

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Azure         │    │   Azure         │
│   Actions       │───▶│   Container     │───▶│   Kubernetes    │
│   CI/CD         │    │   Registry      │    │   Service       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Code Quality  │    │   Image Build   │    │   Application   │
│   & Testing     │    │   & Security    │    │   Deployment    │
│                 │    │   Scanning      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Prerequisites

### Azure Setup
1. **Azure Subscription** with appropriate permissions
2. **Service Principal** for GitHub Actions
3. **Storage Account** for Terraform state

### GitHub Secrets Required
```bash
AZURE_CREDENTIALS          # Service Principal JSON
AZURE_STORAGE_ACCOUNT      # Terraform state storage
AZURE_STORAGE_RG           # Storage account resource group
DATABASE_PASSWORD          # MySQL password
```

## 🔧 Setup Instructions

### 1. Create Azure Service Principal

```bash
# Create service principal
az ad sp create-for-rbac --name "laravel-github-actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth

# Output will be JSON - add this to GitHub Secrets as AZURE_CREDENTIALS
```

### 2. Create Storage Account for Terraform State

```bash
# Create resource group
az group create --name terraform-state-rg --location "East US"

# Create storage account
az storage account create \
  --name terraformstate$(date +%s) \
  --resource-group terraform-state-rg \
  --location "East US" \
  --sku Standard_LRS

# Create container
az storage container create \
  --name terraform-state \
  --account-name terraformstate$(date +%s)
```

### 3. Configure GitHub Secrets

Go to your repository → Settings → Secrets and add:

- `AZURE_CREDENTIALS`: Service Principal JSON from step 1
- `AZURE_STORAGE_ACCOUNT`: Storage account name from step 2
- `AZURE_STORAGE_RG`: `terraform-state-rg`
- `DATABASE_PASSWORD`: Strong password for MySQL

### 4. Update Environment Variables

Edit `.github/workflows/professional-cicd.yml`:

```yaml
env:
  AZURE_LOCATION: eastus              # Your preferred region
  ACR_REGISTRY: your-acr-name         # Unique ACR name
  AKS_CLUSTER: your-aks-cluster       # AKS cluster name
  RESOURCE_GROUP: your-resource-group # Resource group name
```

## 🚀 Deployment Process

### Automatic Deployment

The pipeline triggers on:
- Push to `main`, `master`, `develop`, `staging`, `production` branches
- Pull requests to `main`, `master`
- Manual workflow dispatch

### Manual Deployment

```bash
# Go to Actions tab in GitHub
# Select "Professional Laravel CI/CD Pipeline - AKS Deployment"
# Click "Run workflow"
# Choose environment: staging/production/demo
```

## 📁 Project Structure

```
laravel/
├── .github/workflows/
│   └── professional-cicd.yml     # Main CI/CD pipeline
├── terraform/
│   └── main.tf                    # Azure infrastructure
├── docker/
│   ├── nginx/                     # Nginx configuration
│   ├── php/                       # PHP-FPM configuration
│   └── supervisor/                # Process management
├── k8s/
│   ├── namespace.yaml             # Kubernetes namespaces
│   └── secrets.yaml               # Secret templates
└── Dockerfile                     # Multi-stage Docker build
```

## 🔍 Pipeline Stages

### 1. 🔍 Pre-flight Checks
- Environment detection
- Strategy determination
- Branch-based configuration

### 2. 🏗️ Infrastructure Provisioning
- Terraform plan and apply
- Azure resources creation:
  - Resource Group
  - Virtual Network & Subnets
  - Azure Kubernetes Service
  - Azure Container Registry
  - MySQL Flexible Server
  - Key Vault for secrets

### 3. 🧪 Code Quality & Security
- PHP CodeSniffer (PSR-12)
- PHPStan static analysis
- Security vulnerability scanning
- Frontend linting
- Dependency security checks

### 4. 🧪 Automated Testing
- Unit tests
- Feature tests
- Integration tests
- Code coverage reporting

### 5. 🏗️ Build & Package
- Multi-stage Docker build
- Image security scanning
- Push to Azure Container Registry
- Container signing (production)

### 6. 🚀 Deployment
- AKS cluster configuration
- Kubernetes manifest generation
- Rolling deployment
- Health checks
- Database migrations

### 7. 📊 Post-Deployment Testing
- End-to-end tests
- Performance testing
- Smoke tests

## 🔧 Environment Configuration

### Development
- 1 AKS node (Standard_B2s)
- Basic MySQL (B_Gen5_1)
- 7-day backup retention

### Staging
- 2 AKS nodes (Standard_D2s_v3)
- General Purpose MySQL (GP_Gen5_2)
- 7-day backup retention

### Production
- 3 AKS nodes (Standard_D4s_v3)
- General Purpose MySQL (GP_Gen5_4)
- 35-day backup retention
- Zone-redundant high availability
- Container image signing

## 🔒 Security Features

- **Network Security**: NSG rules, private subnets
- **Secret Management**: Azure Key Vault integration
- **Container Security**: Trivy vulnerability scanning
- **Access Control**: RBAC for AKS and ACR
- **SSL/TLS**: Automatic certificate management
- **Database Security**: Private endpoints, encrypted connections

## 📊 Monitoring & Logging

- **Azure Monitor**: AKS cluster monitoring
- **Log Analytics**: Centralized logging
- **Application Insights**: Performance monitoring
- **Health Checks**: Kubernetes liveness/readiness probes

## 🛠️ Local Development

```bash
# Build Docker image locally
docker build -t laravel-app .

# Run with docker-compose
docker-compose up -d

# Access application
curl http://localhost:8080/health
```

## 🔄 Rollback Strategy

```bash
# Rollback deployment
kubectl rollout undo deployment/laravel-app-production -n production

# Check rollout status
kubectl rollout status deployment/laravel-app-production -n production
```

## 📞 Support

For issues and questions:
1. Check GitHub Actions logs
2. Review Azure Monitor logs
3. Verify Kubernetes pod status: `kubectl get pods -n <namespace>`
4. Check application logs: `kubectl logs -f deployment/laravel-app-<env> -n <namespace>`

## 🎯 Next Steps

1. **Custom Domain**: Configure ingress with custom domain
2. **SSL Certificates**: Set up cert-manager for automatic SSL
3. **Monitoring**: Enhance monitoring with Prometheus/Grafana
4. **Backup Strategy**: Implement automated database backups
5. **Disaster Recovery**: Set up multi-region deployment
