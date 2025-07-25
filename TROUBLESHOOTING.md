# Troubleshooting Guide

This comprehensive troubleshooting guide covers common issues encountered when implementing Infrastructure as Code in your home lab environment.

**Last Updated:** 2025-07-25

---

## Quick Reference

### Environment Check Commands
```bash
# Verify tool installations
terraform version
packer version
ansible --version

# Check environment variables
echo $PROXMOX_URL
echo $PROXMOX_USERNAME
echo $PROXMOX_NODE

# Test Proxmox API connectivity
curl -k -d "username=$PROXMOX_USERNAME&password=$PROXMOX_PASSWORD" \
     "$PROXMOX_URL/access/ticket"
```

### Log Locations
- **Packer logs**: Set `PACKER_LOG=1` for verbose output
- **Terraform logs**: Set `TF_LOG=DEBUG` for detailed logging
- **Ansible logs**: Use `-vvv` flag for verbose output
- **GitHub Actions**: Actions tab > Workflow run > Job logs
- **GitLab CI/CD**: CI/CD > Pipelines > Job logs

---

## Phase 1: Environment Setup Issues

### WSL2 Setup Problems

#### Issue: "sudo: a terminal is required to read the password"
**Symptoms:**
- Setup script fails with sudo password prompt
- Cannot install packages with apt

**Solution:**
```bash
# Run commands manually with password input
sudo apt update
sudo apt upgrade -y

# Or configure passwordless sudo (advanced users)
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
```

#### Issue: WSL2 networking problems
**Symptoms:**
- Cannot reach Proxmox server from WSL2
- DNS resolution fails

**Solutions:**
```bash
# Check WSL2 networking
ip route show
cat /etc/resolv.conf

# Add Windows host entries to WSL2
echo "192.168.1.100 proxmox.local" | sudo tee -a /etc/hosts

# Restart WSL2 networking
sudo service networking restart
```

### Tool Installation Issues

#### Issue: Terraform/Packer/Ansible not found
**Symptoms:**
- `command not found` errors
- Tools not in PATH

**Solutions:**
```bash
# Check installation
which terraform packer ansible

# Add to PATH if installed but not found
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# Manual installation via package managers
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Packer
sudo apt-get install packer

# Ansible
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update && sudo apt-get install ansible
```

---

## Phase 2: Infrastructure Code Issues

### Packer Template Problems

#### Issue: Packer build fails with authentication error
**Symptoms:**
```
Error: authentication failed: 401 Unauthorized
```

**Solutions:**
```bash
# Verify environment variables
echo "URL: $PROXMOX_URL"
echo "User: $PROXMOX_USERNAME"
echo "Node: $PROXMOX_NODE"

# Test API access manually
curl -k -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$PROXMOX_USERNAME&password=$PROXMOX_PASSWORD" \
  "$PROXMOX_URL/access/ticket"

# Check Proxmox user permissions
# On Proxmox server:
pveum user list
pveum aclmod / -user terraform@pve -role Administrator
```

#### Issue: ISO file not found during Packer build
**Symptoms:**
```
Error: iso_file "local:iso/debian-12.2.0-amd64-netinst.iso" not found
```

**Solutions:**
```bash
# Check ISOs on Proxmox server
ssh root@proxmox "ls -la /var/lib/vz/template/iso/"

# Upload ISOs via web interface or CLI
scp debian-12.2.0-amd64-netinst.iso root@proxmox:/var/lib/vz/template/iso/

# Verify ISO paths in Packer templates match actual filenames
grep -r "iso_file" packer/templates/
```

#### Issue: Boot command fails / VM doesn't start installation
**Symptoms:**
- VM boots but doesn't proceed with installation
- Packer times out waiting for SSH/WinRM

**Solutions:**
```bash
# Check boot command in Packer template
# Increase boot_wait time
"boot_wait": "30s"

# Monitor VM console in Proxmox web interface during build
# Adjust boot commands based on actual ISO behavior

# For Ubuntu autoinstall, verify user-data syntax
cloud-init schema --config-file packer/templates/ubuntu-22.04/user-data

# For Windows, check Autounattend.xml syntax
# Use Windows System Image Manager to validate
```

### Terraform Issues

#### Issue: Terraform provider authentication fails
**Symptoms:**
```
Error: error creating Proxmox client: authentication failed
```

