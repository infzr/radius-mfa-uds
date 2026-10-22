#!/usr/bin/env bash
# Persiapan aaa-server (Ubuntu 22.04): paket, akun, dan direktori TOTP.
# Jalankan dengan: sudo bash scripts/setup-server.sh
set -euo pipefail

apt update
apt install -y chrony freeradius freeradius-ldap freeradius-utils \
    slapd ldap-utils libpam-google-authenticator oathtool qrencode

timedatectl set-timezone Asia/Jakarta
systemctl enable --now chrony

# Akun autentikasi (tanpa shell login). Sandi di bawah adalah data simulasi.
id adminnet &>/dev/null || useradd -M -s /usr/sbin/nologin adminnet
id staf01   &>/dev/null || useradd -M -s /usr/sbin/nologin staf01
echo 'adminnet:Adm!nUDS#2026' | chpasswd
echo 'staf01:Staf!UDS#2026'   | chpasswd

# Izinkan proses FreeRADIUS membaca /etc/shadow untuk pam_unix
usermod -aG shadow freerad

# Direktori rahasia TOTP
mkdir -p /etc/freeradius/3.0/totp
chown freerad:freerad /etc/freeradius/3.0/totp
chmod 700 /etc/freeradius/3.0/totp

# Aktifkan modul pam dan ldap
ln -sf ../mods-available/pam  /etc/freeradius/3.0/mods-enabled/pam
ln -sf ../mods-available/ldap /etc/freeradius/3.0/mods-enabled/ldap

echo "Selesai. Lanjutkan dengan: dpkg-reconfigure slapd, ldapadd, lalu scripts/enroll-totp.sh"
