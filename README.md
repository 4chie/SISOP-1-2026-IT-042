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

### Code

```c
BEGIN {
    FS ="," # membaca csv
    mode = ARGV[2]
    delete ARGV[2]
}
    NR==1 {next} # skip header
{
	# hitung penumpang (a)
	count_passenger++

	# jumlah  gerbong (b)
	{ gsub(/\r/, "", $4) }
	carriage[$4]

	# penumpang tertua (c)
	if ($2 > max_age) {
		max_age = $2
		oldest = $1
	}

	# rata-rata usia penumpang (d)
	total_age += $2

	# penumpang business class (e)
	if ($3 == "Business") {
		business_passenger++
	}
}

END {
	if (mode == "a") {
		print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
	} else if (mode == "b") {
		print "Jumlah gerbong penumpang KANJ adalah " length(carriage)
	} else if (mode == "c") {
		print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
	} else if (mode == "d") {
		print "Rata-rata usia penumpang adalah " int(total_age/count_passenger) " tahun"
	} else if (mode == "e") {
		print "Jumlah penumpang business class ada " business_passenger " orang"
	} else {
        	print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        	print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
	}
}
```

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

### Penjelasan

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

### Code

#### `parserkoordinat.sh`
```c
#!/bin/bash

input="gsxtrack.json"
output="titik-penting.txt"

> "$output"

awk '
/"id":/ && /"node_/ {
    gsub(/.*"id": "/, ""); gsub(/".*/, ""); id = $0
}
/"site_name":/ {
    gsub(/.*"site_name": "/, ""); gsub(/".*/, ""); name = $0
}
/"latitude":/ {
    gsub(/.*"latitude": /, ""); gsub(/,.*/, ""); lat = $0
}
/"longitude":/ && !/coordinates/ {
    gsub(/.*"longitude": /, ""); gsub(/,.*/, ""); lon = $0
    print id ", " name ", " lat ", " lon
}
' "$input" >> "$output"

echo "Selesai!"
cat "$output"
```

#### `nemupusaka.sh`
```c
#!/bin/bash

input="titik-penting.txt"
output="posisipusaka.txt"

# Ambil koordinat node_001 (baris 1) dan node_003 (baris 3) — diagonal 1
lat1=$(awk -F', ' 'NR==1 {print $3}' "$input")
lon1=$(awk -F', ' 'NR==1 {print $4}' "$input")
lat3=$(awk -F', ' 'NR==3 {print $3}' "$input")
lon3=$(awk -F', ' 'NR==3 {print $4}' "$input")

# Hitung titik tengah diagonal
mid_lat=$(awk "BEGIN {printf \"%.6f\", ($lat1 + $lat3) / 2}")
mid_lon=$(awk "BEGIN {printf \"%.6f\", ($lon1 + $lon3) / 2}")

echo "Latitude: $mid_lat, Longitude: $mid_lon" > "$output"

echo "=== LOKASI PUSAKA DITEMUKAN ==="
cat "$output"
```

### Cara Penggunaan

Jalankan dari dalam folder `peta-gunung-kawi/`:

```bash
# Langkah 1: Parse koordinat dari JSON
./parserkoordinat.sh

# Langkah 2: Temukan lokasi pusaka
./nemupusaka.sh
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

### Penjelasan

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

### Code

```c
#!/bin/bash

# SISTEM MANAJEMEN KOST SLEBEW

DB="data/penghuni.csv"
SAMPAH="sampah/history_hapus.csv"
REKAP="rekap/laporan_bulanan.txt"
LOG="log/tagihan.log"
SCRIPT_PATH="$(realpath "$0")"

# Inisialisasi folder & file
mkdir -p data sampah rekap log
[ ! -f "$DB" ] && echo "nama,kamar,harga_sewa,tanggal_masuk,status" > "$DB"
[ ! -f "$SAMPAH" ] && echo "nama,kamar,harga_sewa,tanggal_masuk,status,tanggal_hapus" > "$SAMPAH"

# FUNGSI HELPER

tampil_header() {
    clear
    echo "=============================================="
    cat << 'EOF'

__  _____  ____ ______    ____  _     _____ ____  _______        __
| |/ /   \/ ___|_   _|   / ___|| |   | ____| __ )| ____\ \      / /
| ' /  _  \___ \ | |     \___ \| |   |  _| |  _ \|  _|  \ \ /\ / /
| . \ (_) /___)  | |      ___) | |___| |___| |_) | |___  \ V  V /
|_|\_\___/\____/ |_|     |____/|_____|_____|____/|_____|  \_/\_/

