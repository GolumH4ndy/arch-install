ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime 
hwclock --systohc 
sed -i "en_US.UTF-8 UTF-8" /etc/locale.gen 
sed -i "de_DE.UTF-8 UTF-8" /etc/locale.gen    
locale-gen 
touch /etc/locale.conf 
sed -i "LANG=de_DE.UTF-8" 
rm /etc/vconsole.conf 
touch /etc/vconsole.conf 
sed -i "KEYMAP=de-latin1" /etc/vconsole.conf 
touch /etc/hostname 
sed -i "julius-arch" /etc/hostname 
mkinitcpio -P 
passwd 
pacman -S grub  
pacman -S efibootmgr 
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Arch Linux 
pacman -S chromium  nautilus 
pacman -S --needed xorg sddm
pacman -S --needed plasma kde-applications 
systemctl enable sddm
systemctl enable NetworkManager 
sudo pacman -S --needed base-devel 
git clone https://aur.archlinux.org/yay.git 
cd yay 
makepkg -si 
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
pacman -S --noconfirm --needed intel-ucode
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
        nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then

