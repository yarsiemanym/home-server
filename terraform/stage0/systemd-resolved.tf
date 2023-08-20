resource "null_resource" "systemd_resolved" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create

    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo systemctl stop systemd-resolved",
      "sudo systemctl disable systemd-resolved",
      "sudo sed -i 's/nameserver 127.0.0.53/nameserver 208.67.222.222\\nnameserver 208.67.220.220/g' /etc/resolv.conf"
    ]
  }
}
