#!/bin/bash
if [[ $# -ne 3 ]]
then 
	echo "Wrong number of parameters, first parameter is the position, secondo parameter is the doc you want to build the proof for, third is the number of docs "
else
division=2
for (( i = 0; i < $3; i++))
do
    echo "hello$i" > "./docs/doc"$i".dat"
done
temp=$3
height=0
d=$(echo "sqrt($temp)" | bc)
if [[ $d=~^[0-9] ]]
then
        ((temp-=1))
fi
while [ $temp -gt 0 ]
do
        temp=$(( $temp/$division ))
        ((height+=1))
done

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
echo -n "$(( $height+1 )):linux" >> proof.txt
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
