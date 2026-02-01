#!/bin/bash

# Tangkap password dari argumen v1
ROOT_PASS=$1

# --------------------------------------------------------
# 1. ANTI-CRASH SYSTEM (SWAP MANAGER)
# Wajib dijalankan paling awal agar server tidak mati saat install DB
# --------------------------------------------------------
if [ ! -f /swapfile ]; then
    echo "Creating Swap..."
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    # Tuning Swap agar tidak agresif mematikan proses
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

# --------------------------------------------------------
# 2. CONFIG SSH & FIREWALL (ANTI-LOCKOUT)
# Pastikan port terbuka sebelum installer berjalan
# --------------------------------------------------------
echo "Configuring Network Access..."
apt-get update -y
apt-get install -y ufw

# Allow Ports Explicitly
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8443/tcp

# Setup Password Root
echo "root:$ROOT_PASS" | chpasswd
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/g' /etc/ssh/sshd_config

# Restart SSHD agar config aktif
systemctl restart sshd

# --------------------------------------------------------
# 3. INSTALL CLOUDPANEL
# Gunakan mode 'noninteractive' agar tidak minta input di tengah jalan
# --------------------------------------------------------
echo "Installing CP..."
export DEBIAN_FRONTEND=noninteractive

curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
sudo DB_ENGINE=MARIADB_10.11 bash install.sh

# --------------------------------------------------------
# 4. FINAL CHECK
# Pastikan SSH tetap hidup setelah install selesai
# --------------------------------------------------------
ufw --force enable
service ssh restart
echo "Installation Complete."
