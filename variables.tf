# EXAMPLE

//variable "aws_access_key" {}
//variable "aws_secret_key" {}
//variable "aws_key_path" {}
//variable "aws_key_name" {}
//
//variable "aws_region" {
//  default = "us-west-2"
//}
//
//variable "network" {
//  default = "10.10"
//}
//
//variable "offset" {
//  default = ""
//}
//
//variable "aws_vpc_id" {}
//variable "aws_internet_gateway_id" {}
//variable "aws_route_table_public_id" {}
//variable "aws_route_table_private_id" {}
//variable "aws_subnet_cfruntime-2a_availability_zone" {
//  default = "us-west-2a"
//}
//variable "aws_subnet_cfruntime-2b_availability_zone" {
//  default = "us-west-2a"
//}
//
//variable "aws_ubuntu_ami" {
//  type = "map"
//  default = {
//    us-east-1 = "ami-98aa1cf0"
//    us-west-1 = "ami-736e6536"
//    us-west-2 = "ami-37501207"
//    ap-northeast-1 = "ami-df4b60de"
//    ap-southeast-1 = "ami-2ce7c07e"
//    ap-southeast-2 = "ami-1f117325"
//    eu-west-1 = "ami-f6b11181"
//    sa-east-1 = "ami-71d2676c"
//  }
//}
//
//variable "aws_centos_ami" {
//  type = "map"
//  default = {
//    us-east-1 = "ami-00a11e68"
//    us-west-1 = "ami-e04b7aa5"
//    us-west-2 = "ami-3425be04"
//    ap-northeast-1 = "ami-9392dc92"
//    ap-southeast-1 = "ami-dcbeed8e"
//    ap-southeast-2 = "ami-89e88db3"
//    eu-west-1 = "ami-af6faad8"
//    sa-east-1 = "ami-73ee416e"
//  }
//}

variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "AWS key"
  default = "aws_acherlyonok"
}

variable "key_path" {
  description = "Key path for SSHing into EC2"
  default = "~/ssh/aws_acherlyonok.pem"
}

# Amazon Linux AMI 2017.03.0
variable "aws_amis" {
  type = "map"
  default = {
    us-east-1 = "ami-c58c1dd3"
  }
}

variable "aws_instance_types" {
  default = "t2.micro"
}

variable "aws_security_group_cidr_blocks_epminscope" {
  type = "list"
  default = [
    "213.184.243.0/24",
    "217.21.56.0/24",
    "217.21.63.0/24",
    "213.184.231.0/24",
    "86.57.255.88/29"]
}

variable "availability_zones" {
  description = "ELB availability zones"
  type = "map"
  default = {
    us-east-1 = "us-east-1a"
//    us-east-1 = ["us-east-1a","us-east-1a","us-east-1b","us-east-1c","us-east-1d"]
  }
}