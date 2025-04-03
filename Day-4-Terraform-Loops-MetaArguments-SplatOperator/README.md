# Terraform For Loops, Lists, Maps, and Count Meta-Argument

## Step-00: Pre-requisite Note
- Using the default VPC in `us-east-1` region.

## Step-01: Introduction
### Key Terraform Concepts Covered:
- Terraform **Meta-Argument**: `count`
- Terraform **Lists & Maps**
  - `list(string)`
  - `map(string)`
- Terraform **For Loops**
  - `for` loop with **List**
  - `for` loop with **Map**
  - `for` loop with **Map Advanced**
- **Splat Operators**
  - **Legacy Splat Operator (`.*.`)**
  - **Generalized Splat Operator (`[*]`)**
- Understanding **Terraform Generic Splat Expression** when dealing with the `count` meta-argument and multiple output values.

---

## Step-02: `c1-versions.tf`
_No changes required._

## Step-03: `c2-variables.tf` - Defining Lists and Maps
```hcl
# AWS EC2 Instance Type - List
variable "instance_type_list" {
  description = "EC2 Instance Type"
  type        = list(string)
  default     = ["t3.micro", "t3.small"]
}

# AWS EC2 Instance Type - Map
variable "instance_type_map" {
  description = "EC2 Instance Type"
  type        = map(string)
  default     = {
    "dev"  = "t3.micro"
    "qa"   = "t3.small"
    "prod" = "t3.large"
  }
}
```

## Step-04: `c3-ec2securitygroups.tf` & `c4-ami-datasource.tf`
_No changes required._

## Step-05: `c5-ec2instance.tf` - Using Lists, Maps, and Count
```hcl
# Referencing List values
instance_type = var.instance_type_list[1]

# Referencing Map values
instance_type = var.instance_type_map["prod"]

# Using Meta-Argument `count`
count = 2

# Using `count.index` for dynamic naming
  tags = {
    "Name" = "Count-Demo-${count.index}"
  }
```

## Step-06: `c6-outputs.tf` - Using For Loops and Splat Operators
```hcl
# Output - For Loop with List
output "for_output_list" {
  description = "For Loop with List"
  value       = [for instance in aws_instance.myec2vm: instance.public_dns]
}

# Output - For Loop with Map
output "for_output_map1" {
  description = "For Loop with Map"
  value       = {for instance in aws_instance.myec2vm: instance.id => instance.public_dns}
}

# Output - For Loop with Map Advanced
output "for_output_map2" {
  description = "For Loop with Map - Advanced"
  value       = {for c, instance in aws_instance.myec2vm: c => instance.public_dns}
}

# Output - Legacy Splat Operator (deprecated soon)
output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Expression"
  value       = aws_instance.myec2vm.*.public_dns
}

# Output - Latest Generalized Splat Operator
output "latest_splat_instance_publicdns" {
  description = "Generalized Splat Expression"
  value       = aws_instance.myec2vm[*].public_dns
}
```

---

## Step-07: Execute Terraform Commands
```sh
# Initialize Terraform
terraform init

# Validate Configuration
terraform validate

# Plan Terraform Deployment
terraform plan
```
**Observations:**
1. Experiment with **Lists and Maps** for `instance_type`.

```sh
# Apply Terraform Configuration
terraform apply -auto-approve
```
**Observations:**
1. **Two EC2 instances** will be created (`count = 2`).
2. `count.index` starts from `0` and ends at `1` (for dynamic VM naming).
3. Review outputs:
   - **For loops with List & Map**
   - **Splat Operators (Legacy & Latest)**

---

## Step-08: Terraform Comments
### Commenting Techniques in Terraform:
- **Single-line Comments**: `#` or `//`
- **Multi-line Comments**: `/* */`

### Example: Commenting Legacy Splat Operator
```hcl
/*
output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Expression"
  value       = aws_instance.myec2vm.*.public_dns
}
*/
```
_Reason: The **legacy splat operator (`.*.`)** might be deprecated in future Terraform versions._

---

## Step-09: Clean-Up Resources
```sh
# Destroy Terraform Resources
terraform destroy -auto-approve

# Clean-Up Terraform Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```

---



