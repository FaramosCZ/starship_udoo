
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

### SECURITY HARDENING:

# Create Admin user & group
	groupadd -r udoo_admins
# Create new admin user
# And set his shell to the root's one.
# Also add him to the admin group
# DON'T make him system user, since that will prevent him from creating home
# DON'T share home with any other user. ".ssh" dir cannot be shared
	useradd udoo -G udoo_admins -s /bin/bash
# Set up a password
	echo "udoo:udoo" | chpasswd
# grant him full sudo priviledges
	dnf install -y sudo

	echo -e \
'
Defaults   !visiblepw
Defaults    always_set_home
Defaults    match_group_by_gid
Defaults    always_query_group_plugin
Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
Defaults    secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

includedir /etc/sudoers.d
'  > /etc/sudoers

echo -e \
'
Defaults   log_input, log_output
Defaults   shell_noargs
' > /etc/sudoers.d/udoo_defaults

echo -e \
'
Defaults:%udoo_admins   timestamp_timeout=60, logfile=/var/log/sudolog-udoo_admins
%udoo_admins ALL=(ALL) ALL
' > /etc/sudoers.d/udoo_admins

# Lock the root user account
	passwd -l root
# Scramble the password in the /etc/shadow
	usermod -p '!' root
# Disable root user login shell (avoids "sudo su", but not "sudo su -s /bin/bash")
	usermod -s /sbin/nologin root

# Disable root ssh access via password
sed -i 's/^PermitRootLogin.*//g' /etc/ssh/sshd_config
echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
systemctl restart sshd

# =============================================================


