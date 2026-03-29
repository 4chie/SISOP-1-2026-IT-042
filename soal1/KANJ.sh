BEGIN {
    FS ="," # membaca csv
    mode = ARGV[2]
    delete ARGV[2]
}
    NR==1 {next} # skip header
{
	# hitung penumpang (a)
	{ gsub(/\r/, "", $4) }
	count_passenger++

	# jumlah  gerbong (b)
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
