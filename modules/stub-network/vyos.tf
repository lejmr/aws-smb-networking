data "aws_ami" "vyos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["VyOS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # VyOS
}

data "template_file" "vpn-config" {
  template = "${file("${path.module}/cloud-init/pptp.conf.tmpl")}"

  vars {
    localip  = "${cidrhost(cidrsubnet(var.cidr_block,8,0), var.localip)}"
    username = "${var.username}"
    password = "${var.password}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part = {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = <<EOT
preserve_hostname: true
hostname: vpn-gateway-central
final_message: "The system is finally up"
EOT
  }

  part = {
    filename     = "pptp.cfg"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"

    content = <<EOT
write_files:
  - encoding: b64
    content: "${base64encode(data.template_file.vpn-config.rendered)}"
    permissions: '0655'
    path: /opt/vyatta/etc/config/scripts/vyos-postconfig-bootup.script

# This is just a workaround in order to get configuration into system without logging in
# and running the script from hand
runcmd:
  - reboot

cloud_final_modules:
  - write_files
EOT
  }
}

resource "aws_instance" "router" {
  ami                         = "${data.aws_ami.vyos.id}"
  instance_type               = "m3.medium"
  subnet_id                   = "${aws_subnet.subnet_dmz.id}"
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  private_ip                  = "${cidrhost(cidrsubnet(var.cidr_block,8,0), var.localip)}"
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  user_data_base64            = "${data.template_cloudinit_config.config.rendered}"

  tags = {
    Name = "vpn-gateway-central"
  }
}
