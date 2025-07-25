# CI/CD Pipeline Setup Options

This document provides detailed instructions for setting up automated CI/CD pipelines for your Infrastructure as Code home lab.

## Overview

We provide two complete CI/CD solutions:

1. **GitLab CI/CD** - Complete pipeline with GitLab integration
2. **GitHub Actions** - Native GitHub workflow with same functionality

Both pipelines provide identical functionality:
- ✅ Code validation (Terraform, Packer, Ansible)
- ✅ Infrastructure planning and deployment
- ✅ Template building with Packer
- ✅ Configuration management with Ansible
- ✅ Drift detection
- ✅ Environment cleanup

---

## Option 1: GitLab CI/CD Integration

### Features
- **File**: `ci-cd/.gitlab-ci.yml`
- **Status**: ✅ Ready to use
- **Integration**: Works with GitHub repositories via GitLab's GitHub integration

### Setup Steps

#### 1. Create GitLab Project
```bash
# Option A: Import from GitHub
1. Go to GitLab.com
2. Click "New project" > "Import project" > "GitHub"
3. Authenticate with GitHub
4. Select your repository

# Option B: Create new project and push
1. Create new GitLab project
2. Add GitLab as remote:
   git remote add gitlab https://gitlab.com/yourusername/iac_poc.git
3. Push to GitLab:
   git push gitlab main
```

#### 2. Configure Pipeline Variables
In GitLab project settings > CI/CD > Variables, add:

| Variable | Value | Protected | Masked |
|----------|-------|-----------|---------|
| `PROXMOX_URL` | `https://your-proxmox-ip:8006/api2/json` | ✅ | ❌ |
| `PROXMOX_USERNAME` | `terraform@pve` | ✅ | ❌ |
| `PROXMOX_PASSWORD` | `your-secure-password` | ✅ | ✅ |
| `PROXMOX_NODE` | `your-node-name` | ✅ | ❌ |

#### 3. Setup GitLab Runner (Optional)
For better performance, set up a dedicated runner:

```bash
# On a dedicated VM or container
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install gitlab-runner

# Register runner
sudo gitlab-runner register
# Follow prompts with your GitLab project details
```

#### 4. Pipeline Stages
The GitLab pipeline includes these stages:

1. **validate** - Validates all IaC code
2. **plan** - Creates Terraform plans
3. **build** - Builds Packer templates (manual trigger)
4. **deploy** - Deploys infrastructure (manual trigger)
5. **test** - Tests deployed infrastructure

### GitHub Integration Benefits
- ✅ Keep GitHub as primary repository
- ✅ Automatic synchronization
- ✅ GitLab's powerful CI/CD features
- ✅ Free CI/CD minutes on GitLab.com

---

## Option 2: GitHub Actions (Recommended)

### Features
- **File**: `.github/workflows/iac.yml`
- **Status**: ✅ Ready to use
- **Integration**: Native GitHub integration

### Setup Steps

#### 1. Configure Repository Secrets
In GitHub repository > Settings > Secrets and variables > Actions:

| Secret Name | Value |
|-------------|--------|
| `PROXMOX_API_URL` | `https://your-proxmox-ip:8006/api2/json` |
| `PROXMOX_USERNAME` | `terraform@pve` |
| `PROXMOX_PASSWORD` | `your-secure-password` |
| `PROXMOX_NODE` | `your-node-name` |
| `PROXMOX_URL` | `https://your-proxmox-ip:8006/api2/json` |

#### 2. Enable GitHub Actions
1. Go to repository > Actions tab
2. Enable workflows if prompted
3. The workflow will appear automatically

#### 3. Workflow Triggers

**Automatic Triggers:**
- **Push to main** - Runs validation and planning
- **Pull Request** - Runs validation and planning

**Manual Triggers (workflow_dispatch):**
- `plan` - Generate Terraform plans
- `build-templates` - Build Packer templates
- `deploy-k8s` - Deploy Kubernetes cluster
- `deploy-windows` - Deploy Windows domain
- `destroy-k8s` - Destroy Kubernetes cluster
- `destroy-windows` - Destroy Windows domain

