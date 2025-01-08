#!/bin/bash

# update
sudo apt update && sudo apt upgrade -y

# root
if [ "$(id -u)" != "0" ]; then
    echo "Script ini harus dijalankan sebagai root atau menggunakan sudo."
    exit 1
fi

# port
echo "Membuka port yang diperlukan..."
sudo ufw allow 22 comment 'Allow SSH'
sudo ufw allow 3389 comment 'Allow RDP'
sudo ufw reload
echo "Port 22 tetap terbuka untuk SSH. Port 3389 dibuka untuk RDP."

# xfce
echo "Menginstal XFCE..."
sudo apt update
sudo apt install xfce4 xfce4-goodies -y
if [ $? -eq 0 ]; then
    echo "XFCE berhasil diinstal."
else
    echo "Gagal menginstal XFCE. Periksa koneksi internet atau repo."
    exit 1
fi

# ldm
echo "Menginstal LightDM..."
sudo apt install lightdm -y
if [ $? -eq 0 ]; then
    echo "LightDM berhasil diinstal."
else
    echo "Gagal menginstal LightDM. Periksa koneksi internet atau repo."
    exit 1
fi

echo "Mengatur LightDM sebagai display manager default..."
sudo systemctl enable lightdm
sudo systemctl start lightdm

# xrdp
echo "Menginstal XRDP untuk akses Remote Desktop..."
sudo apt install xrdp -y
if [ $? -eq 0 ]; then
    echo "XRDP berhasil diinstal."
else
    echo "Gagal menginstal XRDP. Periksa koneksi internet atau repo."
    exit 1
fi

echo "Mengonfigurasi XRDP untuk menggunakan XFCE..."
echo xfce4-session >~/.xsession
sudo systemctl enable xrdp
sudo systemctl restart xrdp
sudo adduser xrdp ssl-cert
echo "Status XRDP:"
sudo systemctl status xrdp --no-pager

# firewall
echo "Menampilkan status firewall..."
sudo ufw status verbose

echo "Setup selesai! Anda sekarang dapat mengakses server melalui Remote Desktop Connection menggunakan IP server ini."


# docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg
done

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# OpenLedger
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
sudo apt install unzip -y
unzip openledger-node-1.0.0-linux.zip
sudo dpkg -i openledger-node-1.0.0.deb
