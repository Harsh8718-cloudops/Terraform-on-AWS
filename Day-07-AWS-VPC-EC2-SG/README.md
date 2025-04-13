
# 🚀 Terraform Project: Build 3-Tier AWS Architecture with EC2, Security Groups, and Provisioners

## 📌 Step-01: Introduction

### 🔧 Terraform Modules Used:
- [`terraform-aws-modules/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- [`terraform-aws-modules/security-group/aws`](https://github.com/terraform-aws-modules/terraform-aws-security-group)
- [`terraform-aws-modules/ec2-instance/aws`](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance)

### ✨ Terraform Concepts Introduced:
- `aws_eip`
- `null_resource`
- `file`, `remote-exec`, and `local-exec` provisioners
- `depends_on` meta-argument

---

## 🏗️ Step-02: 3-Tier VPC Setup

Copy the following files from your previous 3-tier VPC setup:

```bash
c1-versions.tf
c2-generic-variables.tf
c3-local-values.tf
c4-01-vpc-variables.tf
c4-02-vpc-module.tf
c4-03-vpc-outputs.tf
terraform.tfvars
vpc.auto.tfvars
private-key/terraform-key.pem
```

---

## 🧪 Step-03: Add App Install Script

Create `app1-install.sh`:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start
echo '<h1>Welcome to StackSimplify - APP-1</h1>' | sudo tee /var/www/html/index.html
sudo mkdir /var/www/html/app1
echo '<!DOCTYPE html><html><body style="background-color:rgb(250,210,210);"><h1>Welcome to Stack Simplify - APP-1</h1><p>Terraform Demo</p><p>Application Version: V1</p></body></html>' | sudo tee /var/www/html/app1/index.html
curl http://169.254.169.254/latest/dynamic/instance-identity/document -o /var/www/html/app1/metadata.html
```

---

## 🔐 Step-04: Create Security Groups

### ✅ Bastion Host SG (`c5-03-securitygroup-bastionsg.tf`)

```hcl
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name = "public-bastion-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  tags = local.common_tags
}
```

### ✅ Private SG (`c5-04-securitygroup-privatesg.tf`)

```hcl
module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name = "private-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = ["ssh-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  tags = local.common_tags
}
```

---

## 🧠 Step-05: Get Latest Amazon Linux 2 AMI

```hcl
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
}
```

---

## 💻 Step-06: EC2 Instances

### 🔸 Bastion Host

```hcl
module "ec2_public" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  name = "${var.environment}-BastionHost"
  ami = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name = var.instance_keypair
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  subnet_id = module.vpc.public_subnets[0]
  tags = local.common_tags
}
```

### 🔸 Private EC2s

```hcl
module "ec2_private" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  name = "${var.environment}-vm"
  ami = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name = var.instance_keypair
  vpc_security_group_ids = [module.private_sg.security_group_id]
  subnet_id = module.vpc.private_subnets[0]
  user_data = file("${path.module}/app1-install.sh")
  tags = local.common_tags
}
```

---

## 🌐 Step-07: Elastic IP for Bastion Host

```hcl
resource "aws_eip" "bastion_eip" {
  depends_on = [module.ec2_public]
  instance = module.ec2_public.id[0]
  vpc = true
  tags = local.common_tags
}
```

---

## 🧩 Step-08: null_resource with Provisioners

```hcl
resource "null_resource" "name" {
  depends_on = [module.ec2_public]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_eip.bastion_eip.public_ip
    private_key = file("private-key/terraform-key.pem")
  }

  provisioner "file" {
    source      = "private-key/terraform-key.pem"
    destination = "/tmp/terraform-key.pem"
  }

  provisioner "remote-exec" {
    inline = ["sudo chmod 400 /tmp/terraform-key.pem"]
  }

  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
  }

  provisioner "local-exec" {
    command     = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    working_dir = "local-exec-output-files/"
    when        = destroy
  }
}
```

---

## ⚙️ Step-09: Variables

### `ec2instance.auto.tfvars`

```hcl
instance_type = "t3.micro"
instance_keypair = "terraform-key"
```

---

## ✅ Step-10: depends_on Usage

### EC2 Private:

```hcl
depends_on = [module.vpc]
```

### Elastic IP:

```hcl
depends_on = [module.ec2_public, module.vpc]
```

### null_resource:

```hcl
depends_on = [module.ec2_public]
```

---

## 🚀 Step-11: Terraform Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## 🔍 Step-12: Connect & Verify

### Connect to Bastion:

```bash
ssh -i private-key/terraform-key.pem ec2-user@<PUBLIC_IP>
```

### Curl to Private EC2s:

```bash
curl http://<Private-IP>
```

### SSH to Private EC2s from Bastion:

```bash
ssh -i /tmp/terraform-key.pem ec2-user@<Private-IP>
```

### Troubleshooting:

```bash
cat /var/log/cloud-init-output.log
```

---

## 🧹 Step-13: Clean-Up

```bash
terraform destroy -auto-approve
rm -rf .terraform*
rm -rf terraform.tfstate*
```

---

