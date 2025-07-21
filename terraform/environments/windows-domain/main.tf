# Windows Domain Environment
# Based on VirtualizationHowTo article example

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.5"
    }
  }
}

# Network configuration for Windows domain
module "network" {
  source = "../../modules/networking"
  
  network_name = "domain-network"
  subnet_cidr  = "10.2.0.0/24"
  vlan_id      = 200
  gateway      = "10.2.0.1"
}

# Domain Controller
module "domain_controller" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "windows-server-2022-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "dc"
  disk_size      = "100G"
  network_bridge = "vmbr0"
}

# Domain member servers
module "member_servers" {
  source = "../../modules/compute"
  
  vm_count       = 2
  vm_template    = "windows-server-2022-template"
  cpu_cores      = 2
  memory_mb      = 4096
  target_node    = var.target_node
  vm_name_prefix = "srv"
  disk_size      = "80G"
  network_bridge = "vmbr0"
}

# Storage configuration
module "storage" {
  source = "../../modules/storage"
  
  storage_type = "standard"
  size_gb      = 50
  vm_ids       = concat(module.domain_controller.vm_ids, module.member_servers.vm_ids)
}

# Variables
variable "target_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

# Outputs
output "windows_domain_info" {
  description = "Windows domain information"
  value = {
    domain_controller = {
      names = module.domain_controller.vm_names
      ids   = module.domain_controller.vm_ids
      ips   = module.domain_controller.vm_ips
    }
    member_servers = {
      names = module.member_servers.vm_names
      ids   = module.member_servers.vm_ids
      ips   = module.member_servers.vm_ips
    }
    network = module.network.network_config
  }
}
