#!/bin/bash
for (( i = 0; i < 10; i++))
do
    echo "hello$i" > "./docs/doc"$i".dat"
done
division=2
factor=10
prefixnode=0xE8
prefixdoc=0x35
echo "$prefixnode" > ./docs/node.pre
echo "$prefixdoc" > ./docs/doc.pre
#concatenate prefix to doc
for ((i = 0; i < $factor; i++))
do
	cat ./docs/doc.pre ./docs/doc$i.dat | openssl dgst -sha1 -binary | xxd -p > "./nodes/node0.$i"
	echo -n "0:$i:" >> hashtree.txt 
	cat ./nodes/node0.$i >> hashtree.txt
done
for (( i = 0; i <= 4;i++ ))
do
	for (( j = 0; j < $factor;j++ ))
	do	
		if [[ -f "./nodes/node$i.$(( 2*$j+1 ))" && -f "./nodes/node$i.$(( 2*$j ))" ]]
		then 
			cat ./docs/node.pre ./nodes/node$i.$(( 2*$j )) ./nodes/node$i.$(( 2*$j+1 )) | openssl dgst -sha1 -binary | xxd -p > "./nodes/node$(( $i+1 )).$j"
			echo -n "$(($i+1)):$j: " >> hashtree.txt
		        cat ./nodes/node$(( $i+1 )).$j >> hashtree.txt	
		elif [[ -f "./node/node$i.$(( 2*$j ))" ]]	
		then
			cat ./docs/node.pre ./nodes/node$i.$(( 2*$j ))  | openssl dgst -sha1 -binary | xxd -p > "./nodes/node$(( $i+1 )).$j" 
			echo -n "$(($i+1)):$j: " >> hashtree.txt
		        cat ./nodes/node$(( $i+1 )).$j >> hashtree.txt	
		fi 	
	done

	factor=$(( $factor/$division ))
	echo "$factor"
done

