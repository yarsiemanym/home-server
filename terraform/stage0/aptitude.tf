resource "null_resource" "upgrade_packages" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt autoremove -y"
    ]
  }

  depends_on = [null_resource.systemd_resolved]
}