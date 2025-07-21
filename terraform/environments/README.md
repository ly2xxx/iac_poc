# Terraform Environments

This directory contains example environment configurations demonstrating how to use the IaC modules to create complete infrastructure setups.

## Available Environments

### 1. Kubernetes Cluster (`k8s-cluster/`)
Creates a 3-node Kubernetes cluster environment with:
- 3 Ubuntu VMs with 4 CPU cores and 8GB RAM each
- Network isolation using VLAN 100
- Fast SSD storage allocation

### 2. Windows Domain (`windows-domain/`)
Creates a Windows Active Directory domain environment with:
- 1 Domain Controller (Windows Server 2022)
- 2 Member servers
- Network isolation using VLAN 200
- Standard storage allocation

## Usage

1. Navigate to the desired environment directory:
   ```bash
   cd terraform/environments/k8s-cluster
   # or
   cd terraform/environments/windows-domain
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Prerequisites

- Proxmox VE server configured and accessible
- VM templates created using Packer (see `../../packer/` directory)
- Proper network configuration on Proxmox host
- Terraform variables configured (see `terraform.tfvars.example`)

## Customization

You can customize these environments by:
- Modifying the module parameters in `main.tf`
- Adjusting VM specifications (CPU, memory, disk)
- Changing network configurations
- Adding additional modules or resources

## Credits

Based on Infrastructure as Code patterns from [VirtualizationHowTo](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)
