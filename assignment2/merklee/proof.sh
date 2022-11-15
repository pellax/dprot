#!/bin/bash
if [[ $# -ne 3 ]]
then 
	echo "Wrong number of parameters, first parameter is the position, secondo parameter is the node you want to build the proof for, third is the number of docs "
else
for (( i = 0; i < 10; i++))
do
    echo "hello$i" > "./docs/doc"$i".dat"
done
division=2
factor=$3
prefixnode=0xE8
prefixdoc=0x35
echo -n "$prefixnode" | xxd -p  > ./docs/node.pre
echo -n "$prefixdoc" | xxd -p  > ./docs/doc.pre
echo -n "MerkleeTree:sha1:" >> proof.txt
cat ./docs/node.pre | tr -d '\n' >> proof.txt
echo -n ":" >> proof.txt
cat ./docs/doc.pre | tr -d '\n' >> proof.txt
echo -n ":$factor:" >> proof.txt
echo -n "5:linux" >> proof.txt
echo -e '' >> proof.txt
position=$1
#concatenate prefix to doc
for ((i = 0; i < $factor; i++))
do      
	if [[ $i -eq $position ]]
	then 
		cat ./docs/doc.pre $2 | openssl dgst -sha1 -binary | xxd -p > "./nodes/newnode0.$i"
		echo -n "0:$i:" >> proof.txt
		cat ./nodes/newnode0.$i >> proof.txt
	else
	cat ./docs/doc.pre ./docs/doc$i.dat | openssl dgst -sha1 -binary | xxd -p > "./nodes/node0.$i"
	echo -n "0:$i:" >> proof.txt 
	cat ./nodes/node0.$i >> proof.txt
	fi
done
		        
sed -i "1 s/linux/$(cat hashtree.txt | grep "^MerkleeTree" | cut -d : -f 7)/1" proof.txt
fi
