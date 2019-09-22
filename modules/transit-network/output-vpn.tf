output "tunnel1_address" {
  value = "${aws_vpn_connection.transit.tunnel1_address}"
}

output "tunnel2_address" {
  value = "${aws_vpn_connection.transit.tunnel2_address}"
}

output "tunnel1_cgw_inside_address" {
  value = "${aws_vpn_connection.transit.tunnel1_cgw_inside_address}"
}

output "tunnel1_vgw_inside_address" {
  value = "${aws_vpn_connection.transit.tunnel1_vgw_inside_address}"
}

output "tunnel2_cgw_inside_address" {
  value = "${aws_vpn_connection.transit.tunnel2_cgw_inside_address}"
}

output "tunnel2_vgw_inside_address" {
  value = "${aws_vpn_connection.transit.tunnel2_vgw_inside_address}"
}

output "tunnel1_preshared_key" {
  value = "${aws_vpn_connection.transit.tunnel1_preshared_key}"
}

output "tunnel2_preshared_key" {
  value = "${aws_vpn_connection.transit.tunnel2_preshared_key}"
}
