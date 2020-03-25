
set -x

# =============================================================

# Install minimal set of Xorg packages
dnf install -y pulseaudio pulseaudio-utils alsa-plugins-pulseaudio pulseaudio-module-x11 vlc

# =============================================================

# AUDIO SET-UP

# Pulseaudio server can't run under root.
# It offers a user systemd service, which can be started by all (non-root) users as following:
#   systemctl --user start pulseaudio

usermod -a -G audio udoo
usermod -a -G audio lod
#   systemctl --user start pulseaudio
su -c "systemctl --user enable pulseaudio" udoo
su -c "systemctl --user enable pulseaudio" lod


# ------------------------------------------------------------
