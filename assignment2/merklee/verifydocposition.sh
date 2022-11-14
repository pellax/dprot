if [[ "$#" -ne 1 ]] 
then
    echo "Illegal number of parameters, first parameter defines the number of docs"
else
	factor=$1
	half=2


	oldroot="$( cat proof.txt | grep "MerkleeTree" | cut -d : -f 7 )" #this position holds the original hash of the original merklee tree
	echo "right way"

	elem=$factor
	

		
	echo "no entra"
		
	#Make copy of the hashtree
	cat proof.txt > verify.txt  # copy the hash tree 
	line="$( cat proof.txt | grep 0:$1 )"
	cat verify.txt
	#sed -i "s/$line/0:$1:$newleaf/g" proof.txt #substitute the line with the new leaf now lets recalculate the merklee tree
	for (( i = 0; i < $(( $elem/$half )); i++ )) # taking the original file lets build the whole tree and calculate the hash
	do
		for (( j = 0; j <= $factor; j++ ))
		do	
			if [[ "$( cat verify.txt | grep -q "$i:$(( 2*$j )):" )" -eq 0 && "$( cat verify.txt | grep -q "$i:$(( 2*$j+1 )):" )" -eq 0  ]]; # we have two nodes
			then    echo ·existen ambos·
				newhash="$( cat verify.txt | grep -- "$i:$(( 2*$j )):\|$i:$(( 2*$j+1 )):" | cut -d : -f 3 | tr -d '\n' | openssl dgst -sha1 -binary | xxd -p )" 
				#sed -i "s/$( cat proof.txt | grep "$(( $i+1 )):$j" | cut -d : -f 3 )/$newhash/g" proof.txt #substitute the hash in the merklee tree
		                echo -n "$(( $i+1 )):$j:" >> verify.txt
				echo $newhash >> verify.txt
			elif [[ "$( cat verify.txt | grep -q "$i:$(( 2*$j )):" )" -eq 0 ]]; #we have one node
			then    
				echo "existe uno"
				newhash="$( cat verify.txt | grep "$i:$(( 2*$j )):" | cut -d : -f 3 | openssl dgst -sha1 -binary | xxd -p )" #get new node hash
			        echo -n "$(( $i+1 )):$j:" >> verify.txt
				echo $newhash >> verify.txt
	
					#sed -i "s/$( cat proof.txt | grep "$(( $i+1 )):$j" | cut -d : -f 3 )/$newhash/g " proof.txt
		         fi
		 done
		factor=$(( $factor/$half ))
		echo "$factor"
	done
	sed -i "s/$oldroot/$( cat verify.txt | grep "$(( $elem/$half )):0" | cut -d : -f 3 )/g" verify.txt
	if [[ "$( cat verify.txt | grep "MerkleeTree" | cut -d : -f 7 )" == $( cat proof.txt | grep "MerkleeTree" | cut -d : -f 7 ) ]]
	then
	echo "Verification ok" >> verify.txt
	else
		echo "Verification ko" >> verify.txt
	fi
fi



