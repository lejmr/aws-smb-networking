# # VPC for transit
provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"

  tags = {
    "Name" = "${var.network_name}"
  }
}

# Subnets
data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet_primary" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr_block,8,0)}"

  tags = {
    "Name" = "DMZ"
  }
}

# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "IGW-${var.network_name}"
  }
}

data "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "igw_default_route" {
  route_table_id         = "${data.aws_route_table.main.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}
