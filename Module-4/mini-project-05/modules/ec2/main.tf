variable "instance_type" {
  description = "The type of EC2 instance to launch."
  default     = "t2.micro"
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
}

variable "user_data" {
  description = "The user data script to run on instance launch."
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  user_data     = var.user_data

  tags = {
    Name = "My-Web-Server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
