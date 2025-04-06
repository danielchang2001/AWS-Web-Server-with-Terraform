#############################################
# VPC, Subnets, IGW, Route Table, SG
#############################################

# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block = var.cidr
}

# Subnet 1 - first block of 256 ip addresses within the VPC CIDR
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Subnet 2 - next block of 256 ip addresses within the VPC CIDR
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id
}

# Create a new custom route table for the VPC.
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Subnet 1 with the custom route table
resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

# Associate Subnet 2 with the custom route table
resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group for VPC
resource "aws_security_group" "webSG" {
  name        = "webSG"
  vpc_id      = aws_vpc.myVPC.id
}

# Inbound rule for SG to allow HTTP in
resource "aws_vpc_security_group_ingress_rule" "allow_http_in" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Inbound rule for SG to allow SSH in
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Outbound rule for SG to allow all traffic out
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#############################################
# S3 bucket
#############################################

# Create S3 bucket
resource "aws_s3_bucket" "myS3" {
  bucket = "daniel-terraform-aws-2025"
}

# Disable block public access for S3 bucket
resource "aws_s3_bucket_public_access_block" "myS3_public_access" {
  bucket = aws_s3_bucket.myS3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Attach a bucket policy for the S3 bucket
resource "aws_s3_bucket_policy" "myS3_bucket_policy" {
  bucket = aws_s3_bucket.myS3.id
  policy = data.aws_iam_policy_document.myS3_bucket_policy_data.json

  depends_on = [aws_s3_bucket_public_access_block.myS3_public_access]
}

# Create the data for the bucket policy, allowing public read access
data "aws_iam_policy_document" "myS3_bucket_policy_data" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.myS3.arn,
      "${aws_s3_bucket.myS3.arn}/*",
    ]
  }
}

#############################################
# 2 EC2 instances within respective subnets
#############################################

resource "aws_instance" "webserver1" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSG.id]
  subnet_id = aws_subnet.subnet1.id
  user_data = base64encode(file("userdata1.sh"))
}

resource "aws_instance" "webserver2" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSG.id]
  subnet_id = aws_subnet.subnet2.id
  user_data = base64encode(file("userdata2.sh"))
}