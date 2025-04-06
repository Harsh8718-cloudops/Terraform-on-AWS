# 🚀 Terraform Project: Build AWS EC2 Instances and Security Groups with 3-Tier Architecture

This project provisions a complete 3-tier AWS architecture (Web, App, DB layers) using **Terraform modules**. It includes public and private subnets, EC2 instances, Security Groups, Elastic IP for Bastion Host, and Terraform provisioners like `file`, `remote-exec`, and `local-exec`.

---

## 📚 What You'll Learn

- Using popular **Terraform AWS modules** (VPC, EC2, SG)
- Creating and associating **Elastic IP**
- Working with **Terraform Provisioners**
- Handling **dependencies using `depends_on`**
- Using **null_resource** for custom provisioning

---

## 📦 Terraform Modules Used

- [`terraform-aws-modules/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- [`terraform-aws-modules/security-group/aws`](https://github.com/terraform-aws-modules/terraform-aws-security-group)
- [`terraform-aws-modules/ec2-instance/aws`](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance)

---

## 🧠 Key Terraform Concepts

- `aws_eip` – Elastic IP for Bastion Host
- `null_resource` – Triggers custom actions
- Provisioners:
  - `file`
  - `remote-exec`
  - `local-exec`
- `depends_on` – Handle resource creation order

---

## 🏗️ Architecture Overview

- **VPC** with 3-Tier Subnets (Web, App, DB)
- **Bastion Host** in Public Subnet
- **App EC2 Instances** in Private Subnets
- **Security Groups** for SSH & HTTP
- **Provisioners** for installation and logging

---

## 📁 Project Structure

```
.
├── app1-install.sh
├── private-key/
│   └── terraform-key.pem
├── local-exec-output-files/
├── terraform.tfvars
├── ec2instance.auto.tfvars
├── *.tf (All other Terraform files)
```

---

## 🚀 Steps to Implement

### ✅ Step 1: VPC Creation

- Reuse VPC module from previous section `06-02`
- Files:
  - `c1-versions.tf`
  - `c2-generic-variables.tf`
  - `c3-local-values.tf`
  - `c4-01/02/03-vpc-*.tf`

### ✅ Step 2: Add EC2 UserData Script

- Create `app1-install.sh` to install Apache and serve metadata.

### ✅ Step 3: Create Security Groups

- `public_bastion_sg` – SSH from Internet
- `private_sg` – HTTP + SSH from Internet (for demo)

### ✅ Step 4: Data Source for AMI

- Dynamically fetch latest **Amazon Linux 2 AMI**

### ✅ Step 5: Launch EC2 Instances

- Bastion Host in Public Subnet
- App Servers (3) in Private Subnets
- Use `user_data` to configure Apache

### ✅ Step 6: Elastic IP for Bastion Host

- Use `aws_eip` with `depends_on = [module.ec2_public]`

### ✅ Step 7: Null Resource & Provisioners

```hcl
resource "null_resource" "copy_key_and_log" {
  depends_on = [module.ec2_public]

  connection {
    type        = "ssh"
    host        = aws_eip.bastion_eip.public_ip
    user        = "ec2-user"
    private_key = file("private-key/terraform-key.pem")
  }

  provisioner "file" {
    source      = "private-key/terraform-key.pem"
    destination = "/tmp/terraform-key.pem"
  }

  provisioner "remote-exec" {
    inline = [ "sudo chmod 400 /tmp/terraform-key.pem" ]
  }

  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    working_dir = "local-exec-output-files/"
  }
}
```

### ✅ Step 8: Use `depends_on`

- Ensures proper provisioning order:
  - NAT Gateway before Private EC2s
  - Bastion EC2 before EIP
  - EC2 before `null_resource`

---

## 🔧 Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## 🔍 Testing Instructions

```bash
# SSH to Bastion Host
ssh -i private-key/terraform-key.pem ec2-user@<BASTION_PUBLIC_IP>

# Curl test to private EC2s
curl http://<PRIVATE_IP_1>
curl http://<PRIVATE_IP_2>

# SSH to Private EC2s from Bastion
ssh -i /tmp/terraform-key.pem ec2-user@<PRIVATE_IP>
```

### 🧪 Verify Metadata & App Page

```bash
cd /var/www/html/app1/
cat metadata.html
cat index.html
```

### 📄 Troubleshooting

```bash
cd /var/log
cat cloud-init-output.log
```

---

## 🧹 Clean-Up Resources

```bash
terraform destroy -auto-approve
rm -rf .terraform* terraform.tfstate*
```

---

