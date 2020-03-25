
set -x

# =============================================================

# Install minimal set of Xorg packages
dnf install -y pulseaudio pulseaudio-utils vlc

# =============================================================

# AUDIO SET-UP

# Pulseaudio server can't run under root.
# It offers a user systemd service, which can be started by all (non-root) users as following:
#   systemctl --user start pulseaudio

# ------------------------------------------------------------
