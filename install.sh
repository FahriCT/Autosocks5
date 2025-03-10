#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip sebagai root!" 
   exit 1
fi

clear
echo "======================================"
echo "      SENVAS AUTO SOCKS INSTALLER     "
echo "======================================"
echo ""
echo "[+] Menginstal..."

# Membuat File Auto Running
echo "[+] Membuat File Auto Running..."
cat <<EOF > /etc/systemd/system/network-restart.service
[Unit]
Description=Setup network interfaces and restart Dante
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash /home/cloudsigma/auto.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /home/cloudsigma/auto.sh
#!/bin/bash
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up
dhclient ens4
dhclient ens5
dhclient ens6
systemctl restart danted
EOF

chmod +x /home/cloudsigma/auto.sh

echo "[+] Reloading SystemD..."
systemctl daemon-reload
systemctl enable network-restart
systemctl start network-restart

# Instalasi Dante Server
echo "[+] Memperbarui sistem dan menginstal Dante Server..."
apt update -y &> /dev/null && apt install -y dante-server &> /dev/null
ufw disable &> /dev/null

# Mengaktifkan Interface
echo "[+] Mengaktifkan ens4, ens5, ens6..."
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up

dhclient ens4
dhclient ens5
dhclient ens6

# Konfigurasi Dante
echo "[+] Mengonfigurasi Dante..."
cat > /etc/danted.conf <<EOL
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

internal: ens3 port = 1080
internal: ens4 port = 1080
internal: ens5 port = 1080
internal: ens6 port = 1080

external: ens3
external: ens4
external: ens5
external: ens6

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

# Membuat User SOCKS5
echo "[+] Membuat user SOCKS5 (admin)..."
useradd -m admin -s /bin/false
echo "admin:admin" | chpasswd

echo "[✓] User SOCKS5 'admin' berhasil dibuat dengan password 'admin'."

# Memulai Dante Server
echo "[+] Memulai dan mengaktifkan Dante Server..."
systemctl restart danted
systemctl enable danted

# Menampilkan Status
echo "[+] Mengecek status Dante Server..."
systemctl status danted --no-pager | grep "Active:"

echo ""
echo "======================================"
echo "    SENVAS AUTO SOCKS INSTALLED!      "
echo "======================================"
echo "[✓] SOCKS5 Aktif di Port 1080"
echo "[✓] Username: admin"
echo "[✓] Password: admin"
echo "======================================"
