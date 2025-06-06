# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
  profile = "admin"
}

# EC2インスタンス
resource "aws_instance" "iac-instance" {
  ami = "ami-027fff96cc515f7bc"
  instance_type = "t2.micro"

  tags = {
    Name = "iac-instance"
  }
}

# VPC
resource "aws_vpc" "iac-vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "iac-vpc"
  }
}

# VPC2
resource "aws_vpc" "iac-vpc2" {
  cidr_block = "10.1.0.0/16"

    tags = {
    Name = "iac-vpc2"
  }
}

# Subnet
resource "aws_subnet" "iac-subnet" {
  vpc_id     = aws_vpc.iac-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "iac-subnet"
  }
}

# 2
resource "aws_subnet" "iac-subnet2" {
  vpc_id     = aws_vpc.iac-vpc2.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "iac-subnet2"
  }
}

# ひな型
# resource "<provider>_<resource_type>" "name" {
#   key1 = "value1"
#   key2 = "value2"
# }

