# Compute module for creating VMs and LXC containers
# Based on VirtualizationHowTo article examples

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "vm_template" {
  description = "Template to use for VM creation"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "target_node" {
  description = "Proxmox node name"
  type        = string
}

variable "storage" {
  description = "Storage pool to use"
  type        = string
  default     = "local-zfs"
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = string
  default     = "20G"
}

# Create VMs based on template
resource "proxmox_vm_qemu" "vm" {
  count       = var.vm_count
  name        = "${var.vm_name_prefix}-${count.index + 1}"
  target_node = var.target_node
  clone       = var.vm_template
  
  # VM Configuration
  cores    = var.cpu_cores
  sockets  = 1
  memory   = var.memory_mb
  
  # Disk configuration
  disk {
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage
  }
  
  # Network configuration
  network {
    model  = "virtio"
    bridge = var.network_bridge
  }
  
  # Cloud-init configuration
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"
  
  # Enable QEMU Guest Agent
  agent = 1
  
  tags = "terraform,iac-poc"
}

# Example LXC container resource (commented out by default)
# resource "proxmox_lxc" "container" {
#   count       = var.vm_count
#   hostname    = "${var.vm_name_prefix}-lxc-${count.index + 1}"
#   target_node = var.target_node
#   ostemplate  = var.vm_template  # Should be LXC template
#   
#   cores  = var.cpu_cores
#   memory = var.memory_mb
#   
#   rootfs {
#     storage = var.storage
#     size    = var.disk_size
#   }
#   
#   network {
#     name   = "eth0"
#     bridge = var.network_bridge
#     ip     = "dhcp"
#   }
# }
