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
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dmz" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.cidr_block,2, 0), 6, count.index)}"

  tags = {
    "Name" = "DMZ - ${replace(data.aws_availability_zones.available.names[count.index], var.region, "")}"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.cidr_block,2, 1), 6, 6+count.index)}"

  tags = {
    "Name" = "Private - ${replace(data.aws_availability_zones.available.names[count.index], var.region, "")}"
  }
}

# Internet gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "IGW - ${var.network_name}"
  }
}

resource "aws_eip" "nat" {
  tags {
    Name = "nat_gateway"
  }
}

resource "aws_nat_gateway" "default" {
  subnet_id     = "${aws_subnet.dmz.0.id}"
  allocation_id = "${aws_eip.nat.id}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags {
    Name = "NGW - ${var.network_name}"
  }
}

# Routing tables
resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    "Name" = "DMZ"
  }
}

resource "aws_route_table_association" "dmz" {
  count          = "${length(aws_subnet.dmz.*.id)}"
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.default.id}"
  }

  tags = {
    "Name" = "Private"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(aws_subnet.private.*.id)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
