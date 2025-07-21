# Packer Templates

This directory contains Packer templates for creating golden images in Proxmox, based on the [VirtualizationHowTo article](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/).

## Available Templates

### 1. Debian 12 (`templates/debian-12/`)
- **Template Name**: `debian-12-template`
- **VM ID**: 9000
- **Features**: QEMU Guest Agent, Cloud-init, SSH server
- **Use Case**: Lightweight Linux containers and VMs

### 2. Ubuntu 22.04 LTS (`templates/ubuntu-22.04/`)
- **Template Name**: `ubuntu-22.04-template`
- **VM ID**: 9001
- **Features**: QEMU Guest Agent, Cloud-init, Docker pre-installed
- **Use Case**: Kubernetes nodes, containerized applications

### 3. Windows Server 2022 (`templates/windows-server-2022/`)
- **Template Name**: `windows-server-2022-template`
- **VM ID**: 9002
- **Features**: RSAT tools, Remote Desktop enabled
- **Use Case**: Active Directory, Windows services

## Prerequisites

### Software Requirements
- Packer installed on your build machine
- Access to Proxmox VE server
- ISO files uploaded to Proxmox storage

### Required ISOs
Upload these ISOs to your Proxmox `local` storage:
- `debian-12.2.0-amd64-netinst.iso`
- `ubuntu-22.04.3-live-server-amd64.iso`
- `windows-server-2022.iso`
- `virtio-win.iso` (for Windows VMs)

### Environment Variables
Set these environment variables before building:

```bash
export PROXMOX_URL="https://proxmox.local:8006/api2/json"
export PROXMOX_USERNAME="packer@pve"
export PROXMOX_PASSWORD="your-secure-password"
export PROXMOX_NODE="pve"
```

## Building Templates

### Build All Templates
```bash
# From the project root
./build-all-templates.sh
```

### Build Individual Templates

**Debian 12:**
```bash
cd packer/templates/debian-12
packer build debian.json
```

**Ubuntu 22.04:**
```bash
cd packer/templates/ubuntu-22.04
packer build ubuntu.json
```

**Windows Server 2022:**
```bash
cd packer/templates/windows-server-2022
packer build windows.json
```

## Validation

Validate templates before building:

```bash
packer validate debian.json
packer validate ubuntu.json
packer validate windows.json
```

## Customization

### Modifying Templates
- Edit the JSON files to change VM specifications
- Modify provisioning scripts in the `scripts/` directory
- Add additional software installations in the provisioners section

### Creating New Templates
1. Copy an existing template directory
2. Modify the JSON configuration
3. Update the provisioning scripts
4. Test thoroughly before use

## Best Practices

1. **Version Control**: Always commit template changes to git
2. **Testing**: Test templates in a non-production environment first
3. **Security**: Never hardcode passwords in templates
4. **Documentation**: Update this README when adding new templates
5. **Cleanup**: Templates include cleanup scripts to reduce image size

## Troubleshooting

### Common Issues

**Build Fails with Authentication Error:**
- Verify environment variables are set correctly
- Check Proxmox user permissions
- Ensure API access is enabled

**ISO Not Found:**
- Verify ISO files are uploaded to Proxmox storage
- Check the `iso_file` path in the template

**Boot Command Issues:**
- Increase `boot_wait` time
- Verify boot command sequence for your ISO version
- Check console output in Proxmox web interface

**WinRM Connection Failed (Windows):**
- Verify Windows firewall rules
- Check WinRM service status
- Ensure VirtIO drivers are loading correctly

## Credits

Based on Infrastructure as Code patterns from [VirtualizationHowTo](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)