EOF

    echo "=============================================="
    echo "       SISTEM MANAJEMEN KOST SLEBEW"
    echo "=============================================="
}

validasi_tanggal() {
    local tgl="$1"
    # Cek format YYYY-MM-DD
    if ! echo "$tgl" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        return 1
    fi
    # Cek tidak melebihi hari ini
    local today
    today=$(date +%Y-%m-%d)
    if [[ "$tgl" > "$today" ]]; then
        return 2
    fi
    return 0
}

kamar_unik() {
    local kamar="$1"
    if awk -F',' -v k="$kamar" 'NR>1 && $2==k {found=1} END {exit !found}' "$DB" 2>/dev/null; then
        return 1  # tidak unik
    fi
    return 0  # unik
}

# CHECK TAGIHAN (dipanggil oleh cron)

if [ "$1" == "--check-tagihan" ]; then
    mkdir -p log
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    found=0
while IFS=',' read -r nama kamar harga tanggal status; do
        [ "$nama" == "nama" ] && continue
        if [ "$status" == "Menunggak" ]; then
            echo "[$timestamp] TAGIHAN: $nama (Kamar $kamar) - Menunggak Rp$harga" >> "$LOG"
            found=1
        fi
    done < "$DB"
    [ $found -eq 0 ] && echo "[$timestamp] TAGIHAN: Tidak ada penghuni menunggak." >> "$LOG"
    exit 0
fi

# OPSI 1: TAMBAH PENGHUNI

tambah_penghuni() {
    echo "=============================================="
    echo "            TAMBAH PENGHUNI"
    echo "=============================================="

    # Nama
    read -p "Masukkan Nama: " nama
    if [ -z "$nama" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Kamar
    while true; do
        read -p "Masukkan Kamar: " kamar
        if ! echo "$kamar" | grep -qE '^[0-9]+$'; then
            echo "[!] Nomor kamar harus angka."
            continue
        fi
        if ! kamar_unik "$kamar"; then
            echo "[!] Kamar $kamar sudah terisi. Pilih kamar lain."
            continue
        fi
        break
    done

    # Harga Sewa
    while true; do
        read -p "Masukkan Harga Sewa: " harga
        if ! echo "$harga" | grep -qE '^[0-9]+$' || [ "$harga" -le 0 ]; then
            echo "[!] Harga sewa harus angka positif."
            continue
        fi
        break
    done

    # Tanggal Masuk
    while true; do
        read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tgl
        validasi_tanggal "$tgl"
        case $? in
            1) echo "[!] Format tanggal salah. Gunakan YYYY-MM-DD." ;;
            2) echo "[!] Tanggal tidak boleh melebihi hari ini." ;;
            0) break ;;
        esac
    done

    # Status
    while true; do
        read -p "Masukkan Status Awal (Aktif/Menunggak): " status
        # Kapitalisasi huruf pertama
        status="$(echo "$status" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
        if [ "$status" != "Aktif" ] && [ "$status" != "Menunggak" ]; then
            echo "[!] Status harus 'Aktif' atau 'Menunggak'."
            continue
        fi
        break
    done

    echo "$nama,$kamar,$harga,$tgl,$status" >> "$DB"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# OPSI 2: HAPUS PENGHUNI

