output "vm_ids" {
  description = "List of VM IDs"
  value       = proxmox_vm_qemu.vm[*].vmid
}

output "vm_names" {
  description = "List of VM names"
  value       = proxmox_vm_qemu.vm[*].name
}

output "vm_ips" {
  description = "List of VM IP addresses"
  value       = proxmox_vm_qemu.vm[*].default_ipv4_address
}
