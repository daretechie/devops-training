
variable "vpc_id" {
  description = "The VPC ID to create the security group in."
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "The CIDR blocks to allow SSH access from."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_cidr_blocks" {
  description = "The CIDR blocks to allow ingress traffic from."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
