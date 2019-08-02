data "local_file" "ssh_key" {
  filename = "files/id_rsa.pub"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key_app_${var.network_name}"
  public_key = "${data.local_file.ssh_key.content}"
}
