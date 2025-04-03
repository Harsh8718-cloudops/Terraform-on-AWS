# Terraform Settings, Providers & Resource Blocks

## Step-01: Introduction
- Terraform Settings
- Terraform Providers
- Terraform Resources
- Terraform File Function
- Create EC2 Instance using Terraform and provision a web server with userdata.

## Step-02: Create Terraform Settings Block (c1-versions.tf)
### Understand Terraform Settings Block
```hcl
terraform {
  required_version = "~> 0.14" # Supports versions >= 0.14 and < 1.xx
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

## Step-03: Create Terraform Providers Block (c1-versions.tf)
### Understand Terraform Providers
- Configure AWS Credentials in AWS CLI (if not already configured)

#### Verify AWS Credentials
```bash
cat $HOME/.aws/credentials
```

#### Create AWS Providers Block
```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
```

## Step-04: Create Resource Block (c2-ec2instance.tf)
### Understand Resources
- Create EC2 Instance Resource
- Understand File Function
- Understand Resources - Argument & Attribute Reference

#### EC2 Instance Resource Block
```hcl
resource "aws_instance" "myec2vm" {
  ami = "ami-0533f2ba8a1995cf9"
  instance_type = "t3.micro"
  user_data = file("${path.module}/app1-install.sh")
  tags = {
    "Name" = "EC2 Demo"
  }
}
```

## Step-05: Review User Data Script (app1-install.sh)
```bash
#! /bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start  

sudo echo '<h1>Welcome to StackSimplify - APP-1</h1>' | sudo tee /var/www/html/index.html
sudo mkdir /var/www/html/app1
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - APP-1</h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
sudo curl http://169.254.169.254/latest/dynamic/instance-identity/document -o /var/www/html/app1/metadata.html
```

## Step-06: Execute Terraform Commands
### Initialize Terraform
```bash
terraform init
```
**Observations:**
1. Initialized Local Backend
2. Downloaded provider plugins
3. Created `.terraform` folder

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
# or
terraform apply -auto-approve
```

**Observations:**
1. Resources are created on AWS
2. `terraform.tfstate` file is generated

## Step-07: Access Application
### Verify if Default VPC Security Group allows Port 80
#### Access Web Pages
```bash
http://<PUBLIC-IP>/index.html
http://<PUBLIC-IP>/app1/index.html
```

#### Access Metadata
```bash
http://<PUBLIC-IP>/app1/metadata.html
```

## Step-08: Understand Terraform State
- Terraform State file: `terraform.tfstate`
- Understand Desired State vs. Current State

## Step-09: Clean-Up Resources
### Destroy Infrastructure
```bash
terraform plan -destroy  # View destroy plan
terraform destroy
```

### Clean-Up Terraform Files
```bash
rm -rf .terraform*
rm -rf terraform.tfstate*
