resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      master = {
        index      = range(var.masters.count)
        ip_address = proxmox_vm_qemu.masters.*.default_ipv4_address
        user       = proxmox_vm_qemu.masters.*.ciuser
        vm_name    = proxmox_vm_qemu.masters.*.name
      }
      worker = {
        index      = range(var.workers.count)
        ip_address = proxmox_vm_qemu.workers.*.default_ipv4_address
        user       = proxmox_vm_qemu.workers.*.ciuser
        vm_name    = proxmox_vm_qemu.workers.*.name
      }
    }
  )
  filename        = "inventory_files/${var.cluster.name}.ini"
  file_permission = "0600"
}