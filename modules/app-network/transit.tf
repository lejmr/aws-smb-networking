resource "aws_ec2_transit_gateway_vpc_attachment" "att-tgw" {
  subnet_ids         = ["${aws_subnet.private[0].id}"]
  transit_gateway_id = "${var.transit_vpc_id}"
  vpc_id             = "${aws_vpc.vpc.id}"

  tags = {
    "Name" = "${var.network_name}"
  }
}

# # Sumarized route
resource "aws_route" "tgw_route_private" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${var.transit_vpc_id}"
}

resource "aws_route" "tgw_route_dmz" {
  route_table_id         = "${aws_route_table.dmz.id}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${var.transit_vpc_id}"
}

resource "aws_route" "tgw_route_private_vpn" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "192.168.0.0/24"
  transit_gateway_id     = "${var.transit_vpc_id}"
}


resource "aws_route" "tgw_route_dmz_vpn" {
  route_table_id         = "${aws_route_table.dmz.id}"
  destination_cidr_block = "192.168.0.0/24"
  transit_gateway_id     = "${var.transit_vpc_id}"
}
