#! /usr/bin/bash


if [ "$#" -ne "1" ]
then
echo 'Introduce file with message to pad'
  echo "$0 file"
  exit 1
else


echo "Getting message padded from $1 (into padded.dat)"
total_bytes=`wc -c $1 | cut -f1 -d" "`
padding=$(( 16 - ($total_bytes%16) ))

cat $1 > padded.dat

for (( i=0; i<$padding; i++ ))
do
	printf "\x$(printf "%02x" "$padding")" >> padded.dat
done
fi
