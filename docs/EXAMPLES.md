# Usage Examples

This document provides practical examples for using the Infrastructure as Code setup based on the [VirtualizationHowTo article](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/).

## Table of Contents

- [Basic VM Deployment](#basic-vm-deployment)
- [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
- [Windows Domain Deployment](#windows-domain-deployment)
- [Custom Environment Creation](#custom-environment-creation)
- [Multi-Environment Management](#multi-environment-management)
- [GitLab CI/CD Usage](#gitlab-cicd-usage)

## Basic VM Deployment

### Single Ubuntu VM

Create a simple Ubuntu VM for testing:

```hcl
# environments/single-vm/main.tf
module "test_vm" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 2
  memory_mb      = 4096
  target_node    = "pve"
  vm_name_prefix = "test"
  disk_size      = "30G"
}

output "vm_info" {
  value = {
    name = module.test_vm.vm_names[0]
    id   = module.test_vm.vm_ids[0]
    ip   = module.test_vm.vm_ips[0]
  }
}
```

Deploy:

```bash
cd terraform/environments/single-vm
terraform init
terraform apply
```

### Multiple VMs with Different Specs

```hcl
# environments/mixed-vms/main.tf

# Web servers
module "web_servers" {
  source = "../../modules/compute"
  
  vm_count       = 2
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 2
  memory_mb      = 4096
  target_node    = var.target_node
  vm_name_prefix = "web"
  disk_size      = "40G"
}

# Database server
module "database_server" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "db"
  disk_size      = "100G"
  storage        = "fast-ssd"
}
```

## Kubernetes Cluster Setup

### Three-Node K8s Cluster

The project includes a complete K8s cluster example:

```bash
# Deploy the cluster
cd terraform/environments/k8s-cluster
terraform init
terraform plan
terraform apply

# Configure with Ansible
cd ../../../ansible
ansible-playbook -i inventory/hosts.yml playbooks/k8s-setup.yml
```

### Custom K8s Configuration

Create a larger cluster:

```hcl
# environments/k8s-large/main.tf
module "k8s_masters" {
  source = "../../modules/compute"
  
  vm_count       = 3  # HA masters
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "k8s-master"
  disk_size      = "50G"
}

module "k8s_workers" {
  source = "../../modules/compute"
  
  vm_count       = 5  # Worker nodes
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 8
  memory_mb      = 16384
  target_node    = var.target_node
  vm_name_prefix = "k8s-worker"
  disk_size      = "100G"
}
```

## Windows Domain Deployment

### Basic AD Domain

Deploy a Windows domain with the included example:

```bash
cd terraform/environments/windows-domain
terraform init
terraform apply

# Configure with Ansible
cd ../../../ansible
ansible-playbook -i inventory/hosts.yml playbooks/windows-domain.yml
```

### Extended Domain Setup

```hcl
# environments/windows-enterprise/main.tf

# Domain Controllers (HA)
module "domain_controllers" {
  source = "../../modules/compute"
  
  vm_count       = 2
  vm_template    = "windows-server-2022-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "dc"
  disk_size      = "120G"
}

# File servers
module "file_servers" {
  source = "../../modules/compute"
  
  vm_count       = 2
  vm_template    = "windows-server-2022-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "fs"
  disk_size      = "500G"
}

# SQL Server
module "sql_server" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "windows-server-2022-template"
  cpu_cores      = 8
  memory_mb      = 16384
  target_node    = var.target_node
  vm_name_prefix = "sql"
  disk_size      = "300G"
}
```

## Custom Environment Creation

### Development Environment

```hcl
# environments/dev-env/main.tf

# Network configuration
module "dev_network" {
  source = "../../modules/networking"
  
  network_name = "dev-network"
  subnet_cidr  = "10.10.0.0/24"
  vlan_id      = 110
}

# Development VMs
module "dev_vms" {
  source = "../../modules/compute"
  
  vm_count       = 3
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "dev"
  disk_size      = "80G"
}

# Variables
variable "target_node" {
  description = "Proxmox node"
  type        = string
  default     = "pve"
}

# Outputs
output "dev_environment" {
  value = {
    network = module.dev_network.network_config
    vms = {
      names = module.dev_vms.vm_names
      ips   = module.dev_vms.vm_ips
    }
  }
}
```

### Testing Environment

```hcl
# environments/test-env/main.tf

# Load balancer
module "load_balancer" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 2
  memory_mb      = 4096
  target_node    = var.target_node
  vm_name_prefix = "lb"
}

# Application servers
module "app_servers" {
  source = "../../modules/compute"
  
  vm_count       = 3
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "app"
}

# Database
module "database" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "db"
  disk_size      = "200G"
}
```

## Multi-Environment Management

### Environment Switching

Use Terraform workspaces for multiple environments:

```bash
# Create workspaces
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between environments
terraform workspace select development
terraform apply

terraform workspace select staging
terraform apply
```

### Environment-Specific Variables

```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vm_sizes" {
  description = "VM sizes per environment"
  type = map(object({
    cpu_cores = number
    memory_mb = number
    disk_size = string
  }))
  default = {
    dev = {
      cpu_cores = 2
      memory_mb = 4096
      disk_size = "40G"
    }
    staging = {
      cpu_cores = 4
      memory_mb = 8192
      disk_size = "80G"
    }
    production = {
      cpu_cores = 8
      memory_mb = 16384
      disk_size = "200G"
    }
  }
}

# main.tf
locals {
  env_config = var.vm_sizes[var.environment]
}

module "compute" {
  source = "../../modules/compute"
  
  vm_count    = 3
  vm_template = "ubuntu-22.04-template"
  cpu_cores   = local.env_config.cpu_cores
  memory_mb   = local.env_config.memory_mb
  disk_size   = local.env_config.disk_size
  target_node = var.target_node
  vm_name_prefix = "${var.environment}-app"
}
```

## GitLab CI/CD Usage

### Automated Deployment Pipeline

The included `.gitlab-ci.yml` provides automation. Configure variables in GitLab:

```yaml
# GitLab CI/CD Variables (Settings > CI/CD > Variables)
PROXMOX_URL: "https://proxmox.local:8006/api2/json"
PROXMOX_USERNAME: "terraform@pve"
PROXMOX_PASSWORD: "your-password"  # Mark as protected
PROXMOX_NODE: "pve"
```

### Manual Deployment Jobs

```yaml
# Custom deployment job
deploy_custom_env:
  stage: deploy
  image: hashicorp/terraform:latest
  script:
    - cd terraform/environments/custom-env
    - terraform init
    - terraform apply -auto-approve
  when: manual
  environment:
    name: custom
    action: start
```

### Environment-Specific Pipelines

```yaml
# Deploy to different environments based on branch
deploy_development:
  extends: .deploy_template
  variables:
    ENVIRONMENT: "development"
  only:
    - develop

deploy_staging:
  extends: .deploy_template
  variables:
    ENVIRONMENT: "staging"
  only:
    - staging

deploy_production:
  extends: .deploy_template
  variables:
    ENVIRONMENT: "production"
  only:
    - main
  when: manual
```

## Advanced Scenarios

### DR Environment

```hcl
# environments/disaster-recovery/main.tf

# Backup infrastructure in secondary site
module "dr_infrastructure" {
  source = "../../modules/compute"
  
  vm_count       = 5
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = "pve-dr"  # Secondary node
  vm_name_prefix = "dr"
  disk_size      = "100G"
}

# Backup storage
module "dr_storage" {
  source = "../../modules/storage"
  
  storage_type = "backup"
  size_gb      = 1000
  vm_ids       = module.dr_infrastructure.vm_ids
}
```

### Monitoring Stack

```hcl
# environments/monitoring/main.tf

# Prometheus server
module "prometheus" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 4
  memory_mb      = 8192
  target_node    = var.target_node
  vm_name_prefix = "prometheus"
  disk_size      = "200G"
}

# Grafana server
module "grafana" {
  source = "../../modules/compute"
  
  vm_count       = 1
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 2
  memory_mb      = 4096
  target_node    = var.target_node
  vm_name_prefix = "grafana"
}

# ELK Stack
module "elasticsearch" {
  source = "../../modules/compute"
  
  vm_count       = 3
  vm_template    = "ubuntu-22.04-template"
  cpu_cores      = 8
  memory_mb      = 16384
  target_node    = var.target_node
  vm_name_prefix = "elastic"
  disk_size      = "500G"
}
```

## Best Practices

### Resource Naming

```hcl
# Use consistent naming conventions
vm_name_prefix = "${var.environment}-${var.application}-${var.tier}"

# Example: "prod-web-frontend-1"
```

### Tagging

```hcl
# Add tags to resources
tags = "environment=${var.environment},application=${var.application},managed=terraform"
```

### Resource Limits

```hcl
# Set reasonable defaults with overrides
variable "vm_specs" {
  description = "VM specifications"
  type = object({
    cpu_cores = number
    memory_mb = number
    disk_size = string
  })
  default = {
    cpu_cores = 2
    memory_mb = 4096
    disk_size = "40G"
  }
  validation {
    condition     = var.vm_specs.cpu_cores <= 16
    error_message = "CPU cores cannot exceed 16."
  }
}
```

---

These examples demonstrate the flexibility and power of the IaC approach outlined in the VirtualizationHowTo article. Start with simple deployments and gradually build more complex environments as you become comfortable with the tools and patterns.
