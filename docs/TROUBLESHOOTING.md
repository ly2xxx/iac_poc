# Troubleshooting Guide

This guide helps resolve common issues when setting up and running the Infrastructure as Code home lab based on the [VirtualizationHowTo article](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/).

## Table of Contents

- [Windows 11 Setup Issues](#windows-11-setup-issues)
- [Proxmox Configuration](#proxmox-configuration)
- [Terraform Issues](#terraform-issues)
- [Packer Build Problems](#packer-build-problems)
- [Ansible Connection Issues](#ansible-connection-issues)
- [Network and Connectivity](#network-and-connectivity)
- [Performance Optimization](#performance-optimization)

## Windows 11 Setup Issues

### Hyper-V Not Available

**Problem**: Error when enabling Hyper-V features

**Solutions**:
1. Ensure you have Windows 11 Pro (Home doesn't support Hyper-V)
2. Check BIOS settings for virtualization support
3. Verify CPU supports hardware virtualization

```powershell
# Check Hyper-V requirements
systeminfo | findstr /i "hyper-v"

# Enable from PowerShell (Run as Administrator)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

### WSL2 Installation Issues

**Problem**: WSL2 fails to install or start

**Solutions**:
1. Update Windows to latest version
2. Enable required Windows features
3. Install WSL2 kernel update

```powershell
# Check WSL version
wsl --list --verbose

# Update WSL
wsl --update

# Set default version
wsl --set-default-version 2
```

### Docker Desktop Issues

**Problem**: Docker Desktop won't start or connect to WSL2

**Solutions**:
1. Ensure WSL2 is properly configured
2. Check Docker Desktop WSL2 integration settings
3. Restart Docker Desktop service

```powershell
# Restart Docker Desktop
Restart-Service -Name "Docker Desktop Service"

# Check Docker status in WSL2
docker --version
docker run hello-world
```

## Proxmox Configuration

### API Access Issues

**Problem**: Cannot connect to Proxmox API

**Solutions**:
1. Verify Proxmox web interface is accessible
2. Check firewall settings
3. Ensure API user has correct permissions

```bash
# Test API connectivity
curl -k https://your-proxmox-ip:8006/api2/json/version

# Test authentication
curl -k -d "username=terraform@pve&password=yourpassword" \
  https://your-proxmox-ip:8006/api2/json/access/ticket
```

### User Permissions

**Problem**: API user lacks sufficient permissions

**Solution**: Create proper user and assign roles

```bash
# On Proxmox host
pveum user add terraform@pve
pveum passwd terraform@pve
pveum acl modify / -user terraform@pve -role Administrator

# For Packer
pveum user add packer@pve
pveum passwd packer@pve
pveum acl modify / -user packer@pve -role Administrator
```

### Storage Issues

**Problem**: Templates fail to create due to storage problems

**Solutions**:
1. Check available storage space
2. Verify storage pool configuration
3. Ensure correct permissions on storage

```bash
# Check storage on Proxmox
pvesm status
df -h

# List storage pools
pvesm list local
```

## Terraform Issues

### Provider Authentication

**Problem**: Terraform provider fails to authenticate

**Solutions**:
1. Verify credentials in `terraform.tfvars`
2. Check API URL format
3. Test manual API connection

```bash
# Debug Terraform provider
export TF_LOG=DEBUG
terraform plan

# Validate configuration
terraform validate

# Check provider version
terraform providers
```

### State File Issues

**Problem**: Terraform state becomes corrupted or locked

**Solutions**:
1. Force unlock if safe
2. Backup and restore state
3. Import existing resources

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Backup state
cp terraform.tfstate terraform.tfstate.backup

# Import existing resource
terraform import proxmox_vm_qemu.vm 100
```

### Resource Creation Failures

**Problem**: VMs fail to create or clone

**Solutions**:
1. Verify template exists
2. Check resource limits
3. Ensure proper network configuration

```bash
# List available templates
qm list | grep template

# Check VM configuration
qm config VM_ID

# Monitor logs
tail -f /var/log/pveproxy/access.log
```

## Packer Build Problems

### ISO File Issues

**Problem**: Packer cannot find ISO files

**Solutions**:
1. Verify ISO is uploaded to Proxmox
2. Check file path in template
3. Ensure proper permissions

```bash
# List ISOs on Proxmox
ls -la /var/lib/vz/template/iso/

# Upload ISO via web interface or:
scp your-iso.iso root@proxmox:/var/lib/vz/template/iso/
```

### Boot Command Issues

**Problem**: VM doesn't boot properly or hangs

**Solutions**:
1. Increase boot_wait time
2. Verify boot command sequence
3. Check console output in Proxmox

```json
{
  "boot_wait": "30s",
  "boot_command": [
    "<esc><wait10>",
    "..."
  ]
}
```

### SSH/WinRM Connection Failures

**Problem**: Packer cannot connect to VM

**Solutions**:
1. Verify network configuration
2. Check SSH/WinRM service status
3. Increase timeout values

```bash
# Test SSH connectivity
ssh -o ConnectTimeout=10 user@vm-ip

# For Windows, test WinRM
Test-NetConnection -ComputerName vm-ip -Port 5985
```

## Ansible Connection Issues

### SSH Key Authentication

**Problem**: Ansible cannot connect to hosts

**Solutions**:
1. Copy SSH keys to target hosts
2. Verify SSH agent is running
3. Check inventory configuration

```bash
# Copy SSH key
ssh-copy-id user@target-host

# Test Ansible connectivity
ansible all -i inventory/hosts.yml -m ping

# Debug connection
ansible all -i inventory/hosts.yml -m ping -vvv
```

### Privilege Escalation

**Problem**: Sudo/become operations fail

**Solutions**:
1. Configure passwordless sudo
2. Use proper become method
3. Check user permissions

```bash
# Configure passwordless sudo
echo "username ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/username

# Test become
ansible all -i inventory -b -m shell -a "whoami"
```

### Windows Host Issues

**Problem**: Cannot connect to Windows hosts

**Solutions**:
1. Configure WinRM properly
2. Set up certificate authentication
3. Check firewall rules

```powershell
# Configure WinRM on Windows host
winrm quickconfig
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

## Network and Connectivity

### VLAN Configuration

**Problem**: VMs cannot communicate across VLANs

**Solutions**:
1. Configure VLAN-aware bridge
2. Set up proper routing
3. Check switch configuration

```bash
# Configure VLAN on Proxmox bridge
auto vmbr0.100
iface vmbr0.100 inet static
    address 10.1.0.1/24
    vlan-raw-device vmbr0
```

### DNS Resolution

**Problem**: Hostname resolution fails

**Solutions**:
1. Configure proper DNS servers
2. Set up local DNS or hosts file
3. Check network configuration

```bash
# Test DNS resolution
nslookup hostname
dig hostname

# Check DNS configuration
cat /etc/resolv.conf
```

## Performance Optimization

### Slow VM Performance

**Solutions**:
1. Enable VirtIO drivers
2. Increase memory allocation
3. Use faster storage
4. Enable CPU host passthrough

```bash
# Check VirtIO usage
lspci | grep -i virtio

# Monitor performance
htop
iotop
```

### Storage Performance

**Solutions**:
1. Use ZFS with compression
2. Enable SSD optimizations
3. Configure proper cache settings

```bash
# Enable ZFS compression
zfs set compression=lz4 pool/dataset

# Check SSD optimization
cat /sys/block/sda/queue/rotational
```

### Network Performance

**Solutions**:
1. Use VirtIO network adapters
2. Enable jumbo frames if supported
3. Configure proper queue settings

```bash
# Check network adapter type
ethtool -i eth0

# Test network performance
iperf3 -c target-host
```

## Getting Help

### Log Locations

- **Proxmox**: `/var/log/pve*`, `/var/log/qemu-server/`
- **Terraform**: Set `TF_LOG=DEBUG`
- **Packer**: Set `PACKER_LOG=1`
- **Ansible**: Use `-vvv` flag

### Useful Commands

```bash
# Check system resources
free -h
df -h
lscpu

# Monitor processes
ps aux | grep -E "(terraform|packer|ansible)"

# Check network connectivity
ping 8.8.8.8
traceroute target-host
netstat -tlnp
```

### Community Resources

- [VirtualizationHowTo Community](https://www.virtualizationhowto.com/)
- [Proxmox Forum](https://forum.proxmox.com/)
- [Terraform Documentation](https://terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Remember**: Always test changes in a safe environment before applying to production!
