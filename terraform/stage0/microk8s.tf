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
