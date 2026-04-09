#!/bin/bash

clear
echo "DDoS protection setup"
echo ""

read -sp "Password: " p
echo ""

if [ "$p" != "12300321" ]; then
    echo "Wrong password"
    exit 1
fi

echo "Starting..."
sleep 1

apt update -y >/dev/null 2>&1
apt upgrade -y >/dev/null 2>&1

apt install -y ufw fail2ban >/dev/null 2>&1

ufw default deny incoming >/dev/null 2>&1
ufw default allow outgoing >/dev/null 2>&1
ufw allow 22 >/dev/null 2>&1
ufw limit 22 >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
EOF

systemctl restart fail2ban
systemctl enable fail2ban >/dev/null 2>&1

cat >> /etc/sysctl.conf <<EOF

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
EOF

sysctl -p >/dev/null 2>&1

iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 30 -j DROP

echo ""
echo "Done"
