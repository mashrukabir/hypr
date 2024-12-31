#!/bin/bash

sudo pacman -S --noconfirm thunar thunar-volman tumbler ffmpegthumbnailer gvfs-mtp ntfs-3g

# Rules
volman_config_path=~/.config/Thunar/uca.xml
if [ ! -f "$volman_config_path" ]; then
    echo "Setting up Thunar Volume Management rules..."
    cp assets/uca.xml "$volman_config_path"
else
    echo "Thunar Volume Management rules already exist."
fi
 
echo -e "\e[1;32mThunar and essential packages installed and configured successfully.\e[0m"
