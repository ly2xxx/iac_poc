# Home Lab Infrastructure as Code Setup Plan

## Overview

This document provides a step-by-step guide for setting up a complete Infrastructure as Code (IaC) home lab environment using Terraform, Packer, Ansible, and CI/CD pipelines. This plan is based on the excellent article from [VirtualizationHowTo](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/) and implemented in a WSL2 environment.

**Last Updated:** 2025-07-25  
**Status:** 🚧 In Progress

---

## Prerequisites

### Hardware Requirements
- **CPU**: Intel/AMD with virtualization support (VT-x/AMD-V)
- **RAM**: Minimum 16GB (32GB+ recommended for running multiple VMs)
- **Storage**: 500GB+ SSD for optimal performance
- **Network**: Gigabit Ethernet connection

### Software Requirements
- **Windows 11 Pro** (required for Hyper-V if using nested virtualization)
- **Windows Subsystem for Linux (WSL2)** with Ubuntu 22.04
- **Proxmox VE** (on dedicated hardware or VM)
- **Git** for version control

---

## Phase 1: Environment Setup ⚠️ Requires Manual Intervention

### Step 1.1: WSL2 Environment Setup
- **Script Location**: `/scripts/setup-wsl-tools.sh`
- **Purpose**: Automated installation of all IaC tools in WSL2
- **Status**: ❌ **Requires sudo access - Manual installation needed**

**Current Situation:**
The automated setup script requires sudo privileges that aren't available in this environment. The following tools need to be installed manually:

**Tools to Install:**
- [ ] Terraform (not installed)
- [ ] Packer (not installed)  
- [ ] Ansible (not installed)
- [ ] Python packages (ansible-lint, yamllint)
- [ ] Git configuration

**Manual Installation Commands:**
```bash
# These commands require sudo access:
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform packer

# Install Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Install Python packages
sudo apt install python3-pip
pip3 install --user ansible-lint yamllint jmespath netaddr requests
```

**Action Items:**
- [ ] ⚠️ Manual tool installation required
- [ ] Verify tool installations once available
- [ ] Configure Git credentials
- [ ] Set up SSH keys

### Step 1.2: Environment Variables Configuration
Create and configure Proxmox connection details:

```bash
# Copy template and customize
cp ~/.iac_env_template ~/.iac_env
# Edit with your Proxmox details
vim ~/.iac_env
# Source the environment
source ~/.iac_env
```

**Required Variables:**
- `PROXMOX_URL`: Your Proxmox server URL
- `PROXMOX_USERNAME`: API user (e.g., terraform@pve)
- `PROXMOX_PASSWORD`: API user password
- `PROXMOX_NODE`: Target Proxmox node name

---

## Phase 2: Complete Missing Components ✅ Completed

### Step 2.1: Packer Templates Creation
**Current Status**: ✅ **All templates created and configured**

**Created Templates:**
- ✅ `/packer/templates/debian-12/debian.json` + `preseed.cfg`
- ✅ `/packer/templates/ubuntu-22.04/ubuntu.json` + `user-data` + `meta-data`
- ✅ `/packer/templates/windows-server-2022/windows.json` + `Autounattend.xml` + `setup.ps1`

**Template Features Implemented:**
- ✅ Proxmox builder configuration with VirtIO drivers
- ✅ Automated installation (preseed/autoinstall/unattend)
- ✅ QEMU Guest Agent installation
- ✅ Cloud-init support (Linux templates)
- ✅ SSH/WinRM configuration for Packer communication
- ✅ Base software packages (Docker for Ubuntu)
- ✅ Cleanup scripts for optimized image size

### Step 2.2: Terraform Configuration
**Current Status**: Modules exist, environment-specific configs need customization

**Action Items:**
- [ ] Configure `/terraform/terraform.tfvars` with Proxmox details
- [ ] Validate module configurations
- [ ] Test environment deployments

### Step 2.3: Ansible Inventory Setup
**Current Status**: Roles exist, inventory needs network-specific configuration

**Files to Configure:**
- `/ansible/inventory/hosts.yml`
- `/ansible/group_vars/all.yml`
- Network-specific variables

---

## Phase 3: CI/CD Integration ✅ Completed

### CI/CD Pipeline Options Available

**Current Status**: ✅ **Both GitLab CI/CD and GitHub Actions pipelines ready**

#### Option A: GitLab CI/CD Pipeline
- ✅ **File**: `ci-cd/.gitlab-ci.yml` (existing, comprehensive)
- ✅ **Features**: Validation, planning, building, deployment, drift detection
- ✅ **GitHub Integration**: Supports GitHub repository import
- ✅ **Manual Controls**: All deployment stages require manual approval

#### Option B: GitHub Actions Pipeline ⭐ **Recommended**
- ✅ **File**: `.github/workflows/iac.yml` (newly created)
- ✅ **Features**: Same functionality as GitLab pipeline
- ✅ **Native Integration**: No external services required
- ✅ **Workflow Dispatch**: Manual trigger options for all operations
- ✅ **Environment Protection**: Built-in approval workflows

