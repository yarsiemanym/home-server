resource "null_resource" "boot_parameters" {
  connection {
    host = var.host
    user = var.user
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "echo ${var.password} | sudo -p '' -S true",
      "if ! grep -q 'cgroup_enable=memory cgroup_memory=1' /boot/firmware/cmdline.txt; then sudo sed -i ' 1 s/$/ cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt; sudo reboot; fi"
    ]

    on_failure = continue
  }
}
