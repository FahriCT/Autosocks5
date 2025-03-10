#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip sebagai root!" 
   exit 1
fi

echo "[+] Membuat File Auto Runing..."

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

echo "[+] Reload System ..."
systemctl daemon-reload
systemctl enable network-restart
systemctl start network-restart

echo "[+] Selesai Mereload System"


echo "[+] Memperbarui sistem dan menginstal Dante Server..."
apt update && apt install -y dante-server
sudo ufw disable

echo "[+] Mengaktifkan ens 4,5,6 ..."
sudo ip link set ens4 up
sudo ip link set ens5 up
sudo ip link set ens6 up

sudo dhclient ens4
sudo dhclient ens5
sudo dhclient ens6


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

echo "[+] Membuat user SOCKS5 (admin)..."
useradd -m admin -s /bin/false

echo "[+] Memulai dan mengaktifkan Dante Server..."
systemctl restart danted
systemctl enable danted

echo "[+] Mengecek status Dante Server..."
systemctl status danted --no-pager

echo "[✓] Instalasi selesai! SOCKS5 aktif di port 1080"

passwd admin
