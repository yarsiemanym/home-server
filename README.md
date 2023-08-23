# Home Server

Terraform for setting up my home-lab Kubernetes cluster.

## Setup

1. Setup your workstation.
   1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads).
   2. Install [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl).

2. Install [Ubuntu Server 22.04 LTS](https://ubuntu.com/download/server) on the target server.
   1. Connect to WiFi or Ethernet.
   2. Enable OpenSSH.

3. Assign the target server a static IP address.

4. Copy your workstation's SSH key to the target server using `ssh-copy-id`.

5. Create a `terrform.tfvars` file in `./terraform/stage0`.

```
host     = "{ip-address}"
user     = "{user}"
password = "{password}"
```

5. Create a `terrform.tfvars` file in `./terraform/stage2`.

```
domain                    = "{your-domain}"
dhcp_server               = "{your-dhcp_ip-address}"
dhcp_cidr                 = "{your-dhcp-cidr-block}"
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
cd ../stage3
terraform init
terraform apply
```

7. Change the DNS server in your router's DHCP settings to be the IP address of the target server.

8. Get the ArgoCD initial admin password.

```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
kubectl delete secret argocd-initial-admin-secret -n argocd
```

9.  Check web apps running in Kubernetes.
   1. https://pihole.{your-domain}/admin
      1. Use the admin password specified in stage 2 variables.
   2. https://argocd.{your-domain}
      1. Use "admin" and the initial admin password from step 8.
      2. Naviate to https://argocd.{your-domain}/user-info?changePassword=true and change the admin password.
   3. https://grafana.{your-domain}
      1. Use "admin" as the username and "prom-operator" as the password.
      2. Navigate to https://grafana.{your-domain}/profile/password and change the admin password.

## Links

* [Ubuntu](https://ubuntu.com/)
  * [Ubuntu Server 22.04 LTS (amd64)](https://ubuntu.com/download/server)
* [MicroK8s](https://microk8s.io/)
* [Hostpath Storage](https://microk8s.io/docs/addon-hostpath-storage)
* [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
* [Reflector](https://github.com/emberstack/kubernetes-reflector)
* [cert-manager](https://cert-manager.io/)
  * [Let's Encrypt](https://letsencrypt.org/)
  * [ACME Cluster Issuer](https://cert-manager.io/docs/configuration/acme/)
  * [Route53 DNS Challenge Provider](https://cert-manager.io/docs/configuration/acme/dns01/route53/)
* [Prometheus](https://prometheus.io/)
* [Grafana](https://grafana.com/)
* [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
* [Pi-hole](https://pi-hole.net/)
  * [Docker Container Image](https://hub.docker.com/r/pihole/pihole)
* [Pi-Hole Prometheus Exporter](https://github.com/eko/pihole-exporter)
  * [Docker Container Image](https://hub.docker.com/r/ekofr/pihole-exporter)
  * [Grafana Dashboard](https://grafana.com/grafana/dashboards/14475-pi-hole-ui/)