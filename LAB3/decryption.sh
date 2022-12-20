#! /usr/bin/bash


if [ "$#" -ne "2" ]
then

	echo 'Introduce a ciphered pem file and the private key:'
 	echo "$ $0 ciphertext.pem privkeyfile.pem"
  	exit 1

else

	if [ -f $1 -a -f $2 ]; then

	mkdir -p aux_files #auxiliary credentials used

	#READING CIPHERTEXT.PEM AND OBTAINING AUX FILES

	echo  "-----BEGIN PUBLIC KEY-----" > aux_files/eph_pubkey.pem

	sed -n '/-----BEGIN PUBLIC KEY-----/{:a;n;/-----END PUBLIC KEY-----/b;p;ba}' $1 >> aux_files/eph_pubkey.pem 

	echo  "-----END PUBLIC KEY-----" >> aux_files/eph_pubkey.pem

	sed -n '/-----BEGIN AES-128-CBC IV-----/{:a;n;/-----END AES-128-CBC IV-----/b;p;ba}' $1 | openssl base64 -d -out aux_files/iv.bin

	sed -n '/-----BEGIN AES-128-CBC CIPHERTEXT-----/{:a;n;/-----END AES-128-CBC CIPHERTEXT-----/b;p;ba}' $1 | openssl base64 -d -out aux_files/ciphertext.bin

	sed -n '/-----BEGIN SHA256-HMAC TAG-----/{:a;n;/-----END SHA256-HMAC TAG-----/b;p;ba}' $1 | openssl base64 -d -out aux_files/tag.bin

	openssl pkeyutl -inkey $2 -peerkey aux_files/eph_pubkey.pem -derive -out aux_files/commonsecret.bin #gen common secret again

	cat aux_files/commonsecret.bin | openssl dgst -sha256 -binary > aux_files/sha256.txt #hash secret

	cat aux_files/sha256.txt | head -c 16 > aux_files/k1.bin #extract first 16B for key 1

	cat aux_files/sha256.txt | tail -c 16 > aux_files/k2.bin #extract last 16B for key 2

	cat aux_files/iv.bin aux_files/ciphertext.bin | openssl dgst -sha256 -mac hmac -macopt hexkey:`cat aux_files/k2.bin | xxd -p` -binary > aux_files/generated_tag.bin #gen binary tag


	if [ `cmp --silent aux_files/generated_tag.bin aux_files/tag.bin || echo 1` ]; then
		echo '¡WRONG TAG! MESSAGE HAS BEEN TAMPERED OR KEY MAY NOT BE CORRECT'
		exit 1
	fi

	#DECRYPTION

	openssl enc -aes-128-cbc -d -in aux_files/ciphertext.bin -iv `cat aux_files/iv.bin | xxd -p` -K `cat aux_files/k1.bin | xxd -p` -out resulting_message.txt 


	else
		echo 'Cannot find files'
  		exit 1
	fi

fi

