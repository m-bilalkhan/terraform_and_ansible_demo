provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "allowed_ips" {
  description = "List of IPs allowed to access the server via SSH"
  type        = list(string)
}
variable "instance_type" {}
variable "ssh_key" {}
variable "ssh_key_private" {}

resource "aws_vpc" "demo-app-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "demo-app-subnet-1" {
  vpc_id            = aws_vpc.demo-app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "demp-app-igw" {
  vpc_id = aws_vpc.demo-app-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "demo-app-route-table" {
  vpc_id = aws_vpc.demo-app-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demp-app-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "demo-app-rt-a" {
  subnet_id      = aws_subnet.demo-app-subnet-1.id
  route_table_id = aws_route_table.demo-app-route-table.id
}

resource "aws_security_group" "demo-app-sg" {
  name   = "demo-app-sg"
  vpc_id = aws_vpc.demo-app-vpc.id

  //Rules
  ingress { //ingress for incoming request
    //It's a range of ports can be 0 to 1000 if we want
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.allowed_ips]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { //for exiting or outgoing request
    //here 0 0 means any port and -1 means any protocol
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = [] //For Acessing VPC and Server
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_instance" "myapp-server" {
  //required
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  //Optional
  subnet_id                   = aws_subnet.demo-app-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.demo-app-sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = var.ssh_key

  tags = {
    Name : "${var.env_prefix}-server"
  }
}

resource "null_resource" "configure_server" {
  triggers = {
    server_ip = aws_instance.myapp-server.public_ip
  }
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook --inventory ${aws_instance.myapp-server.public_ip}, --private-key ${var.ssh_key_private} playbook.yaml"
  }
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}