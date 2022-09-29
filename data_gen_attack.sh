#! /usr/bin/bash


m=90 #ASCII messsage
z=0x01
iv=${z}ff00
parcial_key=7e1a0bbc8c770667be44dce10c
key=${iv}${parcial_key}

echo -n > results.txt
for (( i=-1; i<=12; i++ ))
do
	iv=`printf "%02x" $z`ff00
	Z=`printf "%02x" $z`
	echo -n '' > gathered/bytes_${Z}ffxx.dat
	echo -n '' > gathered/results.dat
	echo -n "Gathering keystream first bytes for IV=${Z}ffxx ... "
for (( x=0; x<256; x++ ))
do
	#Encription call with given IV
	key=${iv}${parcial_key}
	echo -n 0x$iv '' >> gathered/bytes_${Z}ffxx.dat
	cipher=0x`echo -n -e '\x'$m | openssl enc -K $key -rc4 | xxd | cut -d ' '  -f 2 | cut -d ' ' -f 1 | head -c2` >> gathered/bytes_${Z}ffxx.dat
	echo $cipher >> gathered/bytes_${Z}ffxx.dat


	iv=`printf "%02x" $z`ff`printf "%02x" $(($x+1))`
done
	echo "done"

if [[ $i -eq -1 ]] # FACT 1, IF IV=01FFxx
then
	echo -n "Guessing m[0] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#Message compute with Ciphertext - Fact 1
		r=0x`printf '%x' $(( ($x+2)%256 ))` #R[0]=x+2
		printf '%x\n'  $(( $r ^ $cipher)) >> gathered/results.dat #Compute m[0]=R[0] xor C[0]
	done < gathered/bytes_01ffxx.dat 

	echo "done"
	echo -n -e "\tGuessed m[0] "
	cat gathered/results.dat | sort | uniq -c -d | sort | tail -1 | cut -c 6-

elif [[ $i -eq 0 ]]
then
	echo -n "Guessing k[0] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#K[0] compute with Ciphertext - Fact 2
		r=0x`printf '%x' $(( -$x -6 ))`
		printf '%x\n'  $(( (($cipher ^ 0x90) + $r) & 0xff )) >> gathered/results.dat #m[0]=0x39
	done < gathered/bytes_03ffxx.dat 

	echo "done"
	echo -n -e "\tGuessed k[0] "
	cat gathered/results.dat | sort | uniq -c -d | sort | tail -1 | cut -c 6-

elif [[ $i -eq 1 ]]
then
	echo -n "Guessing k[1] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#K[1] compute with Ciphertext - Fact 2
		r=0x`printf '%x' $(( -$x -10 - 0x7e ))` #k[0]=0x7e
		printf '%x\n'  $(( (($cipher ^ 0x90) + $r) & 0xff )) >> gathered/results.dat #m[0]=0x39
	done < gathered/bytes_04ffxx.dat 

	echo "done"
	echo -n -e "\tGuessed k[1] "
	cat gathered/results.dat | sort | uniq -c -d | sort | tail -1 | cut -c 6-
else
	echo -e "\tapply fact 3"

fi

	z=0x`printf "%02x" $(($i+4))`
done


#while IFS= read -r line; do echo -n $line | cut -d ' ' -f 1; done < gathered/bytes_01ffxx.dat 

#| cut -c 12,13 7,8
