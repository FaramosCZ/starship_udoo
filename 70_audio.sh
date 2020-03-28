
set -x

# =============================================================

# Install minimal set of Xorg packages
dnf install -y pulseaudio pulseaudio-utils alsa-plugins-pulseaudio pulseaudio-module-x11 vlc

# =============================================================

# AUDIO SET-UP

# update SELinux rules
semodule -i files/PA_socket_container.pp

# Pulseaudio server can't run under root.
# It offers a user systemd service, which can be started by all (non-root) users as following:
#   systemctl --user start pulseaudio

# First add users that are expected to run sound to 'audio' group
usermod -a -G audio udoo
usermod -a -G audio lod
# Enable pulseaudio service for all interactive users
systemctl --global enable pulseaudio

# Update ".bash_profile" configuration of user 'lod', so it will set up correctly DBUS environment variables on each login (bash execution)
su -c "cat" lod << EOF >> /home/lod/.bash_profile
export DISPLAY=:0
export XDG_SESSION_CLASS=user
export XDG_RUNTIME_DIR=/run/user/1001
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1001/bus
EOF

# An user manager is spawned for the user at boot and kept around after logouts. This allows users who are not logged in to run long-running services.
loginctl enable-linger lod

# From now, it is possible to run a sound as as 'lod' user, once a login operation was performed and evironment variables vere set (e.g. "su -" bot not "su").

# Unmute the output
su -c "pacmd set-sink-mute alsa_output.pci-0000_00_1b.0.analog-stereo false" lod

# ------------------------------------------------------------
