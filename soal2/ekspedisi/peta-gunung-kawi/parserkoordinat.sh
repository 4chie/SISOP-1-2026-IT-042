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
