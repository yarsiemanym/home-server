# Raspberry Pi

## Setup

1. Use [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager) to flash [Ubuntu Server 22.04 LTS (64-bit ARM)](https://ubuntu.com/download/server/arm) onto a microSD card.
   1. Enable SSH
      1. Allow public-key authentication only
         1. Paste in your localhost's public key
   2. Set username and password
   3. (Optional) Configure wireless LAN
   
2. Insert microSD card into the Raspberry Pi.

3. Create a `terrform.tfvars` file in `./terraform/stage0`.

```
host     = "{raspberry-pi-ip-address}"
user     = "{raspberry-pi-user}"
password = "{raspberry-pi-password}"
```

4. Create a `terrform.tfvars` file in `./terraform/stage1`.

```
pihole_admin_password    = "{pihole-admin-password}"
custom_dns_records       = [
  "{ip-address} {subdomain}"
]
```

5. Apply the Terraform.

```sh
cd ./terraform/stage0
terraform init
terraform apply
cd ../stage1
terraform init
terraform apply
```

6. Change the DNS server settings in your router to be the IP address of the Raspberry Pi.

7. Open a web browser and navigate to https://pihole.home/admin. You should see the Pi-Hole dashboard.

## Links

* [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager)
* [Ubuntu](https://ubuntu.com/)
  * [Ubuntu Server 22.04 (64-bit ARM)](https://ubuntu.com/download/server/arm)
  * [How to install Ubuntu Server on your Raspberry Pi](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi)
* [MicroK8s](https://microk8s.io/)
  * [Installing MicroK8s on a Raspberry Pi](https://microk8s.io/docs/install-raspberry-pi)
* [Pi-hole](https://pi-hole.net/)
  * [Docker Container Image](https://hub.docker.com/r/pihole/pihole)