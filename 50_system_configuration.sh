
set -x

# =============================================================

# Customize login screen message - show IP adresses
cat << EOF > /etc/issue
IP LAN: \4{enp2s0}
EOF

# Set Kernel (dmesg) verbosity / log level
echo 'GRUB_CMDLINE_LINUX="loglevel=3"' >> /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
# Do not forward kernel messages to systemd journal
echo 'ReadKMsg=no' >> /etc/systemd/journald.conf

# Set locale and timezone
localectl set-locale LANG="en_US.UTF-8"
timedatectl set-timezone "Europe/Prague"

# Install more repositories
RPMFUSION="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
REPOS="fedora-workstation-repositories fedora-repos-rawhide $RPMFUSION"
dnf install -y --nogpgcheck $REPOS || exit
dnf update -y

# Install compression programs
dnf install -y unzip

# Set local time
rm -f /etc/localtime || :
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

# =============================================================

# GIT CONFIGURATION
git config --global user.email "udoo@udoo.server"
git config --global user.name "UDOO"
git config --global core.editor "nano"

# =============================================================

# CREATE CONTAINER MANAGER ACCOUNT
useradd lod
# Set up a password
echo "lod:lod" | chpasswd

# GIT CONFIGURATION
su - -c 'git config --global user.email "lod@udoo.server"' lod
su - -c 'git config --global user.name "LOD"' lod
su - -c 'git config --global core.editor "nano"' lod

# Fetch the container repository
pushd /home/lod
su - -c "git clone https://github.com/FaramosCZ/UDOO_containers.git" lod
popd

# Install podman
dnf install -y podman

# =============================================================

# Setup system-wide BASH aliases
cp files/alias.sh /etc/profile.d/alias.sh

# =============================================================



# =============================================================
# =============================================================
