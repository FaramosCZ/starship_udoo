
set -x

# 1) Enable root ssh access
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl restart sshd

# 2) Customize login screen message - show IP adresses
echo -e "\
IP LAN: \4{enp2s0}
" > /etc/issue

# 3) Set Kernel (dmesg) verbosity / log level
echo 'GRUB_CMDLINE_LINUX="loglevel=3"' >> /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# 4) Set locale and timezone
localectl set-locale LANG="en_US.UTF-8"
timedatectl set-timezone "Europe/Prague"

# 5) Install more repositories
RPMFUSION="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
REPOS="fedora-workstation-repositories fedora-repos-rawhide $RPMFUSION"
dnf install -y --nogpgcheck $REPOS || exit

# 6) Install compression programs
dnf install -y unzip

# =============================================================

