#!/bin/bash

echo "Installing Thunar and related packages..."
sudo pacman -S --noconfirm --needed thunar thunar-volman tumbler ffmpegthumbnailer gvfs-mtp ntfs-3g

if ! pgrep -x "gvfsd" >/dev/null; then
    echo "gvfs isn't running. Please start it for Thunar to function properly."
fi

# Rules
volman_config_path=~/.config/Thunar/uca.xml
if [ ! -f "$volman_config_path" ]; then
    echo "Setting up Thunar Volume Management rules..."
    cp assets/uca.xml "$volman_config_path"
    echo "Thunar Volume Management rules set up successfully."
else
    echo "Thunar Volume Management rules already exist."
fi
 
echo "Thunar and essential packages installed and configured successfully."