**Solutions:**
```bash
# Verify terraform.tfvars configuration
cat terraform/terraform.tfvars

# Example correct configuration:
proxmox_api_url      = "https://192.168.1.100:8006/api2/json"
proxmox_user         = "terraform@pve"
proxmox_password     = "your-password"
proxmox_tls_insecure = true
target_node          = "pve"

# Test connection manually
terraform console
# Then run: var.proxmox_api_url
```

#### Issue: Terraform state lock
**Symptoms:**
```
Error: Error acquiring the state lock: resource temporarily unavailable
```

**Solutions:**
```bash
# List state locks
terraform force-unlock -help

# Force unlock (use carefully!)
terraform force-unlock LOCK_ID

# Check for stuck processes
ps aux | grep terraform
kill -9 PID_IF_STUCK
```

#### Issue: Resource already exists
**Symptoms:**
```
Error: resource already exists with ID 101
```

**Solutions:**
```bash
# Import existing resource
terraform import proxmox_vm_qemu.example 101

# Or destroy and recreate
terraform destroy -target=proxmox_vm_qemu.example
terraform apply
```

### Ansible Issues

#### Issue: SSH connection failures
**Symptoms:**
```
UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}
```

**Solutions:**
```bash
# Test SSH connectivity manually
ssh -i ~/.ssh/id_rsa user@target-host

# Check inventory file
cat ansible/inventory/hosts.yml

# Verify SSH keys are deployed
ssh-copy-id user@target-host

# Use ansible ping module
ansible all -i inventory/hosts.yml -m ping -vvv
```

#### Issue: Privilege escalation fails
**Symptoms:**
```
FAILED! => {"msg": "Missing sudo password"}
```

**Solutions:**
```bash
# Configure passwordless sudo on target hosts
echo "user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/user

# Or use become_pass in inventory
# ansible_become_pass: your_sudo_password

# Test become functionality
ansible all -i inventory/hosts.yml -m shell -a "whoami" --become
```

---

## Phase 3: CI/CD Pipeline Issues

### GitHub Actions Problems

#### Issue: Secrets not found
**Symptoms:**
```
Error: Required secret PROXMOX_PASSWORD not found
```

**Solutions:**
1. Go to GitHub repository > Settings > Secrets and variables > Actions
2. Add missing secrets:
   - `PROXMOX_API_URL`
   - `PROXMOX_USERNAME`
   - `PROXMOX_PASSWORD`
   - `PROXMOX_NODE`
   - `PROXMOX_URL`

#### Issue: Workflow not triggering
**Symptoms:**
- Push to main branch doesn't trigger workflow
- Manual workflow dispatch doesn't appear

**Solutions:**
```bash
# Check workflow file syntax
yamllint .github/workflows/iac.yml

# Verify file is in correct location
ls -la .github/workflows/

# Check if Actions are enabled
# Go to repository > Settings > Actions > General
# Ensure "Allow all actions and reusable workflows" is selected
```

#### Issue: Runner out of disk space
**Symptoms:**
```
Error: No space left on device
```

**Solutions:**
```bash
# In workflow, add cleanup step
- name: Free disk space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /opt/ghc
    sudo rm -rf "/usr/local/share/boost"
    sudo rm -rf "$AGENT_TOOLSDIRECTORY"
    sudo apt-get clean
    df -h
```

### GitLab CI/CD Problems

#### Issue: Variables not set
**Symptoms:**
```
Error: variable PROXMOX_URL is not defined
```

**Solutions:**
1. Go to GitLab project > Settings > CI/CD > Variables
2. Add required variables:
   - `PROXMOX_URL`
   - `PROXMOX_USERNAME`
   - `PROXMOX_PASSWORD`
   - `PROXMOX_NODE`
3. Mark sensitive variables as "Masked"

#### Issue: GitLab runner connectivity
**Symptoms:**
- Jobs stay in "pending" state
- No available runners

**Solutions:**
```bash
# Check runner status
sudo gitlab-runner status

# Register new runner
sudo gitlab-runner register
# Follow prompts with project-specific registration token

# Restart runner service
sudo gitlab-runner restart
```

---

## Phase 4: Infrastructure Deployment Issues

### Proxmox-Specific Problems

#### Issue: VM creation fails with storage error
**Symptoms:**
```
Error: storage 'local-zfs' does not exist
```

**Solutions:**
```bash
# Check available storage on Proxmox
pvesm status

# Update Terraform/Packer templates with correct storage name
# Common storage names: local-lvm, local-zfs, local

# In packer templates:
"storage_pool": "local-lvm"

# In terraform modules:
variable "storage" {
  default = "local-lvm"
}
```

