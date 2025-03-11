#!/bin/bash

# filepath: install-socks.sh
clear
echo "======================================"
echo "      SENVAS AUTO SOCKS INSTALLER     "
echo "======================================"
echo ""
echo "[+] Menginstal..."

# Check root
[[ $EUID -ne 0 ]] && { echo "Jalankan skrip sebagai root!"; exit 1; }

# Create service file
echo "[+] Membuat File Auto Running..."
cat > /etc/systemd/system/network-restart.service << 'EEOF' &>/dev/null
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
cat > /home/cloudsigma/auto.sh << 'EEOF' &>/dev/null
#!/bin/bash
ip link set ens4 up
ip link set ens5 up
ip link set ens6 up
dhclient ens4
dhclient ens5
dhclient ens6
systemctl restart danted
EEOF

chmod +x /home/cloudsigma/auto.sh &>/dev/null

echo "[+] Reloading SystemD..."
systemctl daemon-reload &>/dev/null
systemctl enable network-restart &>/dev/null
systemctl start network-restart &>/dev/null

# Install Dante Server
echo "[+] Memperbarui sistem dan menginstal Dante Server..."
apt update -y &>/dev/null 
apt install -y dante-server &>/dev/null
ufw disable &>/dev/null

# Enable interfaces
echo "[+] Mengaktifkan ens4, ens5, ens6..."
ip link set ens4 up &>/dev/null
ip link set ens5 up &>/dev/null
ip link set ens6 up &>/dev/null
dhclient ens4 &>/dev/null
dhclient ens5 &>/dev/null
dhclient ens6 &>/dev/null

# Configure Dante
echo "[+] Mengonfigurasi Dante..."
cat > /etc/danted.conf << 'EEOF' &>/dev/null
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
echo "[+] Membuat user SOCKS5 (admin)..."
useradd -m admin -s /bin/false &>/dev/null
echo "admin:admin" | chpasswd &>/dev/null

echo "[✓] User SOCKS5 'admin' berhasil dibuat dengan password 'admin'"

# Start Dante
echo "[+] Memulai dan mengaktifkan Dante Server..."
systemctl restart danted &>/dev/null
systemctl enable danted &>/dev/null

echo ""
echo "======================================"
echo "    SENVAS AUTO SOCKS INSTALLED!      "
echo "======================================"
echo "[✓] SOCKS5 Aktif di Port 1080"
echo "[✓] Username: admin"
echo "[✓] Password: admin"
echo "======================================"
