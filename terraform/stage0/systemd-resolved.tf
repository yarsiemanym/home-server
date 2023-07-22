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
      "sudo sed -i 's/127.0.0.53/1.1.1.1/g' /etc/resolv.conf"
    ]
  }

  depends_on = [null_resource.boot_parameters]
}
