provider "aws" {
  region = var.region
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.instance_name}-instance-profile"
  role = aws_iam_role.ec2.name
}

data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.instance_name}-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}


resource "aws_iam_role_policy_attachment" "managed-policy-attach" {
  for_each = {
    instance_core    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    cloudwatch_agent = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }
  role       = aws_iam_role.ec2.name
  policy_arn = each.value
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_instance" "ec2" {
  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  key_name             = var.pem_key_name
  subnet_id            = var.subnet_id

  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id
  ]
  tags = merge({
    Name = var.instance_name
    }, {}
  )
}

resource "local_file" "servers_ini" {
  filename = "inventory/servers.ini"
  content  = <<EOF
[web_servers]
ec2-instance ansible_host=${aws_instance.ec2.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/${var.pem_key_name}-use1.pem
EOF
}

resource "null_resource" "generate_binary" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=amd64 go build -o main main.go"
    working_dir = path.module
  }
}

### Output ###

output "ec2_public_dns" {
  value = aws_instance.ec2.public_dns
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2_pem_key" {
  value = var.pem_key_name
}


### Variables ###

variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID to launch the instance in."
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in."
}

variable "ami" {
  description = "The AMI to use for the instance."
}

variable "instance_type" {
  description = "The type of instance to create."
  default     = "t2.micro"
}

variable "pem_key_name" {
  description = " PEM Name file for SSH access."
}

variable "instance_name" {
  description = "Name tag for the instance."
  default     = "go-ansible-ec2"
}

variable "ssh_ips" {
  type        = list(string)
  description = "IPs address to allow SSH access from."
}

output "servers_ini_path" {
  value = local_file.servers_ini.filename
}