resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "${var.vpn_address}"
  type       = "ipsec.1"

  tags = {
    Name = "VPN to stub-network"
  }
}

resource "aws_vpn_gateway" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_vpn_connection" "transit" {
  # vpn_gateway_id      = "${aws_vpn_gateway.main.id}"
  transit_gateway_id  = "${aws_ec2_transit_gateway.tgw.id}"
  customer_gateway_id = "${aws_customer_gateway.main.id}"
  type                = "${aws_customer_gateway.main.type}"
  static_routes_only  = false

  tags = {
    Name = "Connection to ${var.vpn_address}"
  }
}

# Enable BGP route exchange
resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = "${aws_vpn_gateway.main.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_vpn_gateway_route_propagation" "dmz" {
  vpn_gateway_id = "${aws_vpn_gateway.main.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}
