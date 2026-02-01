#!/bin/bash
# Simpan ini di GitHub/Gist, lalu ambil URL RAW-nya.

# 1. Tangkap Password dari PHP
ROOT_PASS=$1

# 2. Setup Password Root & SSH
echo "root:$ROOT_PASS" | chpasswd
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart

# 3. Buat SWAP 2GB (Wajib untuk CloudPanel)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 4. Update & Install CloudPanel
apt-get update -y
apt-get install -y curl wget sudo
curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh
echo "Installing CloudPanel..."
sudo DB_ENGINE=MARIADB_10.11 bash install.sh