hapus_penghuni() {
    echo "=============================================="
    echo "            HAPUS PENGHUNI"
    echo "=============================================="

    read -p "Masukkan nama penghuni yang akan dihapus: " nama_hapus

    # Cek apakah ada
    if ! awk -F',' -v n="$nama_hapus" 'NR>1 && $1==n {found=1} END {exit !found}' "$DB"; then
        echo "[!] Penghuni \"$nama_hapus\" tidak ditemukan."
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    local today
    today=$(date +%Y-%m-%d)

    # Arsipkan ke sampah
    awk -F',' -v n="$nama_hapus" -v d="$today" \
        'NR>1 && $1==n {print $0","d}' "$DB" >> "$SAMPAH"

    # Hapus dari DB (simpan header + baris yang bukan nama_hapus)
    awk -F',' -v n="$nama_hapus" \
        'NR==1 || $1!=n' "$DB" > /tmp/db_tmp.csv && mv /tmp/db_tmp.csv "$DB"

    echo ""
    echo "[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# OPSI 3: TAMPILKAN DAFTAR PENGHUNI

tampil_daftar() {
    echo "=============================================="
    echo "       DAFTAR PENGHUNI KOST SLEBEW"
    echo "=============================================="

    awk -F',' '
    BEGIN {
        printf "%-4s| %-15s| %-7s| %-15s| %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
        print "------------------------------------------------------"
        no=0; aktif=0; nunggak=0
    }
    NR==1 { next }
    {
        no++
        harga_fmt = sprintf("Rp%\047d", $3)
        printf "%-4s| %-15s| %-7s| %-15s| %s\n", no, $1, $2, harga_fmt, $5
        print "------------------------------------------------------"
        if ($5=="Aktif") aktif++
        else nunggak++
    }
    END {
        printf "\nTotal: %d penghuni | Aktif: %d | Menunggak: %d\n", no, aktif, nunggak
        print "=============================================="
    }
    ' "$DB"

    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# OPSI 4: UPDATE STATUS

update_status() {
    echo "=============================================="
    echo "              UPDATE STATUS"
    echo "=============================================="

    read -p "Masukkan Nama Penghuni: " nama_update

    if ! awk -F',' -v n="$nama_update" 'NR>1 && $1==n {found=1} END {exit !found}' "$DB"; then
        echo "[!] Penghuni \"$nama_update\" tidak ditemukan."
        read -p "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    while true; do
        read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
        status_baru="$(echo "$status_baru" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
        if [ "$status_baru" != "Aktif" ] && [ "$status_baru" != "Menunggak" ]; then
            echo "[!] Status harus 'Aktif' atau 'Menunggak'."
            continue
        fi
        break
    done

    awk -F',' -v n="$nama_update" -v s="$status_baru" 'OFS=","{
        if (NR>1 && $1==n) $5=s
        print
    }' "$DB" > /tmp/db_tmp.csv && mv /tmp/db_tmp.csv "$DB"

    echo ""
    echo "[√] Status $nama_update berhasil diubah menjadi: $status_baru"
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# OPSI 5: LAPORAN KEUANGAN

laporan_keuangan() {
    echo "=============================================="
    echo "      LAPORAN KEUANGAN KOST SLEBEW"
    echo "=============================================="

    awk -F',' '
    NR==1 { next }
    {
        kamar_terisi++
        if ($5=="Aktif") pemasukan += $3
        else tunggakan += $3
        if ($5=="Menunggak") nunggak_list = nunggak_list "  " $1 " (Kamar " $2 ") - Rp" $3 "\n"
    }
    END {
        printf "%-25s: Rp%d\n", "Total pemasukan (Aktif)", pemasukan
        printf "%-25s: Rp%d\n", "Total tunggakan", tunggakan
        printf "%-25s: %d\n", "Jumlah kamar terisi", kamar_terisi
        print "----------------------------------------------"
        print "Daftar penghuni menunggak:"
        if (nunggak_list == "") print "  Tidak ada tunggakan."
        else printf "%s", nunggak_list
        print "\n=============================================="
    }
    ' "$DB"

    # Simpan ke file
    {
        echo "LAPORAN KEUANGAN KOST SLEBEW"
        echo "Tanggal: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================================="
        awk -F',' '
        NR==1 { next }
        {
            kamar_terisi++
            if ($5=="Aktif") pemasukan += $3
            else tunggakan += $3
            if ($5=="Menunggak") nunggak_list = nunggak_list "  " $1 " (Kamar " $2 ") - Rp" $3 "\n"
        }
        END {
            printf "Total pemasukan (Aktif) : Rp%d\n", pemasukan
            printf "Total tunggakan         : Rp%d\n", tunggakan
            printf "Jumlah kamar terisi     : %d\n", kamar_terisi
            print "----------------------------------------------"
            print "Daftar penghuni menunggak:"
            if (nunggak_list == "") print "  Tidak ada tunggakan."
            else printf "%s", nunggak_list
        }
        ' "$DB"
    } > "$REKAP"

    echo ""
    echo "[√] Laporan berhasil disimpan ke $REKAP"
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

# OPSI 6: KELOLA CRON

kelola_cron() {
    while true; do
        echo "================================"
        echo "       MENU KELOLA CRON"
        echo "================================"
        echo " 1. Lihat Cron Job Aktif"
        echo " 2. Daftarkan Cron Job Pengingat"
        echo " 3. Hapus Cron Job Pengingat"
        echo " 4. Kembali"
        echo "================================"
        read -p "Pilih [1-4]: " pilih_cron

        case $pilih_cron in
            1)
                echo ""
                echo "--- Daftar Cron Job Pengingat Tagihan ---"
                crontab -l 2>/dev/null | grep "kost_slebew.sh --check-tagihan" || echo "  (Tidak ada cron job aktif)"
                echo ""
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            2)
                read -p "Masukkan Jam (0-23): " jam
                read -p "Masukkan Menit (0-59): " menit

                # Validasi jam & menit
                if ! echo "$jam" | grep -qE '^[0-9]+$' || [ "$jam" -lt 0 ] || [ "$jam" -gt 23 ]; then
                    echo "[!] Jam tidak valid."
                    read -p "Tekan [ENTER]..."
                    continue
                fi
                if ! echo "$menit" | grep -qE '^[0-9]+$' || [ "$menit" -lt 0 ] || [ "$menit" -gt 59 ]; then
                    echo "[!] Menit tidak valid."
                    read -p "Tekan [ENTER]..."
                    continue
                fi

                # Format 2 digit
                jam=$(printf "%02d" "$jam")
                menit=$(printf "%02d" "$menit")

                # Hapus cron lama, tambah yang baru (overwrite)
                ( crontab -l 2>/dev/null | grep -v "kost_slebew.sh --check-tagihan"
                  echo "$menit $jam * * * $SCRIPT_PATH --check-tagihan"
                ) | crontab -

                echo ""
                echo "[√] Cron job pengingat tagihan berhasil didaftarkan pukul $jam:$menit."
                echo ""
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            3)
                ( crontab -l 2>/dev/null | grep -v "kost_slebew.sh --check-tagihan" ) | crontab -
                echo ""
                echo "[√] Cron job pengingat tagihan berhasil dihapus."
                echo ""
                read -p "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            4)
                break
                ;;
            *)
                echo "[!] Pilihan tidak valid."
                ;;
        esac
    done
}

