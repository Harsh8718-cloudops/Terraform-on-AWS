# Terraform Command Basics

## Step-01: Introduction
### Understand Basic Terraform Commands
- `terraform init` - Initialize a Terraform working directory
- `terraform validate` - Validate the Terraform configuration files
- `terraform plan` - Show execution plan before applying changes
- `terraform apply` - Apply the Terraform configuration
- `terraform destroy` - Destroy Terraform-managed infrastructure

## Step-02: Review Terraform Manifest for EC2 Instance
### Pre-Conditions
1. Ensure we have a **default VPC** in the selected AWS region
2. Ensure the **AMI ID** you are provisioning exists in that region, update if necessary
3. Verify your AWS Credentials in `$HOME/.aws/credentials`

### Terraform Configuration
#### Terraform Settings Block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}
```

#### Provider Block
```hcl
provider "aws" {
  profile = "default" # AWS Credentials Profile configured on our local desktop
  region  = "us-east-1"
}
```

#### Resource Block
```hcl
resource "aws_instance" "ec2demo" {
  ami           = "ami-04d29b6f966df1537" # Amazon Linux in us-east-1, update as per our region
  instance_type = "t2.micro"
}
```

## Step-03: Terraform Core Commands
### Initialize Terraform
```bash
terraform init
```

### Validate Terraform Configuration
```bash
terraform validate
```

### Plan Terraform Execution
```bash
terraform plan
```

### Apply Terraform Configuration
```bash
terraform apply
```

## Step-04: Verify EC2 Instance in AWS Management Console
1. Go to **AWS Management Console**
2. Navigate to **Services** → **EC2**
3. Verify the newly created EC2 instance

## Step-05: Destroy Infrastructure
### Destroy EC2 Instance
```bash
terraform destroy
```

### Clean-Up Terraform Files
```bash
rm -rf .terraform*
rm -rf terraform.tfstate*