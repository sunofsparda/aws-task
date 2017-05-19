provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "Ec2Instance00" {
  ami           = "ami-c58c1dd3"
  instance_type = "t2.micro"
}