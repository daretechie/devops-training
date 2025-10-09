provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2_spec" {
  ami = "ami-052064a798f08f0d3"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-created-EC2-Instance"
  }
}

resource "aws_ami_from_instance" "my_ec2_spec_ami" {
  name = "my-ec2-ami"
  description = "My AMI created from my EC2 Instance with Terraform script"
  source_instance_id = aws_instance.my_ec2_spec.id
}