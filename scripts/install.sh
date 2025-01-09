#!/bin/bash

# Optimizations
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sudo sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf

echo -e "\e[1;34mInstalling AUR helper...\e[0m"
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si --noconfirm && cd .. && rm -rf paru-bin

# Packages
paru -S --noconfirm hyprland waybar wofi swww hyprlock cliphist xdg-desktop-portal-hyprland alacritty mpv pulsemixer grim slurp polkit-gnome nwg-look blueman fastfetch btop zoxide
sudo systemctl enable bluetooth

# Thunar
./thunar.sh && clear

echo -e "\e[1;33mInstalling applications\e[0m"
paru -S --noconfirm obsidian syncthing keepassxc librewolf-bin qview-git
paru -Rsc --noconfirm yay nano xterm unrar sysfsutils b43-fwcutter btrfs-progs ding-libs dosfstools ell eos-hooks f2fs-tools fd fzf sof-firmware smart-montools s-nail reflector rebuild-detector man-db man-pages

# Configuration
echo -e "\e[1;34mConfiguring system\e[0m"
sudo rm /usr/share/hyprland/* && rm -rf ~/.config/hypr
mkdir -p ~/Pictures/{Wallpapers,Screenshots} 
mkdir -p ~/Downloads ~/Videos ~/Projects
mkdir -p ~/.config/hypr ~/.local/share/{icons,fonts,themes} 
mv ~/hypr/{hyprland.conf,hyprlock.conf} ~/.config/hypr/
mv ~/hypr/fonts ~/.local/share/

curl -LO https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
tar -xvf Bibata-Modern-Ice.tar.xz -C ~/.local/share/icons/
mv ~/.local/share/icons/Bibata-Modern-Ice ~/.local/share/icons/cursor
rm Bibata-Modern-Ice.tar.xz

git clone --depth 1 --filter=blob:none --sparse https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git
cd papirus-icon-theme && git sparse-checkout set Papirus && sudo mv Papirus /usr/share/icons/ && cd && rm -rf papirus-icon-theme

git clone https://github.com/daniruiz/flat-remix-gtk.git && cd flat-remix-gtk
cp -r themes/Flat-Remix-GTK-Blue-Darkest-Solid ~/.local/share/themes/Flat-Remix
cd && rm -rf flat-remix-gtk

mv ~/hypr/{alacritty,wofi} ~/.config/
mv ~/hypr/wall.jpg ~/Pictures/Wallpapers/
sudo mv ~/hypr/waybar/* /etc/xdg/waybar/
rm -rf ~/hypr/waybar && rm ~/hypr/scripts/{install.sh,thunar.sh}
xdg-settings set default-web-browser librewolf.desktop
echo "QT_SCALE_FACTOR=1.25" | sudo tee -a /etc/environment && cd

# NVIDIA
echo -e "\e[1;32mDoes your system have an Nvidia GPU? (yes/no): \e[0m"
read -p "" answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer" == "yes" ]]; then
    echo -e "\e[1;32mInstalling NVIDIA drivers and configuring system\e[0m"
    sudo pacman -S --noconfirm nvidia-dkms libva-nvidia-driver
    sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf
    cat <<EOF >> ~/.config/hypr/hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct

cursor {
    no_hardware_cursors = true
}
EOF
    sudo mkinitcpio -P
    echo -e "\e[1;32mNVIDIA setup complete\e[0m"
    read -p "Would you like to reboot to apply Nvidia changes? (y/n): " reboot_answer
    reboot_answer=$(echo "$reboot_answer" | tr '[:upper:]' '[:lower:]')
    if [[ "$reboot_answer" == "y" ]]; then
        echo -e "\e[1;31mRebooting system...\e[0m"
        sudo reboot
    else
        echo -e "\e[1;34mStarting Hyprland...\e[0m"
        Hyprland
    fi
else
    echo -e "\e[1;34mStarting Hyprland...\e[0m"
    Hyprland
fi
