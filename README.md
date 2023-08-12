# Raspberry Pi

## Setup

1. Use Raspberry Pi Imager to flash Ubuntu Server onto a microSD card.
   1. Connect to WiFi
   2. Enable SSH
      1. Allow public-key authentication only
   
2. Insert microSD card into Raspberry Pi

3. Create a `terrform.tfvars` file in `./terraform/stage0`

```
host                    = "{raspberry-pi-ip-address}"
user                    = "{raspberry-pi-user}"
password                = "{raspberry-pi-password}"
```

4. Create a `terrform.tfvars` file in `./terraform/stage1`

```
pihole_password        = "{pihole-admin-password}"
domain                 = "{base-domain-name-for-ingress}"
additional_dns_records = [
  "{ip-address} {subdomain}"
]
```


5. Apply Terraform

```sh
cd ./terraform/stage0
terraform init
terraform apply
cd ../stage1
terraform init
terraform apply
```

7. Change your DNS server to be the IP address of the Raspberry Pi.

8. Open a web browser and navigate to https://pihole.{domain}/admin. You should see the Pi-Hole dashboard.

## Links

* [Ubuntu](https://ubuntu.com/)
  * [How to install Ubuntu Server on your Raspberry Pi](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi)
* [MicroK8s](https://microk8s.io/)
  * [Installing MicroK8s on a Raspberry Pi](https://microk8s.io/docs/install-raspberry-pi)
* [Pi-hole](https://pi-hole.net/)
  * [Docker Container Image](https://hub.docker.com/r/pihole/pihole)