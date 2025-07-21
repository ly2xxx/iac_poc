#!/bin/bash
# Cleanup script for Linux templates
# Based on VirtualizationHowTo article best practices

echo "Starting cleanup process..."

# Clean package cache
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo apt-get clean

# Clear logs
sudo journalctl --vacuum-time=1d
sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/*/*.log
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear bash history
history -c
cat /dev/null > ~/.bash_history

# Clear SSH host keys (will be regenerated on first boot)
sudo rm -f /etc/ssh/ssh_host_*

# Clear machine ID (will be regenerated)
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clear cloud-init state
sudo cloud-init clean

echo "Cleanup complete"
