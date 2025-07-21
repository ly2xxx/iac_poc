# PowerShell script to setup Windows 11 development environment
# Based on VirtualizationHowTo article requirements

[CmdletBinding()]
param(
    [switch]$SkipHyperV,
    [switch]$SkipWSL,
    [switch]$SkipWinget
)

Write-Host "Setting up Windows 11 development environment for IaC..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Exiting..."
    exit 1
}

# Enable Windows Features
if (-not $SkipHyperV) {
    Write-Host "Enabling Hyper-V..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
}

if (-not $SkipWSL) {
    Write-Host "Enabling WSL2..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
}

# Install applications using winget
if (-not $SkipWinget) {
    Write-Host "Installing development tools..." -ForegroundColor Yellow
    
    $apps = @(
        "Git.Git",
        "Microsoft.VisualStudioCode",
        "Docker.DockerDesktop",
        "Microsoft.WindowsTerminal",
        "JanDeDobbeleer.OhMyPosh",
        "7zip.7zip"
    )
    
    foreach ($app in $apps) {
        Write-Host "Installing $app..." -ForegroundColor Cyan
        try {
            winget install --id $app --silent --accept-package-agreements --accept-source-agreements
            Write-Host "✓ $app installed successfully" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to install $app: $_"
        }
    }
}

# Configure Windows Terminal
Write-Host "Configuring Windows Terminal..." -ForegroundColor Yellow
$terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettingsPath) {
    Write-Host "✓ Windows Terminal settings found" -ForegroundColor Green
} else {
    Write-Warning "Windows Terminal settings not found. Install Windows Terminal first."
}

# Create development directories
Write-Host "Creating development directories..." -ForegroundColor Yellow
$devPath = "$env:USERPROFILE\dev"
if (-not (Test-Path $devPath)) {
    New-Item -ItemType Directory -Path $devPath -Force
    Write-Host "✓ Created $devPath" -ForegroundColor Green
}

# Configure Git (basic)
Write-Host "Configuring Git..." -ForegroundColor Yellow
try {
    $gitUser = Read-Host "Enter your Git username"
    $gitEmail = Read-Host "Enter your Git email"
    
    if ($gitUser -and $gitEmail) {
        git config --global user.name "$gitUser"
        git config --global user.email "$gitEmail"
        git config --global init.defaultBranch main
        Write-Host "✓ Git configured successfully" -ForegroundColor Green
    }
} catch {
    Write-Warning "Git not found or configuration failed"
}

Write-Host "`n" -ForegroundColor Green
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your computer to enable Hyper-V and WSL2" -ForegroundColor White
Write-Host "2. Install Ubuntu 22.04 in WSL2: wsl --install -d Ubuntu-22.04" -ForegroundColor White
Write-Host "3. Configure your Proxmox environment" -ForegroundColor White
Write-Host "4. Clone the IaC repository: git clone https://github.com/ly2xxx/iac_poc.git" -ForegroundColor White
Write-Host "`nRestart required: $(if ($SkipHyperV -and $SkipWSL) { 'No' } else { 'Yes' })" -ForegroundColor $(if ($SkipHyperV -and $SkipWSL) { 'Green' } else { 'Red' })
