resource "null_resource" "linux_modules" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo apt install -y linux-modules-extra-raspi"
    ]
  }

  depends_on = [null_resource.aptitude]
}

resource "null_resource" "microk8s" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo snap install microk8s --classic",
      "microk8s start",
      "microk8s status --wait-ready",
      "microk8s config > ~/.kube/config"
    ]
  }

  depends_on = [null_resource.linux_modules]
}
