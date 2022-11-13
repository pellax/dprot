#! /usr/bin/bash

if [ "$#" -ne "1" ]
then
echo 'Introducir directorio con los archivos de datos, del tipo: bytes_zzffxx.dat'
  echo "$0 directorio"
  exit 1
else

z=0x01
iv=${z}ff00
key=${iv}${parcial_key}

guessed_message=""
guessed_key=()


echo -n > results.txt
for (( i=-1; i<=12; i++ ))
do
	iv=`printf "%02x" $z`ff00
	Z=`printf "%02x" $z`

	echo -n '' > $1/results.dat


if [[ $i -eq -1 ]] # FACT 1, IF IV=01FFxx
then
	echo -n "   Guessing m[0] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#Message compute with Ciphertext - Fact 1
		r=0x`printf '%x' $(( ($x+2)%256 ))` #R[0]=x+2
		printf '%x\n'  $(( $r ^ $cipher)) >> $1/results.dat #Compute m[0]=R[0] xor C[0]
	done < $1/bytes_01ffxx.dat 

	echo "done"
	guessed_message=0x`cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 2`
	echo -n -e "\tGuessed m[0]=$guessed_message with freq. \t"

	cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 1

elif [[ $i -eq 0 ]] # FACT 2, IF IV=03FFxx
then
	echo -n "   Guessing k[0] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#K[0] compute with Ciphertext - Fact 2
		r=0x`printf '%x' $(( -$x -6 ))`
		printf '%x\n'  $(( (($cipher ^ $guessed_message) + $r) & 0xff )) >> $1/results.dat 
	done < $1/bytes_03ffxx.dat 

	echo "done"
	value=0x`cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 2`
	guessed_key+=("$value")
	echo -n -e "\tGuessed k[0]=${guessed_key[0]} with freq. \t"
	cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 1

elif [[ $i -eq 1 ]] # FACT 2, IF IV=04FFxx
then
	echo -n "   Guessing k[1] ... "
	while IFS= read -r line
	 do 
		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		#K[1] compute with Ciphertext - Fact 2
		r=0x`printf '%x' $(( -$x -10 - ${guessed_key[0]} ))` 
		printf '%x\n'  $(( (($cipher ^ $guessed_message) + $r) & 0xff )) >> $1/results.dat 
	done < $1/bytes_04ffxx.dat 

	echo "done"
	value=0x`cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 2`
	guessed_key+=("$value")
	echo -n -e "\tGuessed k[1]=${guessed_key[1]} with freq. \t"
	cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 1

else # FACT 3, IF IV=zFFx

	echo -n "   Guessing k[$(( $z-3 ))] ... "
	while IFS= read -r line
	 do 

		x=0x`echo -n $line | cut -c 7,8`
		cipher=`echo -n $line | cut -c 10,11,12,13`

		d=0 #for i ranging from 0 to 12, d[i]=sum(i+3), where iv=z FF x and z=i+3

		for (( j = 1; j <= $z ; j++ ))
		do
			d=$(( $d + $j ))
		done

		key_sum=0
	
		for value in ${guessed_key[@]}
		do
		  	key_sum=$(( $key_sum + $value )) #previous keys guessed are added
		done

		r=0x`printf '%02x' $(( -$x -$d - $key_sum ))` 
		printf '%02x\n'  $(( (($cipher ^ $guessed_message) + $r) & 0xff )) >> $1/results.dat 
	done < $1/bytes_${Z}ffxx.dat 

	echo "done"
	value=0x`cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 2`
	guessed_key+=("$value")
	echo -n -e "\tGuessed k[$(( $z-3 ))]=${guessed_key[$(( $z-3 ))]} with freq. \t"
	cat $1/results.dat | sort | uniq -c -d | sort | tail -1 | awk '{print $1, $2}' | cut -d ' ' -f 1

fi

	z=0x`printf "%02x" $(($i+4))`
done

guessed_message=`echo -n $guessed_message | cut -c 3-`

for i in "${!guessed_key[@]}"; do
        guessed_key[$i]=`echo -n ${guessed_key[$i]} | cut -c 3-`
done


echo -n "Guessed message is : $guessed_message, with the key : " 
printf '%s' "${guessed_key[@]}"
echo ""


fi

