output "transit_vpc_id" {
  value = "${aws_ec2_transit_gateway.tgw.id}"
}
