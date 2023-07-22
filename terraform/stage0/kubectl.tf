resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOC
      ssh ${var.user}@${var.host} microk8s config > ~/.kube/config
      kubectl config set-context microk8s
    EOC
  }

  depends_on = [null_resource.microk8s]
}
