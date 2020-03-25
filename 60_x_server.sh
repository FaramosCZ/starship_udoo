
set -x

# =============================================================

# Install minimal set of Xorg packages
dnf install -y xorg-x11-server-Xorg xorg-x11-xinit xterm twm

# =============================================================

# DESKTOP ENVIRONMENT SET-UP

# We only need X for the containers with GUI apps.
# There is one container manager user account: 'lod'
# Let's start X always as this non-privileged user

# ------------------------------------------------------------

# Allow anybody to start X
cat << EOF > /etc/X11/Xwrapper.config
allowed_users = anybody
EOF

# ------------------------------------------------------------

# Create .xinitrc configuration file
cat << EOF > /home/lod/.xinitrc
xset s off         # don't activate screensaver
xset -dpms         # disable DPMS (Energy Star) features.
xset s noblank     # don't blank the video device

xsetroot -solid gray &
xterm -g 80x24+0+0 &
twm
EOF

exit 1

# ------------------------------------------------------------

# Create systemd service and bind it to the 'graphical.target'

cat << EOF > /usr/lib/systemd/system/xinit.service
[Unit]
Description=xinit
Documentation=man:xinit(1)

[Service]
User=lod
Group=lod

Type=simple
ExecStart=/usr/bin/xinit
#ExecStart=/usr/bin/xinit /etc/X11/xinit/xinitrc
#ExecStart=/usr/bin/startx
Restart=on-failure
RestartSec=5s

[Install]
Alias=display-manager.service
WantedBy=graphical.target
EOF

# Apply the new service
systemctl daemon-reload
systemctl enable xinit

# ------------------------------------------------------------

# By default, boot to graphical target:
systemctl set-default graphical.target

# Here's how to switch to the "headless server" mode:
#systemctl isolate multi-user.target

# =============================================================

# There might be one last thing, regarding containers.
# Non privileged containers doesn't have SELinux access to certain locations, so me must update the SELinux rules

# Install audit2allow
dnf install -y policycoreutils-python-utils

# You might want to:
#  audit2allow -a -t container_t
#  audit2allow -a -t container_t -M container_unprivileged_gui
#  semodule -i container_unprivileged_gui.pp
semodule -i files/container_unprivileged_gui.pp
