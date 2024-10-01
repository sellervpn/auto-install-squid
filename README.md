# Instalasi Squid Proxy di VPS

Script ini akan membantu Anda menginstal dan mengkonfigurasi Squid Proxy di VPS Ubuntu dengan mudah.

## Fitur

* Instalasi otomatis Squid Proxy.
* Konfigurasi dasar dengan autentikasi.
* Menu interaktif untuk:
    * Menambah user.
    * Menghapus user.
    * Menampilkan informasi proxy (IP dan port).

## Cara Instalasi

### 1. Persiapan

* Akses SSH ke VPS Ubuntu Anda.
* Pastikan Git sudah terinstall. Jika belum, install dengan perintah:

   ```bash
   sudo apt update
   sudo apt install git -y

### 2. Clone Repository

* Clone repository ini ke VPS Anda:
   ```clone
   git clone https://github.com/sellervpn/auto-install-squid.git

* cd auto-install-squid

### 3. Jalankan Script
* Beri akses dan Run

    ```bash
    chmod +x install_squid.sh
    sudo ./install_squid.sh
