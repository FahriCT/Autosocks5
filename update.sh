#!/bin/bash

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Script ini harus dijalankan sebagai root!" 
   exit 1
fi

# Buat file systemd service
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

# Buat file auto.sh
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

# Beri izin eksekusi pada script auto.sh
chmod +x /home/cloudsigma/auto.sh

# Reload systemd, enable, dan start service
systemctl daemon-reload
systemctl enable network-restart
systemctl start network-restart

echo "Setup selesai! Service telah diaktifkan."
