# Infrastructure as Code (IaC) Proof of Concept for Home Labs

**Based on the excellent article by VirtualizationHowTo:**  
🔗 [Run Your Home Lab with Infrastructure as Code Like a Boss](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)

> **Credits:** This project is heavily inspired by and based on the patterns and best practices outlined in the VirtualizationHowTo article. All credit for the original concepts and methodology goes to the author at VirtualizationHowTo.com.

## 🎯 Project Overview

This repository demonstrates how to implement Infrastructure as Code (IaC) in your home lab environment using:

- **🏗️ Terraform** - Infrastructure provisioning and management
- **📦 Packer** - Golden image creation and template management
- **⚙️ Ansible** - Configuration management and automation
- **🔄 GitLab CI/CD** - Automated pipeline for validation, building, and deployment

## 🏠 Why Infrastructure as Code for Home Labs?

As highlighted in the VirtualizationHowTo article, treating your home lab like production infrastructure provides:

- **✅ Consistency** - Eliminate "oops, I forgot to set X" moments
- **📝 Version Control** - Roll back mistakes and track changes
- **🐄 Pets vs Cattle** - Treat servers as replaceable, not precious
- **📚 Documentation** - Your code becomes your documentation
- **🚀 Learning** - Develop enterprise-level skills in your home lab

## 📁 Project Structure

```
iac_poc/
├── terraform/                    # Infrastructure definitions
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── networking/          # Network configuration
│   │   ├── compute/             # VM and container resources
│   │   └── storage/             # Storage management
│   ├── environments/            # Environment-specific configs
│   │   ├── k8s-cluster/        # Kubernetes cluster setup
│   │   └── windows-domain/     # Windows AD domain setup
│   ├── provider.tf              # Proxmox provider configuration
│   └── variables.tf             # Global variables
├── packer/                      # Golden image templates
│   ├── templates/               # Packer template definitions
│   │   ├── debian-12/          # Debian 12 template
│   │   ├── ubuntu-22.04/       # Ubuntu 22.04 LTS template
│   │   └── windows-server-2022/ # Windows Server 2022 template
│   └── scripts/                 # Provisioning scripts
├── ansible/                     # Configuration management
│   ├── playbooks/              # Ansible playbooks
│   ├── roles/                  # Reusable Ansible roles
│   ├── inventory/              # Host inventories
│   └── group_vars/             # Group-specific variables
├── ci-cd/                       # CI/CD pipeline definitions
│   └── .gitlab-ci.yml          # GitLab CI/CD pipeline
└── docs/                        # Documentation
```

## 🖥️ Windows 11 Home Lab Setup Guide

### Prerequisites

#### Hardware Requirements
- **CPU**: Intel/AMD with virtualization support (VT-x/AMD-V)
- **RAM**: Minimum 16GB (32GB+ recommended)
- **Storage**: 500GB+ SSD for optimal performance
- **Network**: Gigabit Ethernet connection

#### Software Requirements
1. **Windows 11 Pro** (required for Hyper-V)
2. **Windows Subsystem for Linux (WSL2)**
3. **Docker Desktop for Windows**
4. **Git for Windows**
5. **Visual Studio Code** (recommended)

### Step 1: Enable Windows Features

1. **Enable Hyper-V and WSL2:**
   ```powershell
   # Run as Administrator
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
   Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   
   # Restart when prompted
   Restart-Computer
   ```

2. **Install WSL2 Ubuntu:**
   ```powershell
   wsl --install -d Ubuntu-22.04
   wsl --set-default-version 2
   ```

### Step 2: Install Proxmox VE

