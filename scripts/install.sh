#!/bin/bash

# Optimizations
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i '/\[options\]/a\ILoveCandy' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sudo sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
sudo sed -i 's/^timeout 3/timeout 0/' /boot/loader/loader.conf

echo "Installing AUR helper..."
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si --noconfirm
cd .. && rm -rf paru-bin

echo "Installing packages"
paru -S --noconfirm --needed hyprland waybar wofi swww hyprlock cliphist xdg-desktop-portal-hyprland noto-fonts noto-fonts-emoji alacritty mpv pulsemixer grim slurp playerctl polkit-gnome papirus-icon-theme nwg-look blueman fastfetch btop zoxide
sudo systemctl enable bluetooth

# Thunar
./thunar.sh
clear

# Applications
paru -S --noconfirm --needed obsidian signal-desktop syncthing keepassxc librewolf-bin qview-git vscodium-bin

# Configuration
clear && cd && sudo rm /usr/share/hyprland/* && rm -rf ~/.config/hypr
mkdir -p ~/Pictures/{Wallpapers,Screenshots} 
mkdir -p ~/Downloads ~/Videos ~/Projects ~/Documents/Shared
mkdir -p ~/.config/hypr ~/.local/share/{icons,fonts,themes} 
mv ~/hypr/{hyprland.conf,hyprlock.conf} ~/.config/hypr/
mv ~/hypr/fonts ~/.local/share/

curl -LO https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
tar -xvf Bibata-Modern-Ice.tar.xz -C ~/.local/share/icons/
mv ~/.local/share/icons/Bibata-Modern-Ice ~/.local/share/icons/cursor
rm Bibata-Modern-Ice.tar.xz

git clone https://github.com/daniruiz/flat-remix-gtk.git && cd flat-remix-gtk
cp -r themes/Flat-Remix-GTK-Blue-Darkest-Solid ~/.local/share/themes/Flat-Remix
cd .. && rm -rf flat-remix-gtk

mv ~/hypr/{alacritty,wofi} ~/.config/
mv ~/hypr/wall.jpg ~/Pictures/Wallpapers/
sudo mv ~/hypr/waybar/* /etc/xdg/waybar/
rm -rf ~/hypr/waybar && rm ~/hypr/scripts/{install.sh,thunar.sh}
xdg-settings set default-web-browser librewolf.desktop
echo "QT_SCALE_FACTOR=1.25" | sudo tee -a /etc/environment && cd

# NVIDIA
read -p "Does your system have an Nvidia GPU? (yes/no): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [[ "$answer" == "yes" ]]; then
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
    read -p "Would you like to reboot to apply Nvidia changes? (y/n): " reboot_answer
    reboot_answer=$(echo "$reboot_answer" | tr '[:upper:]' '[:lower:]')
    if [[ "$reboot_answer" == "y" ]]; then
        sudo reboot
    else
        Hyprland
    fi
else
    Hyprland
fi
