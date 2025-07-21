#!/bin/bash
# Build all Packer templates
# Based on VirtualizationHowTo article automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building all Packer templates...${NC}"

# Check if environment variables are set
required_vars=("PROXMOX_URL" "PROXMOX_USERNAME" "PROXMOX_PASSWORD" "PROXMOX_NODE")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}Error: $var environment variable is not set${NC}"
        exit 1
    fi
done

# Function to build template
build_template() {
    local template_dir=$1
    local template_file=$2
    local template_name=$3
    
    echo -e "${YELLOW}Building $template_name template...${NC}"
    
    cd "packer/templates/$template_dir"
    
    if packer validate "$template_file"; then
        echo -e "${GREEN}✓ $template_name template validation passed${NC}"
        
        if packer build \
            -var "proxmox_url=$PROXMOX_URL" \
            -var "proxmox_username=$PROXMOX_USERNAME" \
            -var "proxmox_password=$PROXMOX_PASSWORD" \
            -var "proxmox_node=$PROXMOX_NODE" \
            "$template_file"; then
            echo -e "${GREEN}✓ $template_name template built successfully${NC}"
        else
            echo -e "${RED}✗ Failed to build $template_name template${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ $template_name template validation failed${NC}"
        return 1
    fi
    
    cd - > /dev/null
}

# Build templates
echo -e "${YELLOW}Starting template builds...${NC}"

# Debian 12
build_template "debian-12" "debian.json" "Debian 12"

# Ubuntu 22.04
build_template "ubuntu-22.04" "ubuntu.json" "Ubuntu 22.04"

# Windows Server 2022 (optional, can be commented out)
# build_template "windows-server-2022" "windows.json" "Windows Server 2022"

echo -e "${GREEN}All templates built successfully!${NC}"
echo -e "${YELLOW}Templates are now ready for use with Terraform${NC}"
