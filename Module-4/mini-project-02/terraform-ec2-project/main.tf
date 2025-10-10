provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "tf_key" {
  key_name   = "tf_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "tf_sg" {
  name = "web-server_sg"
  description = "Allow SSH and HTTP inbound traffic"

  # Ingress rule for SSH Access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from any IP but not recommended for production
  }

  # Ingress rule for HTTP Access
  ingress {
    from_port = 80 
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow  Web server accessible from any IP
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic from any IP
  }
}

resource "aws_instance" "tf_ec2" {
  ami = "ami-052064a798f08f0d3"
  instance_type = "t2.micro"
  key_name = aws_key_pair.tf_key.key_name

  vpc_security_group_ids = [aws_security_group.tf_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
}

output "tf_ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value = aws_instance.tf_ec2.public_ip
}