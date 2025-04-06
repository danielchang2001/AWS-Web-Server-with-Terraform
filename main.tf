#############################################
# VPC, Subnets, IGW, Route Table, SGs
#############################################

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# Subnet 1 - first block of 256 ip addresses within the VPC CIDR
resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Subnet 2 - next block of 256 ip addresses within the VPC CIDR
resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Create a new custom route table for the VPC.
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Subnet 1 with the custom route table
resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

# Associate Subnet 2 with the custom route table
resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group for VPC
resource "aws_security_group" "mysg" {
  name        = "websg"
  vpc_id      = aws_vpc.myvpc.id
}

# Inbound rule for SG to allow HTTP in
resource "aws_vpc_security_group_ingress_rule" "allow_http_in" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Inbound rule for SG to allow SSH in
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Outbound rule for SG to allow all traffic out
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#############################################
# S3 and EC2 instances
#############################################

resource "aws_s3_bucket" "example" {
  bucket = "daniel-terraform-aws-2025"
}