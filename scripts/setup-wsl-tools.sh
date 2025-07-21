#!/bin/bash
# Setup script for WSL2 Ubuntu environment
# Based on VirtualizationHowTo article requirements

set -e

echo "🚀 Setting up WSL2 Ubuntu environment for IaC development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Update system
print_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_status "System updated"

# Install essential tools
print_info "Installing essential tools..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    unzip \
    jq \
    tree \
    htop \
    net-tools \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
print_status "Essential tools installed"

# Install Terraform
print_info "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
print_status "Terraform $(terraform version | head -n1 | cut -d' ' -f2) installed"

# Install Packer
print_info "Installing Packer..."
sudo apt install -y packer
print_status "Packer $(packer version) installed"

# Install Ansible
print_info "Installing Ansible..."
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
print_status "Ansible $(ansible --version | head -n1 | cut -d' ' -f3) installed"

# Install Python packages
print_info "Installing Python packages..."
sudo apt install -y python3-pip
pip3 install --user \
    ansible-lint \
    yamllint \
    jmespath \
    netaddr \
    requests
print_status "Python packages installed"

# Install Docker (optional)
read -p "Install Docker in WSL2? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    print_status "Docker installed (logout/login required for group membership)"
fi

# Setup development directory
print_info "Setting up development environment..."
mkdir -p ~/dev
cd ~/dev

# Configure Git
if ! git config --global user.name > /dev/null 2>&1; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    print_status "Git configured"
else
    print_status "Git already configured"
fi

# Create useful aliases
print_info "Setting up shell aliases..."
cat >> ~/.bashrc << 'EOF'

# IaC Development Aliases
alias tf='terraform'
alias tfa='terraform apply'
alias tfp='terraform plan'
alias tfi='terraform init'
alias tfd='terraform destroy'

alias pk='packer'
alias pkv='packer validate'
alias pkb='packer build'

alias ap='ansible-playbook'
alias av='ansible-vault'
alias ag='ansible-galaxy'

# Directory shortcuts
alias cddev='cd ~/dev'
alias cdiac='cd ~/dev/iac_poc'

# Useful functions
tfclean() {
    rm -rf .terraform/
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f *.tfplan
    echo "Terraform directory cleaned"
}

EOF

print_status "Shell aliases added to ~/.bashrc"

# Create SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    print_info "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    print_status "SSH key generated"
    print_warning "Add this public key to your Git provider:"
    cat ~/.ssh/id_ed25519.pub
else
    print_status "SSH key already exists"
fi

# Download and setup the IaC project
read -p "Clone the IaC project repository? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -d "~/dev/iac_poc" ]; then
        print_info "Cloning IaC project..."
        git clone https://github.com/ly2xxx/iac_poc.git ~/dev/iac_poc
        cd ~/dev/iac_poc
        print_status "IaC project cloned to ~/dev/iac_poc"
    else
        print_warning "IaC project directory already exists"
    fi
fi

print_info "Creating environment variables template..."
cat > ~/.iac_env_template << 'EOF'
# IaC Environment Variables Template
# Copy to ~/.iac_env and fill in your values
# Source with: source ~/.iac_env

export PROXMOX_URL="https://your-proxmox-ip:8006/api2/json"
export PROXMOX_USERNAME="terraform@pve"
export PROXMOX_PASSWORD="your-secure-password"
export PROXMOX_NODE="your-node-name"

# Terraform variables
export TF_VAR_proxmox_api_url="$PROXMOX_URL"
export TF_VAR_proxmox_user="$PROXMOX_USERNAME"
export TF_VAR_proxmox_password="$PROXMOX_PASSWORD"
export TF_VAR_target_node="$PROXMOX_NODE"
EOF

print_status "Environment template created at ~/.iac_env_template"

echo
print_status "WSL2 setup complete!"
echo
print_info "Next steps:"
echo "1. Copy ~/.iac_env_template to ~/.iac_env and configure your Proxmox settings"
echo "2. Source the environment: source ~/.iac_env"
echo "3. Navigate to the project: cd ~/dev/iac_poc"
echo "4. Follow the README.md for detailed setup instructions"
echo
print_warning "Restart your terminal or run 'source ~/.bashrc' to load aliases"
if grep -q docker /etc/group && groups | grep -q docker; then
    echo
else
    print_warning "If you installed Docker, logout and login again for group membership"
fi
