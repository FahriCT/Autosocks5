#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip sebagai root!" 
   exit 1
fi

echo "[+] Memperbarui sistem dan menginstal Dante Server..."
apt update && apt install -y dante-server

echo "[+] Mengonfigurasi Dante..."
cat > /etc/danted.conf <<EOL
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

internal: ens3 port = 1080

external: ens3


clientmethod: none
socksmethod: username

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}
EOL

echo "[+] Membuat user SOCKS5 (mimin)..."
useradd -m mimin -s /bin/false
echo "mimin:Senvas@12#" | chpasswd

echo "[+] Memulai dan mengaktifkan Dante Server..."
systemctl restart danted
systemctl enable danted

echo "[+] Mengecek status Dante Server..."
systemctl status danted --no-pager

echo "[✓] Instalasi selesai! SOCKS5 aktif di port 1080"
