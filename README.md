# SISOP-1-2026-042

## Nama

Nayla Arsha Adyuta - 5027251042

## Soal 1 - ARGO NGAWI JESGEJES

### Preview dan deskripsi soal 

Program ini menggunakan `awk` untuk menganalisis data penumpang kereta dari file `passenger.csv`. Terdapat 5 pilihan/menu yang bisa dipilih saat menjalankan script, yaitu a, b, c, d, e.

### Penjelasan

**`KANJ.sh`** — AWK script yang menerima dua argumen: file CSV dan menu (`a`–`e`).

- **Menu `a`** — Menghitung total jumlah seluruh penumpang.
- **Menu `b`** — Menghitung jumlah gerbong unik yang ada.
- **Menu `c`** — Mencari nama penumpang tertua beserta usianya.
- **Menu `d`** — Menghitung rata-rata usia seluruh penumpang (dibulatkan ke bawah).
- **Menu `e`** — Menghitung jumlah penumpang yang menggunakan Business Class.

Script membaca CSV dengan `FS=","`, melewati baris header (`NR==1 {next}`), lalu mengakumulasi data di blok `{}` dan mencetak hasil di blok `END` sesuai menu yang dipilih.

### Cara Penggunaan

```bash
awk -f KANJ.sh passenger.csv <menu>
```

**Contoh:**

```bash
# a - Jumlah seluruh penumpang
awk -f KANJ.sh passenger.csv a

# b - Jumlah gerbong
awk -f KANJ.sh passenger.csv b

# c - Penumpang tertua
awk -f KANJ.sh passenger.csv c

# d - Rata-rata usia
awk -f KANJ.sh passenger.csv d

# e - Penumpang business class
awk -f KANJ.sh passenger.csv e
```

### Output

```
menu a:                     Jumlah seluruh penumpang KANJ adalah 208 orang
menu b:                     Jumlah gerbong penumpang KANJ adalah 4
menu c:                     Jaja Mihardja adalah penumpang kereta tertua dengan usia 85 tahun
menu d:                     Rata-rata usia penumpang adalah 37 tahun
menu e:                     Jumlah penumpang business class ada 74 orang
menu selain a/b/c/d/e:      Soal tidak dikenali. Gunakan a, b, c, d, atau e.
                            Contoh penggunaan: awk -f KANJ.sh passenger.csv a
```

---

## Soal 2 - EKSPEDISI PESUGIHAN GUNUNG KAWI

### Deskripsi

Program ini terdiri dari dua bash script yang bekerja secara berurutan untuk menemukan lokasi "pusaka" yang tersembunyi di Gunung Kawi berdasarkan data koordinat dari file JSON pelacak GPS (`gsxtrack.json`).

### Penjelasan Kode

#### `parserkoordinat.sh`

Script ini mem-parsing file `gsxtrack.json` dan mengekstrak informasi node-node penting ke dalam file `titik-penting.txt`.

- Menggunakan `awk` untuk membaca JSON baris per baris.
- Mengekstrak field `id`, `site_name`, `latitude`, dan `longitude` dari setiap node.
- Hanya memproses node yang memiliki ID dengan format `node_XXX`.
- Output disimpan dalam format: `node_id, site_name, latitude, longitude`.

#### `nemupusaka.sh`

Script ini membaca `titik-penting.txt` hasil parsing sebelumnya dan menghitung titik tengah diagonal antara `node_001` (baris 1) dan `node_003` (baris 3) sebagai lokasi pusaka.

- Mengambil koordinat `node_001` dan `node_003` menggunakan `awk`.
- Menghitung rata-rata latitude dan longitude dari dua titik tersebut.
- Mencetak koordinat titik tengah ke file `posisipusaka.txt` dengan presisi 6 angka desimal.

### Cara Penggunaan

Jalankan dari dalam folder `peta-gunung-kawi/`:

```bash
# Langkah 1: Parse koordinat dari JSON
bash parserkoordinat.sh

# Langkah 2: Temukan lokasi pusaka
bash nemupusaka.sh
```

### Output

**`titik-penting.txt`:**
```
   1 │ node_001, Titik Berak Paman Mas Mba, -7.920000, 112.450000
   2 │ node_002, Basecamp Mas Fuad, -7.920000, 112.468100
   3 │ node_003, Gerbang Dimensi Keputih, -7.937960, 112.468100
   4 │ node_004, Tembok Ratapan Keputih, -7.937960, 112.450000
```

