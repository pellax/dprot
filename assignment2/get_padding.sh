#! /usr/bin/bash


echo "Getting message padded of mess1.dat (into padded.dat)"
total_bytes=`wc -c mess1.dat | cut -f1 -d" "`
padding=$(( 16 - ($total_bytes%16) ))

cat mess1.dat > padded.dat

for (( i=0; i<$padding; i++ ))
do
	printf "\x$(printf "%02x" "$padding")" >> padded.dat
done
