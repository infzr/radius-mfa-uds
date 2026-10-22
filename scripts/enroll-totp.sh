#!/usr/bin/env bash
# Pendaftaran TOTP untuk adminnet dan staf01.
# Jalankan dengan: sudo bash scripts/enroll-totp.sh
set -euo pipefail

for u in adminnet staf01; do
  echo "=== Pendaftaran TOTP: $u ==="
  sudo -u freerad google-authenticator \
      --time-based --disallow-reuse --force \
      --rate-limit=3 --rate-time=30 --window-size=3 \
      --emergency-codes=0 \
      --secret="/etc/freeradius/3.0/totp/${u}.ga"
done

chmod 400 /etc/freeradius/3.0/totp/*.ga
ls -l /etc/freeradius/3.0/totp/
