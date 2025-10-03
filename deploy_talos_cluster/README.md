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

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.38.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.3 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc04 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.2-rc04 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.9.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.main](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/2.5.3/docs/resources/file) | resource |
| [null_resource.wait_for_k8s_api](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [proxmox_vm_qemu.this](https://registry.terraform.io/providers/telmate/proxmox/3.0.2-rc04/docs/resources/vm_qemu) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/data-sources/client_configuration) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Configurations for the cluster | <pre>object({<br/>    name           = string<br/>    description    = string<br/>    cidr           = string<br/>    isoimage       = string<br/>    resource_pool  = optional(string)<br/>    talos_endpoint = string<br/>    vmid_prefix    = number<br/>    kubeconfig     = string<br/>  })</pre> | n/a | yes |
| <a name="input_controlplane_nodes"></a> [controlplane\_nodes](#input\_controlplane\_nodes) | Hardware configuration for control plane nodes | <pre>object({<br/>    sockets   = number<br/>    cores     = number<br/>    memory    = number<br/>    balloon   = optional(number)<br/>    disk_size = number<br/>  })</pre> | n/a | yes |
| <a name="input_hardware"></a> [hardware](#input\_hardware) | Base hardware configuration for the VMs | <pre>object({<br/>    cpu_type = string<br/>  })</pre> | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | List of nodes to be created | <pre>list(object({<br/>    type        = string<br/>    ip          = string<br/>    mac_address = string<br/>  }))</pre> | n/a | yes |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox backend configuration | <pre>object({<br/>    ip   = string<br/>    port = number<br/>  })</pre> | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | SSH configuration | <pre>object({<br/>    private_key = string<br/>    public_key  = string<br/>  })</pre> | n/a | yes |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Hardware configuration for worker nodes | <pre>object({<br/>    sockets   = number<br/>    cores     = number<br/>    memory    = number<br/>    balloon   = optional(number)<br/>    disk_size = number<br/>  })</pre> | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket to store the Terraform state | `string` | `"homelab-kuda-state"` | no |
| <a name="input_helm_charts"></a> [helm\_charts](#input\_helm\_charts) | n/a | <pre>list(object({<br/>    name             = string<br/>    repository       = string<br/>    chart            = string<br/>    namespace        = string<br/>    create_namespace = optional(bool, false)<br/>    wait             = optional(bool, false)<br/>    version          = optional(string, null)<br/>    set = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_how_many_controlplane_nodes_will_be_created"></a> [how\_many\_controlplane\_nodes\_will\_be\_created](#output\_how\_many\_controlplane\_nodes\_will\_be\_created) | Trouble-shooting output |
| <a name="output_how_many_nodes_will_be_created"></a> [how\_many\_nodes\_will\_be\_created](#output\_how\_many\_nodes\_will\_be\_created) | Trouble-shooting output |
| <a name="output_how_many_worker_nodes_will_be_created"></a> [how\_many\_worker\_nodes\_will\_be\_created](#output\_how\_many\_worker\_nodes\_will\_be\_created) | Trouble-shooting output |
| <a name="output_installed_helm_charts"></a> [installed\_helm\_charts](#output\_installed\_helm\_charts) | List of installed Helm charts with their versions |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#output\_kubeconfig\_file\_path) | Path where the kubeconfig file is saved |
| <a name="output_kubernetes_endpoint"></a> [kubernetes\_endpoint](#output\_kubernetes\_endpoint) | Kubernetes API endpoint |
| <a name="output_node_names"></a> [node\_names](#output\_node\_names) | List of node names that will be created |
| <a name="output_talos_endpoint"></a> [talos\_endpoint](#output\_talos\_endpoint) | Talos API endpoint |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |

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
