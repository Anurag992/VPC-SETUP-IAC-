terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
}
resource "aws_vpc" "main2" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main2"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  ="vpc-0b852d5c7d587c9b3"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true
 tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  ="vpc-0b852d5c7d587c9b3"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
tags = {
    Name = "public_subnet_2"
  }
}

# Create private subnets in two availability zones
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  ="vpc-0b852d5c7d587c9b3"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-2a"
tags = {
    Name = "private_subnet_1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  ="vpc-0b852d5c7d587c9b3"
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-southeast-2b"
tags = {
    Name = "private_subnet_2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id ="vpc-0b852d5c7d587c9b3"
 tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public_route_table" {
vpc_id ="vpc-0b852d5c7d587c9b3"
 tags = {
    Name = "PublicRouteTable"
  }  
}
# Create a default route for the public subnets
resource "aws_route" "public_route" {
  route_table_id         ="rtb-0429e7e17e1f7fa18"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             ="igw-02fb9b3e44ccf4878"
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "public_rta_1" {
  subnet_id      ="subnet-08955e9f8c3a68ca9"
  route_table_id ="rtb-0429e7e17e1f7fa18"
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      ="subnet-093af5062f4d0a43c"
  route_table_id ="rtb-0429e7e17e1f7fa18"
}

# Create a security group for the EC2 instances
resource "aws_security_group" "sg" {
  name        = "my_security_group"
  description = "Allow HTTP and SSH"
  vpc_id      = "vpc-0b852d5c7d587c9b3"

  # Allow inbound HTTP (port 80) and SSH (port 22) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the launch configuration for EC2 instances
resource "aws_launch_template" "lc" {
  name = "my_launch_configuration"
  image_id = "ami-0146fc9ad419e2cfd"
  instance_type = "t2.micro"         
  
  network_interfaces {
         security_groups =["sg-0334824566be075b8"]
             associate_public_ip_address = false
}
}
# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id ="eipalloc-0168411bcd2bb3c62"
  subnet_id     ="subnet-08955e9f8c3a68ca9"  
}
resource "aws_route_table" "private_route_table" {
  vpc_id ="vpc-0b852d5c7d587c9b3"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id ="nat-0a5ad7890ffaec9a4"
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}
resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = "subnet-0c334c570dd81b21c"
  route_table_id ="rtb-0b272eb86e7b8f36a"
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      ="subnet-0d0fe6d7ccdd869ad"
  route_table_id ="rtb-0b272eb86e7b8f36a"
}
