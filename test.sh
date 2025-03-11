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

# Create service file
cat > /etc/systemd/system/network-restart.service << 'EEOF'
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
EEOF

# Create auto script
cat > /home/cloudsigma/auto.sh << 'EEOF'
#!/bin/bash
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up
dhclient ens4
dhclient ens5
dhclient ens6
systemctl restart danted
EEOF

chmod +x /home/cloudsigma/auto.sh

systemctl daemon-reload
systemctl enable network-restart
systemctl start network-restart

# Install Dante Server
apt update -y
apt install -y dante-server
ufw disable

# Enable interfaces
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up
dhclient ens4
dhclient ens5
dhclient ens6

# Configure Dante
cat > /etc/danted.conf << 'EEOF'
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
EEOF

# Create SOCKS5 user
useradd -m admin -s /bin/false
echo "admin:admin" | chpasswd

# Start Dante
systemctl restart danted
systemctl enable danted

echo ""
echo "======================================"
echo "    SENVAS AUTO SOCKS INSTALLED!      "
echo "======================================"
echo "[✓] SOCKS5 Aktif di Port 1080"
echo "[✓] Username: admin"
echo "[✓] Password: admin"
echo "======================================"
