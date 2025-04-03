# EC2 Instance
data "aws_vpc" "default" {
  default = true
}

# Fetch the default subnet (selects the first available one)
data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "myec2vm" {
  ami = data.aws_ami.amzlinux2.id
  # instance_type = var.instance_type_list[1]
  instance_type = var.instance_type_map["prod"]
  user_data = file("${path.module}/app1-install.sh")
  key_name = var.instance_keypair
  subnet_id     = data.aws_subnet.default.id 
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]

  # Meta-Argument Count
  count = 2

  # count.index
  tags = {
    "Name" = "Count-Demo-${count.index}"
  }
}