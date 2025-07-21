# Contributing to IaC Home Lab Project

Thank you for your interest in contributing to this Infrastructure as Code home lab project! This project is based on the excellent work from [VirtualizationHowTo](https://www.virtualizationhowto.com/2025/07/run-your-home-lab-with-infrastructure-as-code-like-a-boss/).

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/iac_poc.git
   cd iac_poc
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Windows 11 with WSL2 or Linux environment
- Proxmox VE server (for testing)
- Git
- Code editor (VS Code recommended)

### Install Development Tools

```bash
# In WSL2 or Linux
sudo apt update
sudo apt install -y terraform packer ansible

# Install additional tools
pip3 install ansible-lint yamllint
```

### Environment Setup

1. **Copy environment template**:
   ```bash
   cp ~/.iac_env_template ~/.iac_env
   ```

2. **Configure your test environment**:
   ```bash
   # Edit ~/.iac_env with your Proxmox details
   source ~/.iac_env
   ```

## Contributing Guidelines

### Types of Contributions

- **Bug fixes**: Fix issues in existing code
- **New features**: Add new IaC modules or capabilities
- **Documentation**: Improve guides, examples, or code comments
- **Templates**: Add new Packer templates or Ansible roles
- **CI/CD**: Enhance automation pipelines

### Before You Start

1. **Check existing issues**: Look for related issues or feature requests
2. **Create an issue**: If none exists, create one to discuss your proposal
3. **Get feedback**: Wait for maintainer feedback before starting large changes

## Code Standards

### Terraform

- **Formatting**: Use `terraform fmt` to format code
- **Validation**: Ensure `terraform validate` passes
- **Variables**: Include descriptions and types for all variables
- **Outputs**: Provide meaningful outputs with descriptions
- **Modules**: Keep modules focused and reusable

```hcl
# Good variable definition
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}
```

### Packer

- **Validation**: Use `packer validate` before submitting
- **Variables**: Use variables instead of hardcoded values
- **Provisioning**: Keep provisioning scripts modular
- **Cleanup**: Include proper cleanup procedures

```json
{
  "variables": {
    "vm_name": "{{env `VM_NAME`}}",
    "proxmox_url": "{{env `PROXMOX_URL`}}"
  }
}
```

### Ansible

- **Linting**: Use `ansible-lint` to check playbooks
- **Idempotency**: Ensure tasks are idempotent
- **Variables**: Use group_vars and host_vars appropriately
- **Handlers**: Use handlers for service restarts
- **Documentation**: Document role variables and usage

```yaml
# Good task structure
- name: Install package
  package:
    name: "{{ package_name }}"
    state: present
  notify: restart service
  tags: [packages]
```

### General

- **Comments**: Add comments for complex logic
- **Naming**: Use descriptive, consistent naming
- **Secrets**: Never commit secrets or passwords
- **Documentation**: Update relevant documentation

## Testing

### Local Testing

1. **Terraform**:
   ```bash
   cd terraform/
   terraform fmt -check
   terraform validate
   terraform plan
   ```

2. **Packer**:
   ```bash
   cd packer/templates/debian-12/
   packer validate debian.json
   ```

3. **Ansible**:
   ```bash
   cd ansible/
   ansible-lint playbooks/
   ansible-playbook --syntax-check playbooks/site.yml
   ```

### Integration Testing

- Test in a dedicated Proxmox environment
- Verify all templates build successfully
- Ensure Terraform deployments work end-to-end
- Test Ansible configurations on real VMs

### Documentation Testing

- Follow setup guides step-by-step
- Verify all commands work as documented
- Test on fresh Windows 11 installation

## Submitting Changes

### Pull Request Process

1. **Update documentation**: Update README.md and relevant docs
2. **Add examples**: Include usage examples if applicable
3. **Test thoroughly**: Ensure all tests pass
4. **Follow conventions**: Adhere to coding standards
5. **Write clear commits**: Use descriptive commit messages

### Commit Message Format

```
type(scope): brief description

Longer description if needed

Fixes #issue-number
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `ci`: CI/CD changes

Examples:
```
feat(terraform): add support for multiple storage pools
fix(packer): resolve Ubuntu template boot issues
docs(setup): improve Windows 11 setup instructions
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] Local testing completed
- [ ] Integration testing on Proxmox
- [ ] Documentation verified

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## Code Review Process

1. **Automated checks**: All CI/CD checks must pass
2. **Peer review**: At least one maintainer review required
3. **Testing**: Changes tested in lab environment
4. **Documentation**: Relevant docs updated
5. **Approval**: Maintainer approval before merge

## Community Guidelines

### Be Respectful

- Use welcoming and inclusive language
- Respect different viewpoints and experiences
- Accept constructive feedback gracefully
- Focus on what's best for the community

### Be Collaborative

- Help newcomers get started
- Share knowledge and experience
- Provide constructive feedback
- Credit others for their contributions

### Be Professional

- Keep discussions focused and on-topic
- Use appropriate language
- Respect project maintainers' decisions
- Follow the code of conduct

## Getting Help

### Resources

- **Issues**: Check existing issues for solutions
- **Discussions**: Use GitHub discussions for questions
- **Documentation**: Read the comprehensive docs
- **Examples**: Check the examples directory

### Support Channels

- GitHub Issues (bugs, feature requests)
- GitHub Discussions (questions, ideas)
- VirtualizationHowTo community

### Maintainers

Project maintainers will:
- Review pull requests promptly
- Provide constructive feedback
- Help with technical questions
- Maintain project direction

## Recognition

### Contributors

All contributors will be:
- Listed in the project README
- Credited in release notes
- Thanked in commit messages
- Recognized in project documentation

### Special Recognition

- **First-time contributors**: Welcome package and guidance
- **Significant contributions**: Special mention in releases
- **Long-term contributors**: Potential maintainer invitation

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.

---

**Thank you for contributing to making home lab Infrastructure as Code accessible to everyone!**

*This project builds upon the excellent work from [VirtualizationHowTo](https://www.virtualizationhowto.com/). Please check out their original article for additional insights and best practices.*