#### Issue: Network bridge not found
**Symptoms:**
```
Error: bridge 'vmbr0' does not exist
```

**Solutions:**
```bash
# Check network configuration on Proxmox
cat /etc/network/interfaces

# List available bridges
brctl show

# Update templates with correct bridge name
"network_bridge": "vmbr1"  # or whatever exists
```

#### Issue: Insufficient resources
**Symptoms:**
```
Error: not enough memory/CPU cores available
```

**Solutions:**
```bash
# Check Proxmox node resources
free -h
lscpu

# Reduce VM resource allocation in templates
"memory": "1024"  # Instead of 2048
"cores": "1"      # Instead of 2

# Or add more physical resources to Proxmox host
```

### Template Build Issues

#### Issue: Cloud-init not working
**Symptoms:**
- VMs boot but SSH keys not deployed
- User accounts not created properly

**Solutions:**
```bash
# Check cloud-init logs on target VM
sudo cloud-init status --long
sudo cat /var/log/cloud-init.log

# Verify cloud-init configuration in templates
cat packer/templates/ubuntu-22.04/user-data

# Test cloud-init config syntax
cloud-init schema --config-file user-data
```

#### Issue: Windows template build fails
**Symptoms:**
- WinRM connection timeout
- Autounattend.xml errors

**Solutions:**
```powershell
# Check WinRM configuration
winrm get winrm/config

# Verify firewall rules
Get-NetFirewallRule -DisplayName "*WinRM*"

# Check Autounattend.xml syntax
# Use Windows System Image Manager (WSIM) to validate

# Monitor Windows setup logs
# C:\Windows\Panther\setupact.log
# C:\Windows\Panther\setuperr.log
```

---

## General Debugging Techniques

### Enable Verbose Logging

```bash
# Terraform
export TF_LOG=DEBUG
terraform apply

# Packer
export PACKER_LOG=1
packer build template.json

# Ansible
ansible-playbook -vvv playbook.yml
```

### Network Connectivity Testing

```bash
# Test Proxmox API
curl -k "$PROXMOX_URL/version"

# Test SSH to target hosts
ssh -vvv user@target-host

# Test ports
nc -zv proxmox-ip 8006  # Proxmox web interface
nc -zv proxmox-ip 22    # SSH
```

### Resource Monitoring

```bash
# Monitor system resources
htop
iotop
df -h

# Monitor network
netstat -tulpn
ss -tulpn

# Monitor logs
tail -f /var/log/syslog
journalctl -f
```

---

## Getting Help

### Log Collection
When seeking help, collect these logs:

```bash
# Create debug bundle
mkdir debug-logs
terraform show > debug-logs/terraform-state.txt
terraform plan > debug-logs/terraform-plan.txt 2>&1
ansible-inventory --list > debug-logs/ansible-inventory.json
env | grep -E "(PROXMOX|TF_|ANSIBLE)" > debug-logs/environment.txt

# For Packer issues
PACKER_LOG=1 packer build template.json > debug-logs/packer-build.log 2>&1
```

### Community Resources
- **Proxmox Forum**: https://forum.proxmox.com/
- **Terraform Proxmox Provider**: https://github.com/Telmate/terraform-provider-proxmox
- **Packer Community**: https://www.packer.io/community
- **r/homelab**: Reddit community for home lab enthusiasts

### Professional Support
- **Proxmox Enterprise**: Official Proxmox support
- **HashiCorp Support**: For Terraform/Packer enterprise features
- **Red Hat Support**: For Ansible automation platform

---

## Prevention Tips

### Regular Maintenance
```bash
# Update tools regularly
sudo apt update && sudo apt upgrade
terraform version
packer version
ansible --version

# Clean up old resources
terraform destroy -auto-approve
# Clean up old VM templates in Proxmox
```

### Backup Strategies
```bash
# Backup Terraform state
cp terraform.tfstate terraform.tfstate.backup

# Backup Proxmox configuration
# Use Proxmox backup features for VMs
# Export VM templates regularly
```

### Security Practices
```bash
# Rotate passwords regularly
# Use SSH keys instead of passwords
# Enable 2FA on Proxmox
# Regular security updates
```

---

*This troubleshooting guide will be updated as new issues are discovered and resolved. Contribute your solutions back to help the community!*