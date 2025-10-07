# Terraform Azure IaC Demo
This is minimal but production-style Infrastructure as a Code project using Terraform to provision resources on Microsoft Azure.
The repository is structured to support modular design, remote state management, and scalable infastructure provisioning.

## Components
- Azure Virtual Network (VNet) with subnet
- Azure Storage Account
- Remote state backend (Azure Blob Storage in container "tfstate")

## Usage
bash

### 1. Bootstrap remote backend (only once)
cd bootstrap
terraform init
terraform apply

### 2. Deploy main infrastructure
cd ..
terraform init
terraform apply

### 3. Destroy infrastructure
terraform destroy


* Requirements
- Terraform >= 1.3.0
- Azure CLI authenticated (az login)
- Valid Azure subscription

* Notes !!!
- Storage Account and container for remote state are created via the "bootstrap" step
- All modules are reusable and follow best practices for modular Terraform design
