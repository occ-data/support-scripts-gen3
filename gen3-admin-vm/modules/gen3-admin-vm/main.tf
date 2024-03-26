## AWS VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

## AWS Subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet"
  }
}

## AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

## AWS Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.prefix}-rt"
  }
}

## AWS Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}


## Data Source Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

## Data Source Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## AWS Security Group
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = var.ssh_allowed_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value] # ingress.value refers to each IP address in the list
    }
  }
  tags = {
    Name = "${var.prefix}-sg"
  }
}

## Generate ssh keypair

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "example" {
  key_name   = var.prefix
  public_key = tls_private_key.example.public_key_openssh
}

## output keys to file
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.root}/outputs/${var.prefix}.pem"
}

resource "local_file" "public_key" {
  content  = tls_private_key.example.public_key_openssh
  filename = "${path.root}/outputs/${var.prefix}.pub"
}

## EIP

resource "aws_eip" "main" {
  tags = {
    Name = "${var.prefix}-eip"
  }
}

## AWS EC2 Instance
resource "aws_instance" "main" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = var.prefix
  iam_instance_profile   = aws_iam_instance_profile.admin_vm_instance_profile.name

  tags = {
    Name = "${var.prefix}"
  }
 
  root_block_device {
    volume_size = 30
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.example.private_key_pem
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "${path.module}/scripts/provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "bash /tmp/provision.sh"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-awscli.sh"
    destination = "/tmp/install-awscli.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-awscli.sh",
      "bash /tmp/install-awscli.sh"
    ]
  }

}

## Attach EIP to EC2
resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main.id
}

## Create admin vm role and associate with instance
resource "aws_iam_role" "admin_vm_role" {
  name = "${var.prefix}-admin-vm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

## aws administator policy
resource "aws_iam_policy" "admin_vm_policy" {
  name        = "${var.prefix}-admin-vm-policy"
  description = "Policy for admin VM"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "*",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

## Attach policy to role
resource "aws_iam_role_policy_attachment" "admin_vm_policy_attachment" {
  policy_arn = aws_iam_policy.admin_vm_policy.arn
  role       = aws_iam_role.admin_vm_role.name
}

## Attach role to instance
resource "aws_iam_instance_profile" "admin_vm_instance_profile" {
  name = "${var.prefix}-admin-vm-instance-profile"
  role = aws_iam_role.admin_vm_role.name
}



## Output VPC ID, VPC CIDR, Subnet ID, Subnet Cidr, Intenral IP, Public IP, Security Group ID to file
resource "local_file" "output" {
  content  = <<EOF
VPC ID: ${aws_vpc.main.id}
VPC CIDR: ${aws_vpc.main.cidr_block}
Subnet ID: ${aws_subnet.main.id}
Subnet CIDR: ${aws_subnet.main.cidr_block}
VM Internal IP: ${aws_instance.main.private_ip}
VM Public IP: ${aws_eip.main.public_ip}
VM Security Group ID: ${aws_security_group.main.id}
EOF
  filename = "${path.root}/outputs/${var.prefix}-info.txt"
}
