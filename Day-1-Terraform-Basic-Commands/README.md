
🚀 **Day 1 of Learning Terraform** 🌍💡  

Today, I started my **Terraform journey** by exploring the basics of **Infrastructure as Code (IaC)** and deploying an **EC2 instance** on AWS! 🚀  

### **Terraform Command Basics**  
Understanding the core Terraform commands:  
✅ `terraform init` – Initialize Terraform  
✅ `terraform validate` – Validate configurations  
✅ `terraform plan` – Preview changes before applying  
✅ `terraform apply` – Deploy resources  
✅ `terraform destroy` – Tear down infrastructure  

### **Pre-Deployment Checks**  
Before launching an EC2 instance, I ensured:  
🔹 A **default VPC** exists in my selected AWS region  
🔹 The **AMI ID** is valid for the region  
🔹 My **AWS credentials** are configured properly  

### **Terraform Configuration for EC2**  
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2demo" {
  ami           = "ami-04d29b6f966df1537"
  instance_type = "t2.micro"
}
```

### **Terraform Workflow**  
🚀 **Step 1:** Initialize Terraform  
```bash
terraform init
```
🚀 **Step 2:** Validate the configuration  
```bash
terraform validate
```
🚀 **Step 3:** Preview changes  
```bash
terraform plan
```
🚀 **Step 4:** Apply and create the EC2 instance  
```bash
terraform apply
```
🚀 **Step 5:** Verify the instance in the AWS Console  
✅ Navigate to **EC2 Dashboard** and confirm the instance is running  

🚀 **Step 6:** Clean up resources  
```bash
terraform destroy
rm -rf .terraform* terraform.tfstate*
```

### **What’s Next?**  
This is just the beginning! Looking forward to exploring **Terraform modules, state management, and advanced configurations** in the coming days.  


