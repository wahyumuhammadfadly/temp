#!/bin/bash

# Tangkap password dari argumen pertama
ROOT_PASS=$1

# 1. Setup Password Root & SSH (Agar bisa login PuTTY)
echo "root:$ROOT_PASS" | chpasswd
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart

# 2. Setup SWAP 2GB (Wajib untuk CloudPanel agar tidak crash saat install)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 3. Update System
apt-get update -y
apt-get install -y curl wget sudo

# 4. Install CloudPanel (Database Engine: MariaDB 10.11)
curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
echo "Installing CloudPanel..."
sudo DB_ENGINE=MARIADB_10.11 bash install.sh
