resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.network_name}"
}
