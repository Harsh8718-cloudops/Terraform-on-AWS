# Terraform Variables and Datasources

## Step-00: Pre-requisite Note
Create a **terraform-key** in AWS EC2 Key pairs, which will be referenced in our EC2 Instance.

## Step-01: Introduction
### Terraform Concepts:
- Terraform Input Variables
- Terraform Datasources
- Terraform Output Values

### What are we going to learn?
- Learn about Terraform Input Variable basics:
  - AWS Region
  - Instance Type
  - Key Name
- Define Security Groups and Associate them as a List item to AWS EC2 Instance:
  - `vpc-ssh`
  - `vpc-web`
- Learn about Terraform Output Values:
  - Public IP
  - Public DNS
- Get the latest EC2 AMI ID using the Terraform Datasources concept
- Use an existing EC2 Key pair **terraform-key**
- Use all the above to create an EC2 Instance in the default VPC

---
## Step-02: Define Input Variables in Terraform

### Terraform Input Variables (c2-variables.tf)
```hcl
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"  
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"  
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
  default     = "terraform-key"
}
```

### Reference the variables in respective `.tf` files:
```hcl
# c1-versions.tf
region  = var.aws_region

# c5-ec2instance.tf
instance_type = var.instance_type
key_name      = var.instance_keypair
```

---
## Step-03: Define Security Group Resources

### Security Group for SSH Traffic (c3-ec2securitygroups.tf)
```hcl
resource "aws_security_group" "vpc-ssh" {
  name        = "vpc-ssh"
  description = "Dev VPC SSH"
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Security Group for Web Traffic
```hcl
resource "aws_security_group" "vpc-web" {
  name        = "vpc-web"
  description = "Dev VPC web"
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Reference Security Groups in EC2 Instance:
```hcl
vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]  
```

---
## Step-04: Get Latest AMI ID for Amazon Linux 2

### Terraform Data Source (c4-ami-datasource.tf)
```hcl
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

### Reference Data Source in EC2 Instance:
```hcl
ami = data.aws_ami.amzlinux2.id
```

---
## Step-05: Define EC2 Instance Resource

### EC2 Instance (c5-ec2instance.tf)
```hcl
resource "aws_instance" "myec2vm" {
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  user_data              = file("${path.module}/app1-install.sh")
  key_name               = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  tags = {
    "Name" = "EC2 Demo 2"
  }
}
```

---
## Step-06: Define Output Values

### Terraform Output Values (c6-outputs.tf)
```hcl
output "instance_publicip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.myec2vm.public_ip
}

output "instance_publicdns" {
  description = "EC2 Instance Public DNS"
  value       = aws_instance.myec2vm.public_dns
}
```

---
## Step-07: Execute Terraform Commands
```bash
# Initialize Terraform
terraform init

# Validate Terraform Configuration
terraform validate

# Plan Terraform Execution
terraform plan

# Apply Terraform Configuration
terraform apply -auto-approve
```

---
## Step-08: Access Application
```bash
http://<PUBLIC-IP>/index.html
http://<PUBLIC-IP>/app1/index.html
http://<PUBLIC-IP>/app1/metadata.html
```

---
## Step-09: Clean-Up
```bash
# Destroy Resources
terraform destroy

# Clean-Up Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```

---
