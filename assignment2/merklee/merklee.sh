#!/bin/bash
for i in {0..10}
do
    echo hello > "./docs/doc$(printf "%03d" "$i").dat"
done
factor = 10
prefixnode = 0xE8
prefixdoc = 0x35
echo $prefixnode >> ./docs/node.pre
echo $prefixdoc >> ./docs/doc.pre
#concatenate prefix to doc
for i in {0..$factor}
do
	cat doc.pre ./docs/doc$i.dat | openssl dgst -sha1 -binary > ./nodes/node0.$i
done
for i in {0..3}
do
	for j in {0..$factor}
	do	
		if test -f ./nodes$i.${2*j+1}
		then 
			cat ./docs/node.pre ./nodes/node$i.${2*j} ./nodes/node$i.${2*j+1} | openssl dgst -sha1 -binary > ./nodes/node${i+1}.$j
		else	
			cat ./docs/node.pre ./nodes/node$i.${2*j}  | openssl dgst -sha1 -binary > ./nodes/node${i+1}.$j
	
	factor = $(($factor / 2))
	echo $factor