#### 4. Running Manual Actions
1. Go to Actions tab
2. Select "Infrastructure as Code Pipeline"
3. Click "Run workflow"
4. Choose your action from dropdown
5. Click "Run workflow"

### GitHub Actions Benefits
- ✅ Native integration with GitHub
- ✅ No external dependencies
- ✅ Generous free tier (2000 minutes/month)
- ✅ Excellent workflow visualization
- ✅ Environment protection rules

---

## Comparison Matrix

| Feature | GitLab CI/CD | GitHub Actions |
|---------|-------------|----------------|
| **Setup Complexity** | Medium | Easy |
| **Integration** | External service | Native |
| **Free Minutes** | 400/month | 2000/month |
| **Runner Options** | Self-hosted + SaaS | Self-hosted + SaaS |
| **Environment Protection** | ✅ | ✅ |
| **Artifact Storage** | ✅ | ✅ |
| **Matrix Builds** | ✅ | ✅ |
| **Secrets Management** | ✅ | ✅ |
| **Manual Triggers** | ✅ | ✅ |
| **Scheduled Runs** | ✅ | ✅ |

---

## Recommended Setup: GitHub Actions

For most users, **GitHub Actions is recommended** because:

1. **Simplicity** - No external service setup required
2. **Integration** - Native GitHub integration
3. **Generosity** - More free CI/CD minutes
4. **Visibility** - Better integration with PRs and issues

### Quick Start with GitHub Actions

1. **Configure Secrets** (5 minutes)
   ```bash
   # Add the 5 Proxmox secrets mentioned above
   ```

2. **Test the Pipeline** (2 minutes)
   ```bash
   # Push any change to trigger validation
   git commit -m "test pipeline" --allow-empty
   git push origin main
   ```

3. **Build Templates** (20-60 minutes)
   ```bash
   # Go to Actions > Run workflow > Select "build-templates"
   ```

4. **Deploy Infrastructure** (5-10 minutes)
   ```bash
   # Go to Actions > Run workflow > Select "deploy-k8s" or "deploy-windows"
   ```

---

## Advanced Configuration

### Environment Protection Rules

#### GitHub
1. Go to Settings > Environments
2. Add environment (e.g., "k8s-cluster")
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Environment secrets

#### GitLab
1. Go to Operations > Environments
2. Create environment
3. Set deployment restrictions

### Self-Hosted Runners

#### GitHub Actions Runner
```bash
# On your build machine
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
./config.sh --url https://github.com/yourusername/iac_poc --token YOUR_TOKEN
./run.sh
```

#### GitLab Runner
```bash
# On your build machine
sudo gitlab-runner register
# Follow the prompts
```

---

## Security Best Practices

### Secrets Management
- ✅ Never commit secrets to code
- ✅ Use repository/project secrets
- ✅ Rotate passwords regularly
- ✅ Use least-privilege API users

### Network Security
- ✅ Restrict Proxmox API access by IP
- ✅ Use VPN for remote access
- ✅ Enable firewall rules
- ✅ Regular security updates

### Pipeline Security
- ✅ Environment protection rules
- ✅ Manual approval for deployments
- ✅ Artifact signing (advanced)
- ✅ Runner security hardening

---

## Troubleshooting

### Common Issues

**Authentication Failures:**
```bash
# Check Proxmox API access
curl -k -d "username=terraform@pve&password=yourpass" \
     https://your-proxmox:8006/api2/json/access/ticket
```

**Template Build Failures:**
```bash
# Enable Packer debug logging
export PACKER_LOG=1
packer build template.json
```

**Terraform State Issues:**
```bash
# Clear state lock (if stuck)
terraform force-unlock LOCK_ID
```

### Pipeline Debugging

**GitHub Actions:**
- Check workflow logs in Actions tab
- Enable debug logging: Set `ACTIONS_RUNNER_DEBUG=true`
- Use `actions/upload-artifact` for debugging files

**GitLab CI/CD:**
- Check job logs in CI/CD > Pipelines
- Enable debug logging: Set `CI_DEBUG_TRACE=true`
- Use `artifacts` to save debugging files

---

*Choose the option that best fits your workflow and proceed with the setup. Both solutions provide enterprise-grade automation for your home lab infrastructure.*