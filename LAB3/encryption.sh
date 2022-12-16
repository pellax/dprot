#! /usr/bin/bash


if [ "$#" -ne "3" ]
then

	echo 'Introduce a param file, a public key and a message file:'
 	echo "$ $0 paramfile.pem pubkeyfile.pem message.dat"
  	exit 1

else

	if [ -f $1 -a -f $2 ]; then

	openssl genpkey -paramfile $1 -out aux_files/ephkey.pem #gen ephkey



	openssl pkey -in aux_files/ephkey.pem -pubout -out aux_files/ephpubkey.pem #extract public part of ephkey


	openssl pkeyutl -inkey aux_files/ephkey.pem -derive -peerkey $2 -out aux_files/commonsecret.bin #gen common secret
	
	cat aux_files/commonsecret.bin | openssl dgst -sha256 -binary > aux_files/sha256.txt #hash secret

	cat aux_files/sha256.txt | head -c 16 > aux_files/k1.bin #extract first 16B for key 1

	cat aux_files/sha256.txt | tail -c 16 > aux_files/k2.bin #extract last 16B for key 2

	openssl rand 16 > aux_files/iv.bin #gen iv

	#ENCRYPTION

	openssl enc -aes-128-cbc -iv `cat aux_files/iv.bin | xxd -p` -K `cat aux_files/k1.bin | xxd -p` -in $3 > aux_files/ciphertext.bin

	cat aux_files/iv.bin aux_files/ciphertext.bin | openssl dgst -sha256 -mac hmac -macopt hexkey:`cat aux_files/k2.bin | xxd -p` -binary > aux_files/tag.bin #gen binary tag


	#CIPHERTEXT.PEM GENERATION (ephpubkey.pem, iv.bin, ciphertext.bin, tag.bin)
	cat aux_files/ephpubkey.pem > ciphertext.pem
	echo "-----BEGIN AES-128-CBC IV-----" >> ciphertext.pem
	cat aux_files/iv.bin | openssl base64 >> ciphertext.pem
	echo "-----END AES-128-CBC IV-----" >> ciphertext.pem

	echo "-----BEGIN AES-128-CBC CIPHERTEXT-----" >> ciphertext.pem
	cat aux_files/ciphertext.bin | openssl base64 >> ciphertext.pem
	echo "-----END AES-128-CBC CIPHERTEXT-----" >> ciphertext.pem

	echo "-----BEGIN SHA256-HMAC TAG-----" >> ciphertext.pem
	cat aux_files/tag.bin | openssl base64 >> ciphertext.pem
	echo "-----END SHA256-HMAC TAG-----" >> ciphertext.pem

	else
		echo 'Cannot find files'
  		exit 1
	fi

fi
