# Windows Server 2022 Setup Script for Packer
# Based on VirtualizationHowTo article

Write-Host "Starting Windows Server 2022 setup..."

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Configure WinRM for Packer communication
Write-Host "Configuring WinRM..."
winrm quickconfig -quiet
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Start WinRM service
Start-Service -Name WinRM
Set-Service -Name WinRM -StartupType Automatic

# Configure firewall for WinRM
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Install VirtIO drivers
Write-Host "Installing VirtIO drivers..."
$virtioPath = "E:\guest-agent\qemu-ga-x86_64.msi"
if (Test-Path $virtioPath) {
    Start-Process -FilePath msiexec.exe -ArgumentList "/i", $virtioPath, "/quiet", "/norestart" -Wait
    Write-Host "VirtIO guest agent installed"
} else {
    Write-Host "VirtIO installer not found at $virtioPath"
}

# Disable Windows Defender real-time protection for faster builds
Write-Host "Disabling Windows Defender real-time protection..."
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable automatic updates during build
Write-Host "Disabling automatic updates..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

# Set network profile to private
Write-Host "Setting network profile to private..."
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Write-Host "Windows Server 2022 setup complete"
Write-Host "System ready for Packer provisioning"