# EXAMPLES
# https://github.com/hashicorp/terraform/tree/master/examples
# https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}


# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "default"
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

# Grant the VPC internet access on its default route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

# resource "aws_route" "nat_access" {
#   route_table_id         = "${aws_vpc.default.default_route_table_id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = "${aws_internet_gateway.default.id}"
# }


resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_nat_gateway" "default" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"
  depends_on = [
    "aws_internet_gateway.default"]
}

resource "aws_eip" "default" {
  vpc = true
}

variable "instance_id" {}
variable "public_ip" {}

data "aws_eip" "proxy_ip" {
  public_ip = "${var.public_ip}"
}

resource "aws_eip_association" "proxy_eip" {
  instance_id = "${var.instance_id}"
  allocation_id = "${data.aws_eip.proxy_ip.id}"
}