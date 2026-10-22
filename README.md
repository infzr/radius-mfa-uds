# Autentikasi Terpusat (RADIUS/LDAP) dan MFA pada Jaringan Simulasi

Repositori konfigurasi untuk laporan praktikum **Implementasi Autentikasi Terpusat (RADIUS/LDAP) dan Multi-Factor Authentication** dengan studi kasus PT Utama Digital Solusindo.

- Nama / NIM: Infazar Putra Ramadhan / 2459201009
- Mata kuliah: Sistem Keamanan Jaringan
- Capaian: Sub-CPMK 3.3 dan Sub-CPMK 4.3
- Universitas Muhammadiyah Kotabumi, Program Studi Sistem Teknologi Informasi

> Seluruh sandi dan *shared secret* di repositori ini adalah data simulasi. Rahasia TOTP (`*.ga`) tidak diunggah.

## Topologi dan pengalamatan IP

| Perangkat | Antarmuka | Alamat IP | Peran |
|---|---|---|---|
| R1-UDS (Cisco IOS) | Gi0/0 | 192.168.10.1/24 | NAS, sumber paket RADIUS |
| R1-UDS (Cisco IOS) | Gi0/1 | 192.168.20.1/24 | Titik akses SSH client |
| aaa-server (Ubuntu 22.04) | ens3 | 192.168.10.10/24 | FreeRADIUS, OpenLDAP, PAM Google Authenticator |
| client-pc | ens3 | 192.168.20.10/24 | SSH client dan penguji |

## Peran pengguna (RBAC)

| Peran | Akun | Autentikasi | Faktor | priv-lvl |
|---|---|---|---|---|
| Admin Network | adminnet | RADIUS, PAM (password + TOTP) | 2 | 15 |
| Staf Internal | staf01 | RADIUS, PAM (password + TOTP) | 2 | 1 |
| Tamu | tamu01 | RADIUS, LDAP bind | 1 | 0 |

Saat login SSH, kata sandi dan 6 digit TOTP diketik bersambung pada satu kolom password.

## Struktur repositori

```
radius-mfa-uds/
├── README.md
├── .gitignore
├── freeradius/
│   ├── clients.conf                        -> /etc/freeradius/3.0/clients.conf
│   ├── users                               -> /etc/freeradius/3.0/users
│   ├── sites-enabled-default.snippet.conf  -> bagian authenticate pada sites-enabled/default
│   └── mods-available-ldap.snippet.conf    -> /etc/freeradius/3.0/mods-available/ldap
├── pam/
│   └── radiusd                             -> /etc/pam.d/radiusd
├── ldap/
│   └── guests.ldif                         -> data awal OpenLDAP (ou=Guests, tamu01)
├── cisco/
│   └── R1-UDS-aaa-config.txt               -> ditempel pada router R1-UDS
├── scripts/
│   ├── setup-server.sh                     -> instalasi paket dan pembuatan akun
│   └── enroll-totp.sh                      -> pendaftaran TOTP adminnet dan staf01
├── tests/
│   └── pentest-commands.md                 -> perintah uji Hydra, oathtool, radtest
└── screenshots/                            -> bukti pengujian
```

## Urutan penggunaan

1. Jalankan `scripts/setup-server.sh` pada aaa-server (hak sudo).
2. Muat `ldap/guests.ldif` dengan `ldapadd`, setelah mengganti hash `userPassword`.
3. Salin berkas dari `freeradius/` dan `pam/` ke jalur tujuan, lalu sesuaikan `mods-available/ldap` dan `sites-enabled/default`.
4. Jalankan `scripts/enroll-totp.sh`, lalu pindai kode QR atau catat *secret key*.
5. Uji dengan `sudo freeradius -X` dan `radtest`.
6. Tempel `cisco/R1-UDS-aaa-config.txt` pada router.
7. Lakukan pengujian pada `tests/pentest-commands.md` dan simpan bukti di `screenshots/`.
