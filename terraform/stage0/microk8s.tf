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
      "sudo usermod -a -G microk8s pi",
      "newgrp microk8s",
      "microk8s start",
      "microk8s status --wait-ready",
      "mkdir ~/.kube",
      "microk8s config > ~/.kube/config"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "microk8s stop"
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
      "microk8s enable ingress"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "microk8s disable ingress"
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
      "microk8s enable hostpath-storage"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "microk8s disable hostpath-storage"
    ]
  }

  depends_on = [null_resource.microk8s]
}

resource "null_resource" "observability" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "microk8s enable observability"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "microk8s disable observability"
    ]
  }

  depends_on = [null_resource.microk8s]
}