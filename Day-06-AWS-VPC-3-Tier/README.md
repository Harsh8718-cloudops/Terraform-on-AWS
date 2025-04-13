
# 🌐 3-Tier AWS VPC Design with NAT Gateways using Terraform

This repository demonstrates how to create a **3-Tier AWS VPC** using Terraform and AWS best practices. The setup includes public, private, and database subnets, NAT Gateways for outbound internet access from private subnets, and infrastructure modularization using the Terraform AWS VPC module.

---

## 📘 Project Objectives

- Understand and use **Terraform Modules**
- Define **input variables**, **local values**, and **output values**
- Create and organize VPC resources in AWS
- Use **`terraform.tfvars`** and **`.auto.tfvars`** for default inputs
- Standardize and generalize configurations for reuse
- Understand **version pinning** and NAT Gateway usage

---

## 🧱 Folder Structure

```bash
terraform-manifests/
├── v1-vpc-module/                 # Hardcoded VPC configuration
└── v2-vpc-module-standardized/   # Parameterized and reusable module setup
```

---

## 🚀 Step-by-Step Implementation

### Step-01: Introduction

- Understand Terraform Modules
- Use variables and local values
- Use `.tfvars` and `.auto.tfvars` for dynamic input
- Generate output values from the module

---

### Step-02: v1-vpc-module (Hardcoded Model)

#### Step-02-01: Evaluate Module Selection

- Visit [Terraform Registry](https://registry.terraform.io/)
- Use verified modules like [VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- Check download count, release history, input/output support

#### Step-02-02: Create VPC Module Terraform Config

Files:

- `c1-versions.tf`
- `c2-generic-variables.tf`
- `c3-vpc.tf`

Sample configuration using VPC module:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = "vpc-dev"
  cidr = "10.0.0.0/16"   
  azs  = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24"]

  create_database_subnet_group = true
  create_database_subnet_route_table = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  tags = {
    Owner = "kalyan"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-dev"
  }
}
```

---

### Step-03: Execute Terraform Commands

```bash
cd terraform-manifests/v1-vpc-module

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

✅ **Validate the following after apply**:
- VPC and subnets
- Internet Gateway (IGW)
- NAT Gateway & Elastic IP
- Route Tables
- Tagging

🧹 Cleanup:

```bash
terraform destroy -auto-approve
rm -rf .terraform* terraform.tfstate*
```

---

### Step-04: Version Constraints in Terraform

- Pin module version using `version = "x.y.z"`
- Use `~>` for minor version flexibility (e.g., `~> 2.78`)
- Recommended for stability and avoiding breaking changes

More info: [Terraform Version Constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)

---

### Step-05: v2-vpc-module-standardized – Modular Approach

🎯 Goal: Generalize configuration using input variables and locals

---

### Step-06: Define Generic Variables

File: `c2-generic-variables.tf`

```hcl
variable "aws_region" {
  default     = "us-east-1"
  description = "Region in which AWS Resources to be created"
}

variable "environment" {
  default     = "dev"
  description = "Environment tag"
}

variable "business_divsion" {
  default     = "HR"
  description = "Business Division"
}
```

---

### Step-07: Define Local Values

File: `c3-local-values.tf`

```hcl
locals {
  owners      = var.business_divsion
  environment = var.environment
  name        = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
```

---

### Step-08: Define VPC Input Variables

File: `c4-01-vpc-variables.tf`

Contains parameters like:

- VPC name and CIDR block
- Availability zones
- Subnet CIDRs
- NAT Gateway toggle
- Database subnet group toggle

Example:

```hcl
variable "vpc_name" {
  default     = "myvpc"
  description = "VPC Name"
}

variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}
```

---

### Step-09: Reference Module with Variables

File: `c4-02-vpc-module.tf`

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name              = "${local.name}-${var.vpc_name}"
  cidr              = var.vpc_cidr_block
  azs               = var.vpc_availability_zones
  public_subnets    = var.vpc_public_subnets
  private_subnets   = var.vpc_private_subnets
  database_subnets  = var.vpc_database_subnets

  create_database_subnet_group        = var.vpc_create_database_subnet_group
  create_database_subnet_route_table  = var.vpc_create_database_subnet_route_table

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags     = local.common_tags
  vpc_tags = local.common_tags

  public_subnet_tags = {
    Type = "Public Subnets"
  }

  private_subnet_tags = {
    Type = "Private Subnets"
  }

  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}
```

---

### Step-10: Terraform Variable Files

File: `terraform.tfvars`

```hcl
aws_region      = "us-east-1"
environment     = "dev"
business_divsion = "HR"
```

File: `vpc.auto.tfvars`

```hcl
vpc_name                        = "myvpc"
vpc_cidr_block                  = "10.0.0.0/16"
vpc_availability_zones         = ["us-east-1a", "us-east-1b"]
vpc_public_subnets             = ["10.0.101.0/24", "10.0.102.0/24"]
vpc_private_subnets            = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_database_subnets           = ["10.0.151.0/24", "10.0.152.0/24"]
vpc_create_database_subnet_group = true
vpc_create_database_subnet_route_table = true
vpc_enable_nat_gateway         = true
vpc_single_nat_gateway         = true
```

---

### Step-11: Run Terraform for Standardized Module

```bash
cd terraform-manifests/v2-vpc-module-standardized

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

Verify:

- Subnets (public, private, DB)
- NAT Gateway and routes
- Tags, AZs, and output IDs

---

### Step-12: Clean-Up Resources

```bash
terraform destroy -auto-approve
rm -rf .terraform* terraform.tfstate*
```

---

## 📚 References

- [Terraform AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Version Constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)

---
