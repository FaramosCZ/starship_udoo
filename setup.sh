
set -x

# 1) Enable root ssh access
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl restart sshd

# 2) Customize login screen message - show IP adresses
echo -e "\
IP LAN: \4{enp2s0}
IP WIFI: \4{wlp3s0} (default wifi password: \"password\")
" > /etc/issue

# 3) Set Kernel (dmesg) verbosity / log level
echo 'GRUB_CMDLINE_LINUX="loglevel=3"' >> /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# =============================================================

# 4)
