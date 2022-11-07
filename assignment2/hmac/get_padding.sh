#! /usr/bin/bash


if [ "$#" -ne "1" ]
then

	echo 'Introduce file with message to pad (mess)'
 	echo "$0 file"
  	exit 1

else

	echo "Getting message padded from $1 (into new_data_padded.dat)"
	cat $1 > new_data_padded.dat

	block_size=$(( 512 ))
	mandatory_bytes=9
	mandatory_bits=$mandatory_bytes*8
	total_bytes=`wc -c $1 | cut -f1 -d" "`
	total_bits=$(( $total_bytes*8 ))
	lastblock_bits=$(( $total_bits % $block_size ))
	lastblock_bytes=$(( $lastblock_bits / 8 ))
	bytes_available=$(( $block_size/8 - $lastblock_bytes ))
	total_bits=$(( $total_bits ))
	
	if [[ $lastblock_bits -eq 0 || $lastblock_bits -le $(( $block_size - $mandatory_bits )) ]] #LAST BLOCK IS COMPLETED (64 BYTES) or FITS MANDATORY PADDING (9 BYTES)
	then

		necessary_zeros=$(( $bytes_available - $mandatory_bytes ))

		printf "\x$(printf "%02x" "128")" >> new_data_padded.dat #APPEND 0x80
		for run in $( seq 1 $necessary_zeros ); do printf "\\x$(printf "%x" "0")"; done >> new_data_padded.dat #APPEND NECESSARY 0x00
		echo 00: `printf "%016x" $total_bits` | xxd -r | xxd -g 8 -e | xxd -r >> new_data_padded.dat #APPEND SIZE in LITTLE-ENDIAN (8 BYTES)

	elif [[ $lastblock_bits -gt $(( $block_size - $mandatory_bits )) && $lastblock_bits -lt $block_size ]] #LAST BLOCK DOESN'T FIT MANDATORY PADDING
	then

		necessary_zeros=$(( $bytes_available - 1 ))

		printf "\x$(printf "%02x" "128")" >> new_data_padded.dat #APPEND 0x80
		for run in $( seq 1 $necessary_zeros ); do printf "\\x$(printf "%x" "0")"; done >> new_data_padded.dat  #APPEND NECESSARY 0x00 TO FINISH BLOCK

		#--BLOCK FINISHED-- 

		for run in {1..56}; do printf "\\x$(printf "%x" "0")"; done >> new_data_padded.dat  #APPEND 56 BYTES OF 0x00 TO FINISH BLOCK
		echo 00: `printf "%016x" $total_bits` | xxd -r | xxd -g 8 -e | xxd -r >> new_data_padded.dat #APPEND SIZE in LITTLE-ENDIAN (8 BYTES)


	fi
fi
