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

6. Create a `terrform.tfvars` file in `./terraform/stage2`.

```
domain                    = "{your-domain}"
dhcp_server               = "{your-dhcp_ip-address}"
dhcp_cidr                 = "{your-dhcp-cidr-block}"
pihole_admin_password     = "{pihole-admin-password}"
pihole_timezone           = "{your-timezone}
pihole_custom_dns_records = [
  "{ip-address} {subdomain}"
]
aws_region                = "{your-aws-region}"
aws_access_key_id         = "{your-aws-access-key-id}"
aws_secret_access_key     = "{your-aws-secret-key"
operator_email_address    = "{your-email-address}"
grafana_admin_password    = "{grafana-admin-password}"
```

7. Apply the Terraform.

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

8. Change the DNS server in your router's DHCP settings to be the IP address of the target server.

9. Get the ArgoCD initial admin password.

```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
kubectl delete secret argocd-initial-admin-secret -n argocd
```

10.  Check web apps running in Kubernetes.
   1. https://pihole.{your-domain}/admin
      1. Use the admin password specified in the stage 2 variables.
   2. https://argocd.{your-domain}
      1. Use "admin" and the initial admin password from step 8.
      2. Naviate to https://argocd.{your-domain}/user-info?changePassword=true and change the admin password.
   3. https://grafana.{your-domain}
      1. Use "admin" as the username and the grafana admin password you specified in the stage 2 variables.

## Links

* [Ubuntu](https://ubuntu.com/)
  * [Ubuntu Server 22.04 LTS (amd64)](https://ubuntu.com/download/server)
* [MicroK8s](https://microk8s.io/)
  * [Hostpath Storage](https://microk8s.io/docs/addon-hostpath-storage)
* [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
  * [Helm Chart](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/#installing-the-chart)
* [Reflector](https://github.com/emberstack/kubernetes-reflector)
  * [Helm Chart](https://artifacthub.io/packages/helm/emberstack/reflector)
* [cert-manager](https://cert-manager.io/)
  * [Helm Chart](https://artifacthub.io/packages/helm/cert-manager/cert-manager)
  * [Let's Encrypt](https://letsencrypt.org/)
  * [ACME Cluster Issuer](https://cert-manager.io/docs/configuration/acme/)
  * [Route53 DNS Challenge Provider](https://cert-manager.io/docs/configuration/acme/dns01/route53/)
* [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)
  * [Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
* [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
  * [Helm Chart](https://artifacthub.io/packages/helm/argo/argo-cd)
* [Pi-hole](https://pi-hole.net/)
  * [Docker Container Image](https://hub.docker.com/r/pihole/pihole)
* [External DNS](https://github.com/kubernetes-sigs/external-dns)
  * [External DNS for Pi-Hole](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/pihole.md)
* [Pi-Hole Prometheus Exporter](https://github.com/eko/pihole-exporter)
  * [Docker Container Image](https://hub.docker.com/r/ekofr/pihole-exporter)
  * [Grafana Dashboard](https://grafana.com/grafana/dashboards/14475-pi-hole-ui/)
