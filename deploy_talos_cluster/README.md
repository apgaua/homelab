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

### Proxmox user privileges
To properly run bgp/proxmox provider, the permissions bellow are needed:

Sys.Console, VM.Allocate, Datastore.AllocateTemplate, VM.Config.HWType, VM.Config.Memory, Mapping.Use, VM.Config.Network, VM.Config.CDROM, VM.GuestAgent.Unrestricted, VM.Clone, Sys.Audit, VM.Config.CPU, Sys.Modify, VM.PowerMgmt, SDN.Use, VM.Migrate, Pool.Audit, Datastore.Allocate, VM.Config.Options, Datastore.Audit, VM.Config.Cloudinit, Pool.Allocate, Datastore.AllocateSpace, VM.GuestAgent.Audit, VM.Config.Disk, VM.Audit

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
