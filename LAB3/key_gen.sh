#! /usr/bin/bash


if [ "$#" -ne "1" ]
then

	echo 'Introduce name of the key owner:'
 	echo "$ $0 name"
  	exit 1

else

FILE=param.pem

	if [ ! -f "$FILE" ]; then
		openssl genpkey -genparam -algorithm dh -pkeyopt dh_rfc5114:3 -out param.pem
	fi
	
	openssl genpkey -paramfile param.pem -out "$1_pkey.pem"

	openssl pkey -in "$1_pkey.pem" -pubout -out "$1_pubkey.pem"
	
	echo "Generated public and private key for $1"

fi
