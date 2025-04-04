
# 🚀 Terraform Utility: EC2 Instance Deployment with Availability Zone Filtering  

## 📌 Introduction  
This Terraform project ensures EC2 instances are only launched in Availability Zones (AZs) where the specified instance type is supported.  

### ⚡ **Problem Statement**  
- AWS does not support all EC2 instance types in every Availability Zone.  
- Deploying an unsupported instance type in a specific AZ results in Terraform errors.  

### ✅ **Solution Approach**  
1. **Query AWS** to find the AZs where the instance type (e.g., `t3.micro`) is supported.  
2. **Filter out unsupported AZs** before launching EC2 instances.  
3. **Use Terraform meta-arguments** (`for_each`, `toset`, `tomap`) for dynamic deployment.  

---

## 🏗 **Project Structure**  

```
📂 terraform-az-instance-check
 ├── 📜 c1-versions.tf  
 ├── 📜 c2-get-instancetype-supported-per-az.tf  
 ├── 📜 c3-ec2-instance.tf  
 ├── 📜 variables.tf  
 ├── 📜 outputs.tf  
 ├── 📜 README.md  👈 (You are here!)
```

---

## 🔧 **Step-by-Step Guide**  

### 🛠 **Step 1: Define AWS Provider**  
Create a `c1-versions.tf` file to specify AWS provider and region.  

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### 🎛 **Step 2: Define Terraform Variables**  

Create a `variables.tf` file to make the instance type configurable.  

```hcl
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_keypair" {
  description = "The key pair name for SSH access"
  type        = string
  default     = "my-keypair"
}
```

---

### 📡 **Step 3: Fetch Supported AZs for an EC2 Instance Type**  

Create a `c2-get-instancetype-supported-per-az.tf` file to fetch the supported AZs for a given instance type.  

```hcl
# Fetch all availability zones in the region
data "aws_availability_zones" "az_list" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Check which AZs support the desired instance type
data "aws_ec2_instance_type_offerings" "instance_support" {
  for_each = toset(data.aws_availability_zones.az_list.names)

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  filter {
    name   = "location"
    values = [each.key]
  }

  location_type = "availability-zone"
}

# Output the AZs where the instance type is supported
output "supported_azs" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types if length(details.instance_types) != 0
  })
}
```

---

### 🖥 **Step 4: Deploy EC2 Instances in Supported AZs**  

Create a `c3-ec2-instance.tf` file to launch EC2 instances dynamically.  

```hcl
# Create EC2 instances only in supported AZs
resource "aws_instance" "myec2vm" {
  ami             = "ami-0c55b159cbfafe1f0"  # Replace with latest Amazon Linux 2 AMI
  instance_type   = var.instance_type
  key_name        = var.instance_keypair
  availability_zone = each.key

  for_each = toset(keys({
    for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types if length(details.instance_types) != 0
  }))

  tags = {
    Name = "EC2-${each.key}"
  }
}
```

---

### 📤 **Step 5: Define Terraform Outputs**  

Create an `outputs.tf` file to display Terraform results.  

```hcl
# Output all AZs mapped to supported instance types
output "output_v3_1" {
  value = { for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types }   
}

# Output only AZs where instance type is supported
output "output_v3_2" {
  value = { for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types if length(details.instance_types) != 0 }
}

# List of supported AZs
output "output_v3_3" {
  value = keys({ for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types if length(details.instance_types) != 0 }) 
}

# Get the first available AZ from the supported list
output "output_v3_4" {
  value = keys({ for az, details in data.aws_ec2_instance_type_offerings.instance_support :
    az => details.instance_types if length(details.instance_types) != 0 })[0]
}
```

---

### 🔄 **Step 6: Run Terraform Commands**  

```sh
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan execution
terraform plan

# Apply changes
terraform apply -auto-approve
```

---

### 🧹 **Step 7: Cleanup Resources**  

```sh
# Destroy EC2 instances and resources
terraform destroy -auto-approve

# Remove Terraform state files
rm -rf .terraform* 
rm -rf terraform.tfstate*
```

---

## 🛠 **Understanding Terraform Meta-Arguments**
| **Meta-Argument** | **Description** |
|-------------------|----------------|
| `for_each` | Loops through a list/map and creates resources dynamically. |
| `toset()` | Converts a list to a set (removes duplicates). |
| `tomap()` | Converts key-value pairs into a map for structured lookups. |
| `keys()` | Extracts keys from a map and returns them as a list. |
| `each.key` | Retrieves the current key when using `for_each`. |

---

## 🎯 **Key Benefits**
✅ **Automated**: No manual AZ selection needed.  
✅ **Dynamic**: Works with any instance type & region.  
✅ **Efficient**: Avoids Terraform errors due to unsupported AZs.  

---

## 📌 **Expected Terraform Outputs**
When running `terraform apply`, you will see outputs like:

```hcl
output_v3_1 = {
  "us-east-1a" = toset([
    "t3.micro",
  ])
  "us-east-1b" = toset([
    "t3.micro",
  ])
  "us-east-1c" = toset([
    "t3.micro",
  ])
  "us-east-1d" = toset([
    "t3.micro",
  ])
  "us-east-1e" = toset([])
  "us-east-1f" = toset([
    "t3.micro",
  ])
}

output_v3_2 = {
  "us-east-1a" = toset(["t3.micro"])
  "us-east-1b" = toset(["t3.micro"])
  "us-east-1c" = toset(["t3.micro"])
  "us-east-1d" = toset(["t3.micro"])
  "us-east-1f" = toset(["t3.micro"])
}

output_v3_3 = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d",
  "us-east-1f",
]

output_v3_4 = "us-east-1a"
`
