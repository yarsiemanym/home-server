# Raspberry Pi

Terraform for setting up my home-lab Kubernetes cluster on Raspberry Pi.

## Setup

1. Use [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager) to flash [Ubuntu Server 22.04 LTS (64-bit ARM)](https://ubuntu.com/download/server/arm) onto a microSD card.
   
   * Enable SSH
     * Allow public-key authentication only
       * Paste in your localhost's public key
   * Set username and password
   * (Optional) Configure wireless LAN
   
2. Insert the microSD card into the Raspberry Pi and power it on.

3. Assign your Raspberry Pi a static IP address.

4. Create a `terrform.tfvars` file in `./terraform/stage0`.

```
host     = "{raspberry-pi-ip-address}"
user     = "{raspberry-pi-user}"
password = "{raspberry-pi-password}"
```

5. Create a `terrform.tfvars` file in `./terraform/stage2`.

```
domain                    = "{your-domain}"
pihole_admin_password     = "{pihole-admin-password}"
pihole_timezone           = "{your-timezone}
pihole_custom_dns_records = [
  "{ip-address} {subdomain}"
]
```

6. Apply the Terraform.

```sh
cd ./terraform/stage0
terraform init
terraform apply
cd ../stage1
terraform init
terraform apply
cd ../stage2
terraform init
terraform apply
```

7. Change the DNS server in your router's DHCP settings to be the IP address of the Raspberry Pi.

8. Open a web browser and navigate to https://pihole.{your-domain}/admin. You should see the Pi-Hole dashboard.

## Links

* [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager)
* [Ubuntu](https://ubuntu.com/)
  * [Ubuntu Server 22.04 (64-bit ARM)](https://ubuntu.com/download/server/arm)
  * [How to Install Ubuntu Server on your Raspberry Pi](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi)
* [MicroK8s](https://microk8s.io/)
  * [Installing MicroK8s on a Raspberry Pi](https://microk8s.io/docs/install-raspberry-pi)
* [Hostpath Storage](https://microk8s.io/docs/addon-hostpath-storage)
* [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
* [Reflector](https://github.com/emberstack/kubernetes-reflector)
* [cert-manager](https://cert-manager.io/)
* [Prometheus](https://prometheus.io/)
* [Grafana](https://grafana.com/)
* [Pi-hole](https://pi-hole.net/)
  * [Docker Container Image](https://hub.docker.com/r/pihole/pihole)
* [Pi-Hole Prometheus Exporter](https://github.com/eko/pihole-exporter)
  * [Docker Container Image](https://hub.docker.com/r/ekofr/pihole-exporter)
  * [Grafana Dashboard](https://grafana.com/grafana/dashboards/14475-pi-hole-ui/)