resource "null_resource" "microk8s" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo snap install kubectl --classic",
      "sudo snap install microk8s --classic",
      "sudo microk8s start",
      "sudo microk8s status --wait-ready",
      "mkdir ~/.kube",
      "sudo microk8s config > ~/.kube/config"
    ]
  }

  depends_on = [null_resource.upgrade_packages]
}

resource "null_resource" "nginx" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo microk8s enable ingress"
    ]
  }

  depends_on = [null_resource.microk8s]
}

resource "null_resource" "host_storage" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo microk8s enable hostpath-storage"
    ]
  }

  depends_on = [null_resource.microk8s]
}