#### Option C: Dual Pipeline Setup
- ✅ **Flexibility**: Run both pipelines simultaneously
- ✅ **Comparison**: Test both platforms side-by-side
- ✅ **Migration Path**: Easy transition between platforms

### Pipeline Features Implemented:
- ✅ **Code Validation**: Terraform, Packer, Ansible linting
- ✅ **Infrastructure Planning**: Terraform plan generation
- ✅ **Template Building**: Packer template builds (Debian, Ubuntu, Windows)
- ✅ **Infrastructure Deployment**: Kubernetes cluster and Windows domain
- ✅ **Configuration Management**: Ansible playbook execution
- ✅ **Drift Detection**: Scheduled infrastructure state checking
- ✅ **Environment Cleanup**: Destroy operations with approval gates

### Setup Documentation:
📚 **Comprehensive guide created**: `CI_CD_SETUP.md`
- Step-by-step setup for both platforms
- Secrets configuration
- Security best practices
- Troubleshooting guide

---

## Phase 4: Infrastructure Deployment 🚀 Implementation Phase

### Step 4.1: Build Golden Images
```bash
# Validate all templates
cd packer/templates/debian-12 && packer validate debian.json
cd ../ubuntu-22.04 && packer validate ubuntu.json
cd ../windows-server-2022 && packer validate windows.json

# Build templates
./build-all-templates.sh
```

### Step 4.2: Deploy Test Infrastructure
```bash
# Deploy Kubernetes cluster
cd terraform/environments/k8s-cluster
terraform init && terraform plan && terraform apply

# Deploy Windows domain
cd ../windows-domain
terraform init && terraform plan && terraform apply
```

### Step 4.3: Apply Configuration Management
```bash
# Test connectivity
cd ansible
ansible all -i inventory/hosts.yml -m ping

# Deploy configurations
ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

---

## Phase 5: Documentation & Best Practices 📚 Continuous Improvement

### Step 5.1: Documentation Updates
- [ ] Update README.md with actual implementation details
- [ ] Create troubleshooting guide based on issues encountered
- [ ] Document network topology and IP assignments

### Step 5.2: Security Implementation
- [ ] Set up Ansible Vault for secrets management
- [ ] Configure Terraform backend for remote state
- [ ] Implement proper RBAC in Proxmox

### Step 5.3: Monitoring and Maintenance
- [ ] Set up infrastructure monitoring
- [ ] Configure automated backups
- [ ] Implement drift detection

---

## Implementation Status Tracking

### ✅ Completed Tasks
- ✅ **Documentation**: Comprehensive setup plan and guides created
- ✅ **Packer Templates**: All three templates completed (Debian, Ubuntu, Windows)
- ✅ **CI/CD Pipelines**: Both GitLab CI/CD and GitHub Actions workflows ready
- ✅ **Infrastructure Modules**: Terraform modules for compute, networking, storage
- ✅ **Ansible Roles**: Configuration management roles for common, docker, monitoring, security
- ✅ **Build Scripts**: Automated template building with `build-all-templates.sh`
- ✅ **Troubleshooting Guide**: Comprehensive issue resolution documentation

### ⚠️ Requires Manual Intervention
- ⚠️ **Tool Installation**: Terraform, Packer, Ansible need manual installation (sudo required)
- ⚠️ **Environment Configuration**: Proxmox connection details need to be configured
- ⚠️ **CI/CD Setup**: Repository secrets need to be configured

### 🎯 Ready for Deployment
- 🎯 **Infrastructure Components**: All code ready for execution
- 🎯 **Automation Pipelines**: Ready to build and deploy
- 🎯 **Documentation**: Complete guides for setup and troubleshooting

---

## Troubleshooting Section

### Comprehensive Troubleshooting Guide
📚 **Detailed troubleshooting documentation**: `TROUBLESHOOTING.md`

**Covers:**
- ✅ Environment setup issues (WSL2, tool installation)
- ✅ Packer template build problems
- ✅ Terraform deployment issues
- ✅ Ansible configuration problems
- ✅ CI/CD pipeline debugging
- ✅ Proxmox-specific solutions
- ✅ Network connectivity troubleshooting
- ✅ Resource and performance issues

### Known Limitations
- **Nested Virtualization**: Performance impact when running Proxmox in VM
- **WSL2 Networking**: May require additional configuration for Proxmox access
- **Resource Requirements**: Home lab hardware may limit concurrent VMs
- **API Rate Limits**: Proxmox API has built-in rate limiting
- **Windows Templates**: Require more resources and time to build

---

## Resources and References

- [Original VirtualizationHowTo Article](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)
- [Terraform Proxmox Provider Documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Packer Proxmox Builder Documentation](https://www.packer.io/plugins/builders/proxmox)
- [Ansible Documentation](https://docs.ansible.com/)

---

## Next Steps

1. **Execute Phase 1**: Run WSL2 setup script and configure environment
2. **Complete Phase 2**: Create missing Packer templates
3. **Test Phase 4**: Deploy a simple test environment
4. **Implement Phase 3**: Set up CI/CD integration

---

*This document will be updated as we progress through each phase, documenting actual implementation details, issues encountered, and solutions found.*