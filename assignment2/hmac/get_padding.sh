#! /usr/bin/bash


if [ "$#" -ne "1" ]
then

	echo 'Introduce file with message to pad (key+mess)'
 	echo "$0 file"
  	exit 1

else

	echo "Getting message padded from $1 (into padded.dat)"
	block_size=512
	total_bytes=`wc -c $1 | cut -f1 -d" "`
	total_bits=$(( $total_bytes*8 ))
	lastblock_bits=$(( $total_bits % $block_size ))
	lastblock_bytes=$(( $lastblock_bits / 8 ))
	
	if [[ $lastblock_bits -eq 0 ]]
	then
		printf "\x$(printf "%02x" "128")" >> padded.dat
		for run in {1..55}; do printf "\\x$(printf "%x" "0")"; done >> padded.dat
		printf "%016x" $total_bits | xxd -r -p >> padded.dat

	elif [[$lastblock_bits -gt $(( $block_size - 65 )) && $lastblock_bit -lt $block_size ]]
	then

	elif [[$lastblock_bit -le $(( $block_size - 65 )) ]]
	then
		necessary_zeros=$(( $block_size - $lastblock_bits - 65))

	fi

fi