**Terminal `nemupusaka.sh`:**
```
=== LOKASI PUSAKA DITEMUKAN ===
Latitude: -7.928980, Longitude: 112.459050
```
**`posisipusaka.txt`:**
```
   1 │ Latitude: -7.928980, Longitude: 112.459050
```

---

## Soal 3 - KOS SLEBEW AMBATUKAM

### Deskripsi

Sistem manajemen kost berbasis bash interaktif dengan tampilan ASCII art. Program ini mengelola data penghuni kost yang tersimpan di CSV, dilengkapi fitur cron job untuk pengingat tagihan otomatis.

### Struktur File

```
soal3/
├── kost_slebew.sh          # Script utama
├── data/
│   └── penghuni.csv        # Database penghuni
├── sampah/
│   └── history_hapus.csv   # Arsip penghuni yang dihapus
├── rekap/
│   └── laporan_bulanan.txt # Laporan keuangan tersimpan
└── log/
    └── tagihan.log         # Log tagihan dari cron job
```

### Penjelasan Kode

Script utama `kost_slebew.sh` memiliki 6 fitur utama:

**1. Tambah Penghuni (`tambah_penghuni`)**
- Input: nama, nomor kamar, harga sewa, tanggal masuk, status awal.
- Validasi nomor kamar harus unik dan berupa angka.
- Validasi tanggal format `YYYY-MM-DD` dan tidak boleh melebihi tanggal hari ini.
- Validasi status hanya `Aktif` atau `Menunggak`.

**2. Hapus Penghuni (`hapus_penghuni`)**
- Mencari penghuni berdasarkan nama.
- Mengarsipkan data ke `sampah/history_hapus.csv` (dengan tambahan kolom `tanggal_hapus`) sebelum menghapus dari database utama.

**3. Tampilkan Daftar Penghuni (`tampil_daftar`)**
- Menampilkan semua penghuni dalam format tabel rapi menggunakan `awk`.
- Menampilkan ringkasan total penghuni, jumlah aktif, dan jumlah menunggak.

**4. Update Status (`update_status`)**
- Mengubah status penghuni antara `Aktif` dan `Menunggak`.
- Menggunakan `awk` untuk in-place edit pada CSV.

**5. Laporan Keuangan (`laporan_keuangan`)**
- Menghitung total pemasukan dari penghuni aktif dan total tunggakan.
- Menampilkan daftar penghuni yang sedang menunggak.
- Menyimpan laporan ke `rekap/laporan_bulanan.txt`.

**6. Kelola Cron (`kelola_cron`)**
- Mendaftarkan cron job harian untuk mengecek penghuni menunggak.
- Cron job memanggil script dengan flag `--check-tagihan` yang menulis ke `log/tagihan.log`.
- Bisa melihat, menambah, dan menghapus cron job dari dalam menu.

### Cara Penggunaan

```bash
# Jalankan program utama
bash kost_slebew.sh

# (Otomatis oleh cron) Cek tagihan
bash kost_slebew.sh --check-tagihan
```

### Output

**Menu Utama:**
```
==============================================

__  _____  ____ ______    ____  _     _____ ____  _______        __
| |/ /   \/ ___|_   _|   / ___|| |   | ____| __ )| ____\ \      / /
| ' /  _  \___ \ | |     \___ \| |   |  _| |  _ \|  _|  \ \ /\ / /
| . \ (_) /___)  | |      ___) | |___| |___| |_) | |___  \ V  V /
|_|\_\___/\____/ |_|     |____/|_____|_____|____/|_____|  \_/\_/

==============================================
       SISTEM MANAJEMEN KOST SLEBEW
==============================================
 ID | OPTION
--------------------------------------------
  1 | Tambah Penghuni Baru
  2 | Hapus Penghuni
  3 | Tampilkan Daftar Penghuni
  4 | Update Status Penghuni
  5 | Cetak Laporan Keuangan
  6 | Kelola Cron (Pengingat Tagihan)
  7 | Exit Program
==============================================
```

**Daftar Penghuni:**
```
==============================================
       DAFTAR PENGHUNI KOST SLEBEW
==============================================
No  | Nama           | Kamar  | Harga Sewa    | Status
------------------------------------------------------
1   | Andi Wijaya    | 101    | Rp1.500.000   | Aktif
------------------------------------------------------
2   | Budi Santoso   | 102    | Rp1.200.000   | Menunggak
------------------------------------------------------

Total: 2 penghuni | Aktif: 1 | Menunggak: 1
==============================================
```

**Log Tagihan (`tagihan.log`):**
```
[2026-03-29 07:00:01] TAGIHAN: Budi Santoso (Kamar 102) - Menunggak Rp1200000
```
