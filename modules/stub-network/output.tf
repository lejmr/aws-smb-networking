output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "gateway_ip" {
  value = "${aws_instance.router.public_ip}"
}
