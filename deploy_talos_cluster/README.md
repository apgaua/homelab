# Deploy Talos linux on PROXMOX

## Steps
### Creating VM
This structure first will create the number of Virtual Machines that you specified on nodes variable. Each machine with a defined MAC Adress, so you can create the IP reservation on the DHCP Server of your network.

### Configuring Cluster
After VM creation and booting it with Talos ISO, the deployment of Talos Kubernetes Cluster will start.
It will create nodes based on the type you specified in nodes variable (3 control planes and 5 workers in the example).
After configuration, it will bootstrap etcd and reboot machines. They will start with a new hostname, and deployed cluster.

### Helm Charts (Optional)
You can use helm_chats variable to deploy how many deploys you could want.
This proccess wait for cluster deployment and full access before starts.

## Commands

| Terraform | Description |
|--------------------|-------------|
| terraform fmt --recursive | Format terraform files |
| terraform init -backend-config=environment/*backendfile*.tfvars | Init terraform backend config|
| terraform validate | Validate terraform workflow |
| terraform apply -auto-approve -var-file=environment/*variablefile*.tfvars | Create structure |
| terraform destroy -auto-approve -var-file=environment/*variablefile*.tfvars | Destroy structure |

## Proxmox user privileges
To properly run bgp/proxmox provider, the permissions bellow are needed:

Sys.Console, VM.Allocate, Datastore.AllocateTemplate, VM.Config.HWType, VM.Config.Memory, Mapping.Use, VM.Config.Network, VM.Config.CDROM, VM.GuestAgent.Unrestricted, VM.Clone, Sys.Audit, VM.Config.CPU, Sys.Modify, VM.PowerMgmt, SDN.Use, VM.Migrate, Pool.Audit, Datastore.Allocate, VM.Config.Options, Datastore.Audit, VM.Config.Cloudinit, Pool.Allocate, Datastore.AllocateSpace, VM.GuestAgent.Audit, VM.Config.Disk, VM.Audit

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd"></a> [argocd](#input\_argocd) | ArgoCD configuration | <pre>object({<br/>    password        = string<br/>    repo_url        = string<br/>    repo_user       = string<br/>    repo_pass       = string<br/>    chart_version   = string<br/>    monitoring_path = optional(string)<br/>    monorepo        = optional(bool)<br/>    ha              = optional(bool, false)<br/>    replicas        = optional(number)<br/>  })</pre> | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster wide configuration | <pre>object({<br/>    name             = string<br/>    description      = string<br/>    cidr             = string<br/>    resource_pool    = optional(string)<br/>    talos_endpoint   = string<br/>    vmid_prefix      = number<br/>    kubeconfig       = string<br/>    cpu_type         = string<br/>    internet_gateway = string<br/>  })</pre> | n/a | yes |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | Hardware configuration for controlplane nodes | <pre>object({<br/>    count               = number<br/>    sockets             = number<br/>    cores               = number<br/>    memory              = number<br/>    balloon             = optional(number)<br/>    disk_size           = number<br/>    network_last_octect = number<br/>  })</pre> | n/a | yes |
| <a name="input_iso"></a> [iso](#input\_iso) | ISO image configuration | <pre>object({<br/>    url                   = string<br/>    file_name             = string<br/>    talos_installer_image = string<br/>  })</pre> | n/a | yes |
| <a name="input_mac_address"></a> [mac\_address](#input\_mac\_address) | Base MAC address for generating unique MACs for controlplane nodes | `list(string)` | n/a | yes |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox backend address | <pre>object({<br/>    ip   = string<br/>    port = number<br/>  })</pre> | n/a | yes |
| <a name="input_worker"></a> [worker](#input\_worker) | Hardware configuration for worker nodes | <pre>object({<br/>    count               = number<br/>    sockets             = number<br/>    cores               = number<br/>    memory              = number<br/>    balloon             = optional(number)<br/>    disk_size           = number<br/>    network_last_octect = number<br/>  })</pre> | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket to store the Terraform state | `string` | `"homelab-kuda-state"` | no |
| <a name="input_helm_charts"></a> [helm\_charts](#input\_helm\_charts) | values for Helm charts to be installed after the cluster is created | <pre>list(object({<br/>    name             = string<br/>    repository       = string<br/>    chart            = string<br/>    namespace        = string<br/>    create_namespace = optional(bool, false)<br/>    wait             = optional(bool, false)<br/>    version          = optional(string, null)<br/>    set = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_kubernetes_manifests"></a> [kubernetes\_manifests](#input\_kubernetes\_manifests) | List of Kubernetes manifest files or URLs to be applied after the cluster is created | `list(string)` | `[]` | no |
## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/2.7.0/docs/resources/file) | resource |
| [null_resource.argocd_manifests](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.waiting](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [proxmox_virtual_environment_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/0.96.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_pool.this](https://registry.terraform.io/providers/bpg/proxmox/0.96.0/docs/resources/virtual_environment_pool) | resource |
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/0.96.0/docs/resources/virtual_environment_vm) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/resources/machine_secrets) | resource |
| [proxmox_virtual_environment_file.iso](https://registry.terraform.io/providers/bpg/proxmox/0.96.0/docs/data-sources/virtual_environment_file) | data source |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/data-sources/client_configuration) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.10.1/docs/data-sources/machine_configuration) | data source |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.7.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.96.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.10.1 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.96.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.10.1 |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_how_many_controlplane_nodes_will_be_created"></a> [how\_many\_controlplane\_nodes\_will\_be\_created](#output\_how\_many\_controlplane\_nodes\_will\_be\_created) | Troubleshooting output |
| <a name="output_how_many_nodes_will_be_created"></a> [how\_many\_nodes\_will\_be\_created](#output\_how\_many\_nodes\_will\_be\_created) | Troubleshooting output |
| <a name="output_how_many_worker_nodes_will_be_created"></a> [how\_many\_worker\_nodes\_will\_be\_created](#output\_how\_many\_worker\_nodes\_will\_be\_created) | Troubleshooting output |
| <a name="output_installed_helm_charts"></a> [installed\_helm\_charts](#output\_installed\_helm\_charts) | List of installed Helm charts with their versions |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | value of kubeconfig to be used with kubectl |
| <a name="output_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#output\_kubeconfig\_file\_path) | Path where kubeconfig file is saved |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | Kubernetes API endpoint |
| <a name="output_kubernetes_manifests_applied"></a> [kubernetes\_manifests\_applied](#output\_kubernetes\_manifests\_applied) | List of Kubernetes manifests that will be applied after cluster creation |
| <a name="output_node_names"></a> [node\_names](#output\_node\_names) | List of node names that will be created |
| <a name="output_talos_endpoint"></a> [talos\_endpoint](#output\_talos\_endpoint) | Talos API endpoint |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | value of talosconfig to be used with talosctl |

## Author

👤 **Apgaua S**

* LinkedIn: [@apgauasousa](https://linkedin.com/in/apgauasousa)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2025 [Apgaua S](https://github.com/apgaua).<br />
This project is [MIT](LICENSE) licensed.
<!-- END_TF_DOCS -->
