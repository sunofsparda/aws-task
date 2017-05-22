/* A multi
   line comment. */
/*
# EXAMPLES
# https://github.com/hashicorp/terraform/tree/master/examples
# https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier
*/

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = false
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "default"
  }
}

# Create a private subnet to launch our instances into
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${var.availability_zones["us-east-1"]}"  # FIXME: HARDCODE
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.availability_zones["us-east-1"]}"  # FIXME: HARDCODE
}

# NAT Gateway
resource "aws_nat_gateway" "default" {
  allocation_id = "${aws_eip.default.id}"
  subnet_id = "${aws_subnet.public.id}"
  depends_on = [
    "aws_internet_gateway.default",
    "aws_eip.default"]
}

# EIP
resource "aws_eip" "default" {
  vpc = true
}

# RouteTablePrivate
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.default.id}"
  }
}
# RouteTablePublic
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}
/* # FIXME: HARDCODE
//# RoutePrivate
//resource "aws_route" "private" {
//  route_table_id = "${aws_vpc.default.default_route_table_id}"
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id = "${aws_nat_gateway.default.id}"
//}
//# RoutePublic
//resource "aws_route" "public" {
//  route_table_id = "${aws_vpc.default.default_route_table_id}"
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id = "${aws_internet_gateway.default.id}"
//}
*/

# SubnetRouteTableAssociationPrivate
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
# SubnetRouteTableAssociationPublic
resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
# SecurityGroups

# SecurityGroupBackend
resource "aws_security_group" "backend" {
  name = "backend_http_ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}
# SecurityGroupBastion
resource "aws_security_group" "bastion" {
  name = "bastion_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.aws_security_group_cidr_blocks_epminscope}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags {
    Name = "bastion_ssh"
  }
}
# SecurityGroupELB
resource "aws_security_group" "elb" {
  name = "elbaccess_epam_minsk"
  description = "Allow http inbound traffic from epam-minsk"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${var.aws_security_group_cidr_blocks_epminscope}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}

# Ec2Instances
resource "aws_instance" "web" {
  depends_on = [
    "aws_route_table.private"]
  ami = "${var.aws_amis["us-east-1"]}"
  count = 2
  source_dest_check = true
  instance_type = "${var.aws_instance_types}"
  vpc_security_group_ids = [
    "${aws_security_group.backend.id}"]
  subnet_id = "${aws_subnet.private.id}"
  availability_zone = "${var.availability_zones["us-east-1"]}"  # FIXME: HARDCODE
  key_name = "${var.key_name}"
  user_data = "${file("provision.sh")}"

  connection {
    user = "root"
  }
}

resource "aws_instance" "bastion" {
  depends_on = [
    "aws_route_table.private"]
  ami = "${var.aws_amis["us-east-1"]}"
  count = 1
  source_dest_check = false
  instance_type = "${var.aws_instance_types}"
  vpc_security_group_ids = [
    "${aws_security_group.bastion.id}"]
  subnet_id = "${aws_subnet.public.id}"
  availability_zone = "${var.availability_zones["us-east-1"]}"  # FIXME: HARDCODE
  key_name = "${var.key_name}"

  connection {
    user = "root"
  }
}

# ElasticLoadBalancer
resource "aws_elb" "elb" {
  name = "stack-elb"
  //  availability_zones = "${var.availability_zones["us-east-1"]}"
  security_groups = [
    "${aws_security_group.elb.id}"]
  subnets = [
    "${aws_subnet.public.id}"]


  //  access_logs {
  //    bucket        = "foo"
  //    bucket_prefix = "bar"
  //    interval      = 60
  //  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "HTTP:80/"
    interval = 5
  }

  instances = [
    "${aws_instance.web.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 30
  connection_draining = true
  connection_draining_timeout = 30

  tags {
    Name = "stack-elb"
  }
}
