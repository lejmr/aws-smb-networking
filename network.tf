# Main region
# Here we are installing our "stub" network and actuall aplication VPC
variable "main_region" {}

module "stub-network" {
  network_name = "Stub (hop) network"
  source       = "./modules/stub-network"
  region       = "${var.main_region}"
  cidr_block   = "10.1.0.0/16"
}

module "transit-network" {
  network_name = "Application network"
  source       = "./modules/transit-network"
  region       = "${var.main_region}"
  cidr_block   = "10.10.0.0/16"

  vpn_address = "${module.stub-network.gateway_ip}"
}

resource "local_file" "vpn-configuration" {
  content = <<EOT
# Tunnel 1
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} authentication pre-shared-secret '${module.transit-network.tunnel1_preshared_key}'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} description 'VPC tunnel 1'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} ike-group 'AWS'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} local-address '${module.stub-network.gateway_localip}'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} vti bind 'vti0'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel1_address} vti esp-group 'AWS'
set interfaces vti vti0 address '${module.transit-network.tunnel1_cgw_inside_address}/30'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel1_vgw_inside_address} remote-as '64512'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel1_vgw_inside_address} timers holdtime '30'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel1_vgw_inside_address} timers keepalive '10'


# Tunnel 2
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} authentication pre-shared-secret '${module.transit-network.tunnel2_preshared_key}'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} description 'VPC tunnel 2'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} ike-group 'AWS'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} local-address '${module.stub-network.gateway_localip}'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} vti bind 'vti1'
set vpn ipsec site-to-site peer ${module.transit-network.tunnel2_address} vti esp-group 'AWS'
set interfaces vti vti1 address '${module.transit-network.tunnel2_cgw_inside_address}/30'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel2_vgw_inside_address} remote-as '64512'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel2_vgw_inside_address} timers holdtime '30'
set protocols bgp 65000 neighbor ${module.transit-network.tunnel2_vgw_inside_address} timers keepalive '10'

# Save
commit
save

# Connection can be verified using following commands (in normal mode):
# show vpn ipsec status
EOT
  filename = "${path.module}/ipsec.vyos.conf"
}
