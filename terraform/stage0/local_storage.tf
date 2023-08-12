resource "null_resource" "data" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "sudo mkdir /data"
    ]

    on_failure = continue
  }
}
