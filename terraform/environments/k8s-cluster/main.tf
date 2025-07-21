# Kubernetes Cluster Environment
# Based on VirtualizationHowTo article example

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.5"
    }
  }
}

# Network configuration for K8s cluster
module "network" {
  source = "../../modules/networking"
  
  network_name = "k8s-network"
  subnet_cidr  = "10.1.0.0/24"
  vlan_id      = 100
  gateway      = "10.1.0.1"
}

# Compute resources for K8s nodes
module "compute" {
  source = "../../modules/compute"
  
  vm_count       = 3
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "k8s-node"
  disk_size      = "50G"
  network_bridge = "vmbr0"
}

# Storage configuration
module "storage" {
  source = "../../modules/storage"
  
  storage_type = "fast-ssd"
  size_gb      = 100
  vm_ids       = module.compute.vm_ids
}

# Variables
variable "target_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

# Outputs
output "k8s_cluster_info" {
  description = "Kubernetes cluster information"
  value = {
    vm_names = module.compute.vm_names
    vm_ids   = module.compute.vm_ids
    vm_ips   = module.compute.vm_ips
    network  = module.network.network_config
  }
}
