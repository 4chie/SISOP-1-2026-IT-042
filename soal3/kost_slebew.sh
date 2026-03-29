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
