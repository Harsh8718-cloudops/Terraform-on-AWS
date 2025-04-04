# EC2 Instance
# Get List of Availability Zones in the current region
data "aws_availability_zones" "my_azones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ec2_instance_type_offerings" "my_ins_type" {
  for_each = toset(data.aws_availability_zones.my_azones.names)
  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }
  filter {
    name   = "location"
    values = [each.key]
  }
  location_type = "availability-zone"
}


data "aws_vpc" "default" {
  default = true
}

# Fetch the default subnet (selects the first available one)
# Create one subnet in each Availability Zone
resource "aws_subnet" "my_subnets" {
  for_each = toset(data.aws_availability_zones.my_azones.names)

  vpc_id            = data.aws_vpc.default.id
 
  availability_zone = each.key
  cidr_block        = cidrsubnet("172.31.0.0/16", 8, index(data.aws_availability_zones.my_azones.names, each.key))

  tags = {
    Name = "Subnet-${each.key}"
  }
}


# EC2 Instance (Rewritten)
resource "aws_instance" "myec2vm" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  user_data     = file("${path.module}/app1-install.sh")
  key_name      = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  associate_public_ip_address = true

  # Use subnets only in supported AZs
  for_each = {
    for az, subnet in aws_subnet.my_subnets :
    az => subnet
    if length(data.aws_ec2_instance_type_offerings.my_ins_type[az].instance_types) != 0
  }

  subnet_id          = each.value.id
  availability_zone  = each.key

  tags = {
    Name = "For-Each-Demo-EC2${each.key}"
  }
}
