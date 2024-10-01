#!/bin/bash

# Auto Script Install Squid Proxy
# Author Masanto
# fb/@scht.id

# Update repository dan upgrade paket
apt update
apt upgrade -y

# Install Squid Proxy
apt install squid -y

# Hentikan service Squid 
systemctl stop squid

# Backup konfigurasi default
cp /etc/squid/squid.conf /etc/squid/squid.conf.orig

# Konfigurasi dasar Squid Proxy 
cat << EOF > /etc/squid/squid.conf
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Squid Basic Authentication
auth_param basic credentialsttl 2 hours
acl auth_users proxy_auth REQUIRED
http_access allow auth_users

acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 "this" network (LAN)
acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)
acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)
acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines
acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)
acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)
acl localnet src fc00::/7       	# RFC 4193 local private network range
acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access allow localhost manager
http_access deny manager

include /etc/squid/conf.d/*

http_access allow localhost

# allow all requests    
acl all src 0.0.0.0/0
http_access allow all

# And finally deny all other access to this proxy
http_access deny all

http_port 3128

#acl ip1 myip 155.138.211.40
#acl ip2 myip 155.138.204.186
#acl ip3 myip 155.138.235.182

#tcp_outgoing_address 155.138.211.40 ip1
#tcp_outgoing_address 155.138.204.186 ip2
#tcp_outgoing_address 155.138.235.182 ip3

coredump_dir /var/spool/squid

refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims
refresh_pattern \/InRelease$ 0 0% 0 refresh-ims
refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
# example pattern for deb packages
#refresh_pattern (\.deb|\.udeb)$   129600 100% 129600
refresh_pattern .		0	20%	4320
EOF

# Reload konfigurasi Squid
systemctl reload squid.service

# Buat file password dan atur ownership
touch /etc/squid/passwd
chown proxy: /etc/squid/passwd

# Fungsi untuk menambahkan user
add_user() {
  read -p "Masukkan username: " username
  read -sp "Masukkan password: " password
  echo
  htpasswd /etc/squid/passwd "$username" <<< "$password"
  echo "User $username berhasil ditambahkan."
}

# Fungsi untuk menghapus user
delete_user() {
  read -p "Masukkan username yang ingin dihapus: " username
  htpasswd -D /etc/squid/passwd "$username"
  echo "User $username berhasil dihapus."
}

# Fungsi untuk menampilkan informasi proxy
show_info() {
  echo "-------------------------"
  echo "  Informasi Proxy Anda  "
  echo "-------------------------"
  echo "IP Address: $(curl -s ifconfig.me)"  # Mendapatkan IP publik VPS
  echo "Port: 3128"
  echo "-------------------------"
}

# Tampilkan menu
while true; do
  echo "-------------------------"
  echo "      Menu Squid Proxy     "
  echo "-------------------------"
  echo "1. Tambah User"
  echo "2. Hapus User"
  echo "3. Tampilkan Info Proxy"
  echo "4. Keluar"
  echo "-------------------------"
  read -p "Pilih menu: " pilihan

  case $pilihan in
    1)
      add_user
      ;;
    2)
      delete_user
      ;;
    3)
      show_info
      ;;
    4)
      break
      ;;
    *)
      echo "Pilihan tidak valid."
      ;;
  esac
done

# Start service Squid dan aktifkan saat booting
systemctl start squid
systemctl enable squid
