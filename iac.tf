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

# Subnet
resource "aws_subnet" "iac-subnet" {
  vpc_id     = aws_vpc.iac-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "iac-subnet"
  }
}

# ひな型
# resource "<provider>_<resource_type>" "name" {
#   key1 = "value1"
#   key2 = "value2"
# }