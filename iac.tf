# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
  profile = "admin"
}

#1 VPC作成
resource "aws_vpc" "iac-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "iac-vpc"
  }
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
  # default = "10.0.1.0/24"
  # type = string
}

#2 インターネットゲートウェイ作成
resource "aws_internet_gateway" "iac-gateway" {
  vpc_id = aws_vpc.iac-vpc.id
  tags = {
    Name = "iac-gateway"
  }
}

#3 ルートテーブル作成
resource "aws_route_table" "iac-route-table" {
  vpc_id = aws_vpc.iac-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iac-gateway.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.iac-gateway.id
  }
  tags = {
    Name = "iac-route-table"
  }
}

#4 サブネット作成
resource "aws_subnet" "iac-subnet" {
  vpc_id     = aws_vpc.iac-vpc.id
  cidr_block = var.subnet_prefix[0].cidr_block
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = var.subnet_prefix[0].name
  }
}

#4-2 サブネット作成
resource "aws_subnet" "iac-subnet2" {
  vpc_id     = aws_vpc.iac-vpc.id
  cidr_block = var.subnet_prefix[1].cidr_block
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = var.subnet_prefix[1].name
  }
}

#5 サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "iac-association" {
  subnet_id      = aws_subnet.iac-subnet.id
  route_table_id = aws_route_table.iac-route-table.id
}

#6 セキュリティグループ作成（ポート22,80,443許可）
resource "aws_security_group" "iac-security-group" {
  name        = "iac-security-group"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.iac-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "iac-security-group"
  }
}

#7 ENI（Elastic Network Interface）作成（サブネット、セキュリティグループ等を１つにまとめる）
resource "aws_network_interface" "iac-nw-interface" {
  subnet_id       = aws_subnet.iac-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.iac-security-group.id]
}

#8 EIP（Elastic IP）作成、ENIに紐付け
resource "aws_eip" "iac-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.iac-nw-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.iac-gateway, aws_instance.iac-instance]
}

output "eip_public_ip" {
  value = aws_eip.iac-eip.public_ip
}

#9 Webサーバー構築（Linuxサーバー構築、Apacheインストール、index.html作成）
resource "aws_instance" "iac-instance" {
  ami = "ami-027fff96cc515f7bc"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-1a"
  key_name = "iac-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.iac-nw-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install httpd
              sudo systemctl start httpd.service
              sudo bash -c 'echo AWSで学ぶ！Infrastructure as Code入門講座へようこそ！ > /var/www/html/index.html'
              EOF
  tags = {
    Name = "iac-instance"
  }
}

output "instance_id" {
  value = aws_instance.iac-instance.private_ip
}

output "instance_private_ip" {
  value = aws_instance.iac-instance.id
}

# # EC2インスタンス
# resource "aws_instance" "iac-instance" {
#   ami = "ami-027fff96cc515f7bc"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "iac-instance"
#   }
# }

# # VPC
# resource "aws_vpc" "iac-vpc" {
#   cidr_block = "10.0.0.0/16"

#     tags = {
#     Name = "iac-vpc"
#   }
# }

# # VPC2
# resource "aws_vpc" "iac-vpc2" {
#   cidr_block = "10.1.0.0/16"

#     tags = {
#     Name = "iac-vpc2"
#   }
# }

# # Subnet
# resource "aws_subnet" "iac-subnet" {
#   vpc_id     = aws_vpc.iac-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "iac-subnet"
#   }
# }

# # 2
# resource "aws_subnet" "iac-subnet2" {
#   vpc_id     = aws_vpc.iac-vpc2.id
#   cidr_block = "10.1.1.0/24"

#   tags = {
#     Name = "iac-subnet2"
#   }
# }

# ひな型
# resource "<provider>_<resource_type>" "name" {
#   key1 = "value1"
#   key2 = "value2"
# }