# MAIN MENU LOOP

while true; do
    tampil_header
    echo " ID | OPTION"
    echo "--------------------------------------------"
    echo "  1 | Tambah Penghuni Baru"
    echo "  2 | Hapus Penghuni"
    echo "  3 | Tampilkan Daftar Penghuni"
    echo "  4 | Update Status Penghuni"
    echo "  5 | Cetak Laporan Keuangan"
    echo "  6 | Kelola Cron (Pengingat Tagihan)"
    echo "  7 | Exit Program"
    echo "=============================================="
    read -p "Enter option [1-7]: " pilihan

    case $pilihan in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampil_daftar ;;
        4) update_status ;;
        5) laporan_keuangan ;;
        6) kelola_cron ;;
        7)
            echo ""
            echo "Sampai jumpa! Terima kasih telah menggunakan Kost Slebew Manager."
            echo ""
            exit 0
            ;;
        *)
            echo "[!] Pilihan tidak valid. Masukkan angka 1-7."
            sleep 1
            ;;
    esac
done
```

### Cara Penggunaan

```bash
# Jalankan program utama
./kost_slebew.sh

# (Otomatis oleh cron) Cek tagihan
./kost_slebew.sh --check-tagihan
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
No  | Nama           | Kamar  | Harga Sewa     | Status
------------------------------------------------------
1   | Mas Rusdi      | 2      | Rp600000       | Menunggak
------------------------------------------------------
2   | acha           | 12     | Rp500000       | Aktif
------------------------------------------------------

Total: 2 penghuni | Aktif: 1 | Menunggak: 1
==============================================
```

**Laporan Keuangan:**

```
Total pemasukan (Aktif)  : Rp500000
Total tunggakan          : Rp600000
Jumlah kamar terisi      : 2
----------------------------------------------
Daftar penghuni menunggak:
  Mas Rusdi (Kamar 2) - Rp600000
```

**Log Tagihan (`tagihan.log`):**

```
[2026-03-29 07:00:01] TAGIHAN: Mas Rusdi (Kamar 2) - Menunggak Rp600000
```                            
