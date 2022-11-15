#!/bin/bash
for (( i = 0; i < 10; i++))
do
    echo "hello$i" > "./docs/doc"$i".dat"
done
division=2
factor=10
prefixnode=0xE8
prefixdoc=0x35
echo -n "$prefixnode" | xxd -p  > ./docs/node.pre
echo -n "$prefixdoc" | xxd -p  > ./docs/doc.pre
echo -n "MerkleeTree:sha1:" >> hashtree.txt
cat ./docs/node.pre | tr -d '\n' >> hashtree.txt
echo -n ":" >> hashtree.txt
cat ./docs/doc.pre | tr -d '\n' >> hashtree.txt
echo -n ":$factor:" >> hashtree.txt
echo -n "5:linux" >> hashtree.txt
echo -e '' >> hashtree.txt
#concatenate prefix to doc
for ((i = 0; i < $factor; i++))
do
	cat ./docs/doc.pre ./docs/doc$i.dat | openssl dgst -sha1 -binary | xxd -p > "./nodes/node0.$i"
	echo -n "0:$i:" >> hashtree.txt 
	cat ./nodes/node0.$i >> hashtree.txt
done
for (( i = 0; i < 4;i++ ))
do
	for (( j = 0; j <= $factor;j++ ))
	do	
		if [[ -f "./nodes/node$i.$(( 2*$j+1 ))" && -f "./nodes/node$i.$(( 2*$j ))" ]]
		then 
			cat ./docs/node.pre ./nodes/node$i.$(( 2*$j )) ./nodes/node$i.$(( 2*$j+1 )) | openssl dgst -sha1 -binary | xxd -p > "./nodes/node$(( $i+1 )).$j"
			echo -n "$(( $i+1 )):$j:" >> hashtree.txt
		        cat ./nodes/node$(( $i+1 )).$j >> hashtree.txt	
		        cat ./nodes/node$(( $i+1 )).$j 	
		elif [[ -f "./nodes/node$i.$((2*$j))" ]]	
		then
			cat ./docs/node.pre ./nodes/node$i.$(( 2*$j ))  | openssl dgst -sha1 -binary | xxd -p > "./nodes/node$(( $i+1 )).$j" 
			echo -n "$(( $i+1 )):$j:" >> hashtree.txt
		        cat ./nodes/node$(( $i+1 )).$j >> hashtree.txt	
		        cat ./nodes/node$(( $i+1 )).$j	
		fi 	
	done

	factor=$(( $factor/$division ))
	echo "$factor"
done
hash=$( cat ./nodes/node4.0 )  
sed -i "1 s/linux/$hash/1" hashtree.txt
