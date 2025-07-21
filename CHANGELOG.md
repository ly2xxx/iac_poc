# Changelog

All notable changes to the Infrastructure as Code Home Lab project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-21

### Added

#### Core Infrastructure
- **Terraform Provider Configuration** for Proxmox VE
- **Modular Terraform Structure** with networking, compute, and storage modules
- **Environment Templates** for Kubernetes cluster and Windows domain deployments
- **Variable Management** with examples and validation

#### Golden Image Creation
- **Packer Templates** for:
  - Debian 12 with QEMU Guest Agent and Cloud-init
  - Ubuntu 22.04 LTS with Docker pre-installed
  - Windows Server 2022 with RSAT tools
- **Automated Build Scripts** for template creation
- **Cleanup Scripts** for optimized image size

#### Configuration Management
- **Ansible Playbooks** for automated configuration
- **Security Roles** with UFW firewall and Fail2ban
- **Monitoring Setup** with Prometheus Node Exporter
- **Docker Installation** and configuration
- **Common System Configuration** (NTP, users, SSH)

#### CI/CD Pipeline
- **GitLab CI/CD Configuration** with:
  - Validation stage for all IaC components
  - Automated planning and building
  - Manual deployment controls
  - Drift detection
  - Testing automation

#### Windows 11 Support
- **PowerShell Setup Script** for development environment
- **WSL2 Configuration** with all required tools
- **Comprehensive Setup Guide** with step-by-step instructions
- **Troubleshooting Documentation** for common issues

#### Documentation
- **Complete README** with Windows 11 setup instructions
- **Usage Examples** for common scenarios
- **Troubleshooting Guide** with solutions
- **Contributing Guidelines** for community involvement
- **Architecture Documentation** explaining design decisions

#### Scripts and Automation
- **Build Scripts** for automated template creation
- **Environment Setup** for Windows and Linux
- **Configuration Templates** for all components
- **Example Configurations** for various use cases

### Features

#### Infrastructure Capabilities
- Support for multiple VM types (Linux and Windows)
- Network isolation with VLAN support
- Storage management with different performance tiers
- Scalable compute resources with configurable specifications
- Template-based VM deployment for consistency

#### Security Features
- API key management for Proxmox authentication
- Firewall configuration with UFW
- Fail2ban intrusion prevention
- SSH key management and passwordless authentication
- Secrets handling in CI/CD pipelines

#### Monitoring and Observability
- Prometheus Node Exporter on all systems
- System health monitoring
- Resource utilization tracking
- Automated testing and validation

#### Developer Experience
- One-command environment setup
- Integrated development tools
- Comprehensive documentation
- Example configurations for common scenarios
- Automated validation and testing

### Architecture

#### Design Principles
- **Modularity**: Reusable components for different environments
- **Scalability**: Easy to expand and modify for growing needs
- **Security**: Best practices implemented by default
- **Documentation**: Code serves as documentation
- **Automation**: Everything automated through code

#### Technology Stack
- **Terraform**: Infrastructure provisioning
- **Packer**: Golden image creation
- **Ansible**: Configuration management
- **Proxmox VE**: Virtualization platform
- **GitLab CI/CD**: Automation pipeline
- **Windows 11 + WSL2**: Development environment

#### Project Structure
```
iac_poc/
├── terraform/           # Infrastructure definitions
│   ├── modules/         # Reusable modules
│   └── environments/    # Environment-specific configs
├── packer/             # Golden image templates
│   ├── templates/      # VM templates
│   └── scripts/        # Build scripts
├── ansible/            # Configuration management
│   ├── playbooks/      # Automation playbooks
│   ├── roles/          # Reusable roles
│   └── inventory/      # Host definitions
├── ci-cd/              # Pipeline definitions
├── scripts/            # Setup and utility scripts
└── docs/              # Documentation
```

### Credits

This project is based on the excellent article by VirtualizationHowTo:
- **Article**: [Run Your Home Lab with Infrastructure as Code Like a Boss](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/)
- **Author**: VirtualizationHowTo Team
- **Inspiration**: All core concepts and best practices

### Compatibility

- **Windows 11**: Full support with WSL2
- **Proxmox VE**: Version 7.0+
- **Terraform**: Version 1.0+
- **Packer**: Version 1.8+
- **Ansible**: Version 2.9+

### Known Issues

- Windows template builds may require manual VirtIO driver installation
- Large Packer builds can consume significant bandwidth
- Initial setup requires manual Proxmox user creation

### Future Enhancements

Planned for future releases:
- Additional template support (CentOS, Rocky Linux)
- Kubernetes deployment automation
- Advanced monitoring with Grafana
- Backup and disaster recovery automation
- Multi-node Proxmox cluster support

---

**Note**: This changelog will be updated with each release. For detailed commit history, see the Git log.
