#!/bin/bash 
loadkeys de-latin1
echo welcome to archfn
sleep 1
lsblk
echo -n "such nach deiner Festplatte und schreib /dev/ davor bei dir sollte es /dev/sda sein ALLES auf dieser Festplatte wird gelöscht:  "
read drive 
#disk setup and formating 
sgdisk -Z ${drive}
sgdisk -a 2048 -o ${drive} 
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${drive} # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+300M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${drive} # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${drive} # partition 3 (Root), default start, remaining
if [[ ! -d "/sys/firmware/efi" ]]; then # Checking for bios system
    sgdisk -A 1:set:2 ${drive}
fi
partprobe ${drive} # reread partition table to ensure it is correct 

#check if disk is nvme
if [[ "${drive}" =~ "nvme" ]]; then
    partition2=${drive}p2
    partition3=${drive}p3
else
    partition2=${drive}2
    partition3=${drive}3
fi
#makes filesystems and mount root
mkfs.vfat -F32 -n "EFIBOOT" ${partition2}
mkfs.btrfs -L ROOT ${partition3} -f
mount -t btrfs ${partition3} /mnt
subvolumesetup
# mount boot
mkdir -p /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --noconfirm archlinux-keyring #update keyrings to latest to prevent packages failing to install
pacman -S --noconfirm --needed pacman-contrib
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup 
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null # Hiding error message if any
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc 
pacstrap /mnt base linux linux-firmware 
genfstab -U /mnt >> /mnt/etc/fstab 
mv arch-install/chroot.sh /mnt  
chmod +x /mnt/chroot.sh
arch-chroot /mnt 