#### Option A: Proxmox on Dedicated Hardware (Recommended)
1. Download Proxmox VE ISO from [proxmox.com](https://www.proxmox.com/)
2. Create bootable USB with tools like Rufus
3. Install on dedicated server/workstation
4. Configure network settings during installation

#### Option B: Proxmox in Hyper-V (Testing Only)
1. Create new Hyper-V VM with:
   - **Generation**: 2
   - **Memory**: 8GB minimum
   - **Storage**: 100GB+ dynamic disk
   - **Network**: External virtual switch
   - **Nested Virtualization**: Enable in PowerShell:
     ```powershell
     Set-VMProcessor -VMName "ProxmoxVM" -ExposeVirtualizationExtensions $true
     ```

### Step 3: Setup Development Environment

1. **Install Git:**
   ```powershell
   winget install Git.Git
   ```

2. **Install Docker Desktop:**
   ```powershell
   winget install Docker.DockerDesktop
   ```

3. **Install Visual Studio Code:**
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```

4. **Install WSL2 packages:**
   ```bash
   # In WSL2 Ubuntu terminal
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y curl wget git vim unzip
   ```

### Step 4: Install IaC Tools in WSL2

1. **Install Terraform:**
   ```bash
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

2. **Install Packer:**
   ```bash
   sudo apt install packer
   ```

3. **Install Ansible:**
   ```bash
   sudo apt install software-properties-common
   sudo add-apt-repository --yes --update ppa:ansible/ansible
   sudo apt install ansible
   ```

### Step 5: Clone and Configure the Project

1. **Clone the repository:**
   ```bash
   cd ~
   git clone https://github.com/ly2xxx/iac_poc.git
   cd iac_poc
   ```

2. **Configure Terraform variables:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit with your Proxmox details
   nano terraform.tfvars
   ```

   Update with your values:
   ```hcl
   proxmox_api_url      = "https://your-proxmox-ip:8006/api2/json"
   proxmox_user         = "terraform@pve"
   proxmox_password     = "your-secure-password"
   proxmox_tls_insecure = true
   target_node          = "your-node-name"
   ```

3. **Set up Packer environment variables:**
   ```bash
   # Add to ~/.bashrc
   export PROXMOX_URL="https://your-proxmox-ip:8006/api2/json"
   export PROXMOX_USERNAME="packer@pve"
   export PROXMOX_PASSWORD="your-secure-password"
   export PROXMOX_NODE="your-node-name"
   
   source ~/.bashrc
   ```

### Step 6: Prepare Proxmox

1. **Create API users:**
   ```bash
   # On Proxmox host, create users for automation
   pveum user add terraform@pve
   pveum passwd terraform@pve
   pveum acl modify / -user terraform@pve -role Administrator
   
   pveum user add packer@pve
   pveum passwd packer@pve
   pveum acl modify / -user packer@pve -role Administrator
   ```

2. **Upload ISOs to Proxmox:**
   - Upload required ISOs to `/var/lib/vz/template/iso/` on Proxmox
   - Debian 12: `debian-12.2.0-amd64-netinst.iso`
   - Ubuntu 22.04: `ubuntu-22.04.3-live-server-amd64.iso`
   - Windows Server 2022: `windows-server-2022.iso`
   - VirtIO drivers: `virtio-win.iso`

### Step 7: Build Golden Images

1. **Validate Packer templates:**
   ```bash
   cd ~/iac_poc
   chmod +x build-all-templates.sh
   
   # Validate all templates
   cd packer/templates/debian-12 && packer validate debian.json
   cd ../ubuntu-22.04 && packer validate ubuntu.json
   cd ../windows-server-2022 && packer validate windows.json
   ```

2. **Build templates:**
   ```bash
   cd ~/iac_poc
   ./build-all-templates.sh
   ```

### Step 8: Deploy Infrastructure

1. **Deploy Kubernetes cluster:**
   ```bash
   cd ~/iac_poc/terraform/environments/k8s-cluster
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Windows domain:**
   ```bash
   cd ~/iac_poc/terraform/environments/windows-domain
   terraform init
   terraform plan
   terraform apply
   ```

### Step 9: Configure with Ansible

1. **Update inventory:**
   ```bash
   cd ~/iac_poc/ansible
   
   # Edit inventory with actual IP addresses
   nano inventory/hosts.yml
   ```

2. **Run Ansible playbooks:**
   ```bash
   # Test connectivity
   ansible all -i inventory/hosts.yml -m ping
   
   # Deploy configuration
   ansible-playbook -i inventory/hosts.yml playbooks/site.yml
   ```

## 🔧 Usage Examples

### Creating a New Environment

1. **Create environment directory:**
   ```bash
   mkdir terraform/environments/my-new-env
   cd terraform/environments/my-new-env
   ```

2. **Create main.tf:**
   ```hcl
   module "network" {
     source = "../../modules/networking"
     
     network_name = "my-network"
     subnet_cidr  = "10.3.0.0/24"
     vlan_id      = 300
   }
   
   module "compute" {
     source = "../../modules/compute"
     
     vm_count       = 2
     vm_template    = "ubuntu-22.04-template"
     cpu_cores      = 2
     memory_mb      = 4096
     target_node    = var.target_node
     vm_name_prefix = "my-app"
   }
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Adding New Ansible Role

1. **Create role structure:**
   ```bash
   cd ~/iac_poc/ansible/roles
   ansible-galaxy init my_new_role
   ```

2. **Add role to playbook:**
   ```yaml
   - hosts: my_servers
     become: true
     roles:
       - role: my_new_role
         tags: [my_new_role]
   ```

## 🚀 Advanced Features

### GitLab CI/CD Integration

1. **Setup GitLab Runner:**
   ```bash
   # Install GitLab Runner on a dedicated VM
   curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
   sudo apt install gitlab-runner
   
   # Register runner
   sudo gitlab-runner register
   ```

2. **Configure pipeline variables in GitLab:**
   - `PROXMOX_URL`
   - `PROXMOX_USERNAME`
   - `PROXMOX_PASSWORD`
   - `PROXMOX_NODE`

### Remote State Management

1. **Setup MinIO for state storage:**
   ```bash
   # Deploy MinIO container
   docker run -d \
     -p 9000:9000 \
     -p 9001:9001 \
     --name minio \
     -v ~/minio/data:/data \
     -e "MINIO_ROOT_USER=admin" \
     -e "MINIO_ROOT_PASSWORD=password123" \
     quay.io/minio/minio server /data --console-address ":9001"
   ```

2. **Configure Terraform backend:**
   ```hcl
   terraform {
     backend "s3" {
       endpoint = "http://your-minio-ip:9000"
       bucket   = "terraform-state"
       key      = "homelab/terraform.tfstate"
       region   = "us-east-1"
       
       skip_credentials_validation = true
       skip_metadata_api_check     = true
       skip_region_validation      = true
       force_path_style           = true
     }
   }
   ```

## 🛠️ Troubleshooting

### Common Issues

**Terraform Provider Issues:**
```bash
# Clear Terraform cache
rm -rf .terraform/
terraform init
```

**Packer Build Failures:**
```bash
# Check Packer logs
PACKER_LOG=1 packer build template.json

# Verify ISO paths in Proxmox
ls /var/lib/vz/template/iso/
```

**Ansible Connection Issues:**
```bash
# Test connectivity
ansible all -i inventory/hosts.yml -m ping -vvv

# Check SSH keys
ssh-copy-id user@target-host
```

**Windows Template Issues:**
- Ensure VirtIO drivers are available
- Check WinRM configuration
- Verify Windows firewall settings

### Performance Optimization

1. **Proxmox Storage:**
   - Use ZFS for better performance
   - Enable compression: `zfs set compression=lz4 pool/dataset`
   - Tune ARC cache: Add to `/etc/modprobe.d/zfs.conf`

2. **VM Templates:**
   - Install QEMU Guest Agent
   - Use VirtIO drivers for network and storage
   - Enable ballooning for dynamic memory

3. **Network Performance:**
   - Use VirtIO network adapters
   - Consider SR-IOV for high-performance workloads
   - Implement proper VLAN segmentation

## 📚 Learning Resources

- **Original Article**: [VirtualizationHowTo IaC Guide](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)
- **Terraform Documentation**: [terraform.io](https://terraform.io/docs)
- **Packer Documentation**: [packer.io](https://packer.io/docs)
- **Ansible Documentation**: [docs.ansible.com](https://docs.ansible.com)
- **Proxmox Documentation**: [pve.proxmox.com](https://pve.proxmox.com/pve-docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

**Special thanks to [VirtualizationHowTo](https://www.virtualizationhowto.com/)** for the excellent article that inspired this project. The methodologies, best practices, and architectural patterns demonstrated here are based on their comprehensive guide to home lab Infrastructure as Code.

---

**⭐ If you found this helpful, please star the repository and check out the original VirtualizationHowTo article!**
