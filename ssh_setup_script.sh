
set -x

# =============================================================

### SECURITY HARDENING:

cd /root || exit 1;

# =============================================================

# Harden sshd configuration
# Remove the old keys
rm -rf /etc/ssh/ssh_host_*
# Generate new secure key
ssh-keygen -o -a 100 -t ed25519 -C "cmeldis" -f /etc/ssh/ssh_host_ed25519_key -N ""
# Generate new Diffie-Hellman moduli (!! 15-30 minutes !! then 5-10 HOURS !! )
ssh-keygen -G moduli-4096.candidates -b 512
# ssh-keygen -G moduli-4096.candidates -b 4096
ssh-keygen -T moduli-4096 -f moduli-4096.candidates
cp moduli-4096 /etc/ssh/moduli
rm moduli-4096



# Allow only the most secure algorithms in the /etc/ssh/sshd_config
cat << EOF > /etc/ssh/sshd_config
Ciphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
MACs=hmac-sha2-512-etm@openssh.com
KexAlgorithms=curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
HostKeyAlgorithms=ssh-ed25519,ssh-ed25519-cert-v01@openssh.com
PubkeyAcceptedKeyTypes=ssh-ed25519,ssh-ed25519-cert-v01@openssh.com
CASignatureAlgorithms=ssh-ed25519
hostbasedacceptedkeytypes=ssh-ed25519-cert-v01@openssh.com,ssh-ed25519

X11Forwarding no
IgnoreRhosts yes
UseDNS yes
PermitEmptyPasswords no

PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin prohibit-password

Protocol 2
Port 8000

ClientAliveInterval 3000
ClientAliveCountMax 5

GSSAPIAuthentication no
permitopen none
permitlisten none
allowtcpforwarding no
allowagentforwarding no
disableforwarding yes
allowstreamlocalforwarding no
PermitTTY yes
permituserrc no
PrintLastLog no

UsePAM yes
EOF

# Allow ssh port in firewall
firewall-cmd --zone=public --add-port=8000/tcp --permanent


# ssh key to access root
cat << EOF > /root/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtORHCAMaWVMxdZmdCGkB73v07xhzF/vYwfxGrK7Q/I
EOF

# DISABLE FIREWALL (for now), so we will be able to connect the configured port
systemctl enable firewalld
systemctl restart firewalld

# ENABLE SSHD
systemctl enable sshd
systemctl restart sshd

