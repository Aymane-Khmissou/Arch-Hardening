#!/bin/bash
#
#Hardening.sh
#
#This script automates the hardening of an Arch linux 
#
#
#----------------------------------------------------
# Updating and Upgrade the System
#----------------------------------------------------
echo "Updating and Upgrade System"
pacman -Syu
echo "System Updating Completed"

#----------------------------------------------------
# Users permissions
#----------------------------------------------------
awk -F: '($3 == 0) {print $1}' /etc/passwd
chmod 644 /etc/passwd
chmod 600 /etc/shadow

#----------------------------------------------------
# Telnet && SSH
#----------------------------------------------------
systemctl stop telnet.socket 2>/dev/null
systemctl disable telnet.socket 2>/dev/null

SSH_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSH_CONFIG" ]; then
	sed -i 's/^#\?Port .*/Port 2222/' "$SSH_CONFIG"
	sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' "$SSH_CONFIG"
	sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSH_CONFIG"
	systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
	echo "SSH cmplete Config"
else
	echo "ERROR in the proccess"
fi

#----------------------------------------------------
# Firewall Setup (UFW)
#----------------------------------------------------
echo "Start Download Firewall"

pacman -S --noconfirm ufw 2>/dev/null

ufw default deny incoming
ufw default allow outgoing

#Allow SSH the New Port
ufw allow 2222/tcp

#Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

#Started with system
systemctl enable --now ufw
ufw --force enable

echo "Firewall DONE!"

#----------------------------------------------------
# Kernel & Network Hardening (Sysctl)
#----------------------------------------------------
echo "[*] جاري تطبيق إعدادات حماية النواة والشبكة (Sysctl)..."

SYSCTL_CONF="/etc/sysctl.d/99-security.conf"

# كتابة قواعد الحماية في ملف خاص بـ sysctl.d
cat << 'EOF' > "$SYSCTL_CONF"
# --- IP Spoofing Protection ---
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# --- ICMP Redirects Disabling ---
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# --- SYN Flood Protection (DDoS Mitigation) ---
net.ipv4.tcp_syncookies = 1

# --- Ignore ICMP Broadcasts ---
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF

sysctl --system > /dev/null 2>&1

echo "Done!!"
