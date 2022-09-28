#! /usr/bin/bash


m=90 #ASCII messsage
iv=05ff00
parcial_key=7e1a0bbc8c770667be44dce10c
key=${iv}${parcial_key}

echo -n > results.txt

for (( i=0; i<256; i++ ))
do

	#Encription call with given IV
	key=${iv}${parcial_key}
	echo -n 0x$iv ''
	cipher=0x`echo -n -e '\x'$m | openssl enc -K $key -rc4 | xxd | cut -d ' '  -f 2 | cut -d ' ' -f 1 | head -c2`
	echo $cipher

	#Message compute with Ciphertext - Fact 1 (WORKING)
	#r=0x`printf '%x' $(( ($i+2)%256 ))` #R[0]=x+2
	#printf '%x\n'  $(( $r ^ $cipher)) >> results.txt #Compute m[0]=R[0] xor C[0]

	#K[0] compute with Ciphertext - Fact 2 (WORKING)
	#r=0x`printf '%x' $(( -$i -6 ))`
	#printf '%x\n'  $(( (($cipher ^ 0x90) + $r) & 0xff )) >> results.txt #m[0]=0x39

	#K[1] compute with Ciphertext - Fact 2 (WORKING)
	#r=0x`printf '%x' $(( -$i -10 - 0x7e ))` #k[0]=0x7e
	#printf '%x\n'  $(( (($cipher ^ 0x90) + $r) & 0xff )) >> results.txt #m[0]=0x39

	#K[2] compute with Ciphertext - Fact 3 #TODO
	d=0x`printf '%02x' $(( 2 + 3 ))` #for i ranging from 0 to 12, d[i]=i+3, where iv=z FF x and z=i+3
	r=0x`printf '%02x' $(( -$i -$d - 0x7e - 0x1a ))` #k[0]=0x7e k[1]=1a
	printf '%02x\n'  $(( (($cipher ^ 0x90) + $r) & 0xff )) >> results.txt #m[0]=0x39


	iv=$(( 16#$iv + 0x1 )) #Increase IV
	iv=0`printf "%x" $iv`

	#iv=01ff`printf "%02x" $i`
done



#NEW_BASE=$(( $BASE + $OFFSET ))

#NEW_BASE=`printf "0x%x\n" $NEW_BASE`

#cat results.txt | sort | uniq -c -d | sort | tail -1 | cut -c 6-


