if [[ "$#" -ne 2 ]] 
then
    echo "Illegal number of parameters, first parameter defines k position of the check leaf, second parameter is the path of the node you want to check"
fi
cat ./docs/doc.pre $2 | openssl dgst -sha1 -binary | xxd -p  > ./nodes/verifynode0.$1
oldroot="$(( cat hashtree.txt | grep "MerkleeTree" | cut -d : -f 7 ))"

if [[ (( $1 % 2 )) eq 0 ]]
then
	i=0
	newleaf="$(( cat ./nodes/verifynode0.$1 ))"
	#Make copy of the hashtree
	cat hashtree.txt > proof.txt # copy the hash tree 
	line="$(( cat proof.txt | grep 0:$1 ))"
	sed -i "s/$line/0:$1:$newleaf/g" proof.txt #substitute the line with the new leaf now lets recalculate the merklee tree
        for (( i = 0 ; i < 5; i++ ))
	do
		for (( j = 0; j < $factor; j++ ))
		do
			if [[ $(( cat proof.txt | grep -q "$i:$(( 2*$j ))" )) &&  $(( cat proof.txt | grep -q "i:$((2*$j+1 ))" )) ]]; # we have two nodes
			then
				newhash="$(( cat proof.txt | grep -- "$i:$(( 2*$j ))\|$i:$(( 2*$j+1 ))" | cut -d : -f 3 | tr -d '\n' | openssl dgst -sha1 -binary | xxd -p ))" 
				sed -i "s/$(( cat proof.txt | grep "$(( $i+1 )):$j" | cut -d : -f 3 ))/$newhash/g" proof.txt #substitute the hash in the merklee tree
			elif [[ $(( cat proof.txt | grep -q "$i:$(( 2*$j ))" )) ]]; #we have one node
			then
				newhash="$(( cat proof.txt | grep "$i:$(( 2*$j ))" | cut -d : -f 3 | openssl dgst -sha1 -binary | xxd -p ))" #get new node hash
			        sed -i "s/$(( cat proof.txt | grep "$(( $i+1 )).$j" | cut -d : -f 3 ))/$newhash/g " proof.txt
		         fi
		 done
		factor=$(( $factor/2 ))
		echo "$factor"
	done
	sed -i "s/$oldroot/$(( cat proof.txt | grep "4:0" | cut -d : -f 3 ))/g" proof.txt
	if [[ "$(( cat proof.txt | grep "MerkleeTree" | cut -d : -f 7 ))" eq $oldroot ]]
	then
	echo "Verification ok" >> proof.txt
	else
		echo "Verification ko" >> proof.txt
	fi

elif [[ (($1 % 2 )) eq 1 ]]#odd case
then 

	i=0
	newleaf="$(( cat ./nodes/verifynode0.$1 ))"
	#Make copy of the hashtree
	cat hashtree.txt > proof.txt 
	line="$(( cat proof.txt | grep 0:$1 ))"
	sed -i "s/$line/0:$1:$checknode/g" proof.txt #substitute the line with the new leaf now lets recalculate the merklee tree
        for (( i = 0 ; i < 5; i++ ))
	do
		for (( j = 0; j < $factor; j++ ))
		do
			if [[ $(( cat proof.txt | grep -q "$i:$(( 2*$j ))" )) && !-z $(( cat proof.txt | grep -q "i:$((2*$j+1 ))" )) ]] # we have two nodes
			then
				newhash="$(( cat proof.txt | grep -- "$i:$(( 2*$j ))\|$i:$(( 2*$j+1 ))" | cut -d : -f 3 | tr -d '\n' | openssl dgst -sha1 -binary | xxd -p ))" 
				sed -i "s/$(( cat proof.txt | grep "$(( $i+1 )):$j" | cut -d : -f 3 ))/$newhash/g" proof.txt #substitute the hash in the merklee tree
			elif [[ $(( cat proof.txt | grep -q "$i:$(( 2*$j ))" )) ]] #we have one node
			then
				newhash="$(( cat proof.txt | grep "$i:$(( 2*$j ))" | cut -d : -f 3 | openssl dgst -sha1 -binary | xxd -p ))" #get new node hash
			        sed -i "s/$(( cat proof.txt | grep "$(( $i+1 )).$j" | cut -d : -f 3 ))/$newhash/g " proof.txt
		         fi
		 done
		factor=$(( $factor/2 ))
		echo "$factor"
	done
	sed -i "s/$oldroot/$(( cat proof.txt | grep "4:0" | cut -d : -f 3 ))/g" proof.txt
	if [[ "$(( cat proof.txt | grep "MerkleeTree" | cut -d : -f 7 ))" eq $oldroot ]]
	then
	echo "Verification ok" >> proof.txt
	else
		echo "Verification ko" >> proof.txt
        fi
fi


