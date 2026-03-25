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
