#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip sebagai root!" 
   exit 1
fi

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
internal: ens3 port = 1081
internal: ens3 port = 1082
internal: ens3 port = 1083
internal: ens3 port = 1084
internal: ens3 port = 1085
internal: ens3 port = 1086
internal: ens3 port = 1087
internal: ens3 port = 1088
internal: ens3 port = 1089
internal: ens3 port = 1090
internal: ens3 port = 1091
internal: ens3 port = 1092
internal: ens3 port = 1093
internal: ens3 port = 1094
internal: ens3 port = 1095
internal: ens3 port = 1096
internal: ens3 port = 1097
internal: ens3 port = 1098
internal: ens3 port = 1099
internal: ens3 port = 1100

internal: ens4 port = 1080
internal: ens4 port = 1081
internal: ens4 port = 1082
internal: ens4 port = 1083
internal: ens4 port = 1084
internal: ens4 port = 1085
internal: ens4 port = 1086
internal: ens4 port = 1087
internal: ens4 port = 1088
internal: ens4 port = 1089
internal: ens4 port = 1090
internal: ens4 port = 1091
internal: ens4 port = 1092
internal: ens4 port = 1093
internal: ens4 port = 1094
internal: ens4 port = 1095
internal: ens4 port = 1096
internal: ens4 port = 1097
internal: ens4 port = 1098
internal: ens4 port = 1099
internal: ens4 port = 1100

internal: ens5 port = 1080
internal: ens5 port = 1081
internal: ens5 port = 1082
internal: ens5 port = 1083
internal: ens5 port = 1084
internal: ens5 port = 1085
internal: ens5 port = 1086
internal: ens5 port = 1087
internal: ens5 port = 1088
internal: ens5 port = 1089
internal: ens5 port = 1090
internal: ens5 port = 1091
internal: ens5 port = 1092
internal: ens5 port = 1093
internal: ens5 port = 1094
internal: ens5 port = 1095
internal: ens5 port = 1096
internal: ens5 port = 1097
internal: ens5 port = 1098
internal: ens5 port = 1099
internal: ens5 port = 1100

internal: ens6 port = 1080
internal: ens6 port = 1081
internal: ens6 port = 1082
internal: ens6 port = 1083
internal: ens6 port = 1084
internal: ens6 port = 1085
internal: ens6 port = 1086
internal: ens6 port = 1087
internal: ens6 port = 1088
internal: ens6 port = 1089
internal: ens6 port = 1090
internal: ens6 port = 1091
internal: ens6 port = 1092
internal: ens6 port = 1093
internal: ens6 port = 1094
internal: ens6 port = 1095
internal: ens6 port = 1096
internal: ens6 port = 1097
internal: ens6 port = 1098
internal: ens6 port = 1099
internal: ens6 port = 1100


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

echo "[+] Membuat user SOCKS5 (mimin)..."
useradd -m admin -s /bin/false

echo "[+] Memulai dan mengaktifkan Dante Server..."
systemctl restart danted
systemctl enable danted

echo "[+] Mengecek status Dante Server..."
systemctl status danted --no-pager

echo "[✓] Instalasi selesai! SOCKS5 aktif di port 1080"

passwd admin
