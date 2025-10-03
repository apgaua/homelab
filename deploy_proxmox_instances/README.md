<!-- BEGIN_TF_DOCS -->
# Deply proxmox instances

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.3 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.2-rc04 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.2-rc04 |

## Resources

| Name | Type |
|------|------|
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/2.5.3/docs/resources/file) | resource |
| [proxmox_vm_qemu.masters](https://registry.terraform.io/providers/telmate/proxmox/3.0.2-rc04/docs/resources/vm_qemu) | resource |
| [proxmox_vm_qemu.workers](https://registry.terraform.io/providers/telmate/proxmox/3.0.2-rc04/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket to store the Terraform state | `string` | `"homelab-kuda-state"` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Configurations for the cluster | <pre>object({<br/>    name          = string<br/>    description   = string<br/>    template      = string<br/>    default_user  = string<br/>    cidr          = string<br/>    resource_pool = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_masters"></a> [masters](#input\_masters) | Master nodes configuration | <pre>object({<br/>    count               = number<br/>    vmid_prefix         = optional(number)<br/>    cores               = number<br/>    memory              = number<br/>    balloon             = optional(number)<br/>    sockets             = number<br/>    network_last_octect = number<br/>  })</pre> | n/a | yes |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox backend configuration | <pre>object({<br/>    ip   = string<br/>    port = number<br/>  })</pre> | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | SSH configuration | <pre>object({<br/>    private_key = string<br/>    public_key  = string<br/>  })</pre> | n/a | yes |
| <a name="input_workers"></a> [workers](#input\_workers) | Worker nodes configuration | <pre>object({<br/>    count               = number<br/>    vmid_prefix         = number<br/>    cores               = number<br/>    memory              = number<br/>    sockets             = number<br/>    balloon             = optional(number)<br/>    network_last_octect = number<br/>  })</pre> | n/a | yes |

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