#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/md5.h>

typedef unsigned int UINT4;

MD5_LONG gethexword32(const unsigned char *digest){

    MD5_LONG var =(unsigned) digest[0]|((unsigned)digest[1]<<8)|((unsigned)digest[2]<<16)|((unsigned)digest[3]<<24); //Little endian to Int

    return var;

}

void set_ctx(MD5_CTX *pctx, const unsigned char *digest, unsigned long nblocks) {
        pctx->A = gethexword32(digest);
        pctx->B = gethexword32(digest+4);
        pctx->C = gethexword32(digest+8);
        pctx->D = gethexword32(digest+12);
        nblocks <<= 9; // converting into bits
        pctx->Nh = nblocks>>32;
        pctx->Nl = nblocks&0xFFFFFFFFul;
}

unsigned char *file2md5(const char *filename, const char *digest_file, const char * newdata_file) {

    char * msg = 0;
    long length;
    long total_bytes;
    unsigned long nblocks;
    FILE * f = fopen (filename, "rb"); //Read message padded

    if (f)
    {
        fseek (f, 0, SEEK_END);
        length = ftell (f);

        fseek (f, 0, SEEK_SET);
        msg = malloc (length);
        if (msg)
        {
            fread (msg, 1, length, f);
        }
        fclose (f);
    }


    if (msg)
    {
        total_bytes=length+16; //Bytes of padded message + key
        nblocks=total_bytes/64;
        MD5_CTX c;
        unsigned char * digest=0;
        unsigned char *out = (unsigned char*)malloc(33);

        f = fopen (digest_file, "rb"); //Read tag file


        if (f)
        {
            fseek (f, 0, SEEK_END);
            length = ftell (f);

            fseek (f, 0, SEEK_SET);
            digest = malloc (length);
            if (digest)
            {
                fread (digest, 1, length, f);
            }
            fclose (f);

        }
        else
            return NULL;

        MD5_Init(&c);

        set_ctx(&c,digest,nblocks); //Set context according to padded message and passing the tag
        
        f = fopen (newdata_file, "rb"); //Open new data file (padded) to append
        char * new_data=0;

        if (f)
        {
            fseek (f, 0, SEEK_END);
            length = ftell (f);

            fseek (f, 0, SEEK_SET);
            new_data = malloc (length);
            if (new_data)
            {
                fread (new_data, 1, length, f);
            }
            fclose (f);
        }
        else
            return NULL;


        while (length > 0) { //Call update for each new block of data
            
            if (length > 64) {
                MD5_Update(&c, new_data, 64);
            } else {
                MD5_Update(&c, new_data, length);
            }
            length -= 64;
            new_data += 64;
        }


        unsigned char new_digest[MD5_DIGEST_LENGTH];

        MD5_Final(new_digest, &c); //Get the new forger tag

        out= new_digest;

        return out;
    }

    return NULL;
}


int main(int argc, char **argv) {

   if( argc == 4 ) {
        unsigned char * new_tag=0;
        new_tag=file2md5(argv[1],argv[2],argv[3]);
        printf("FORGER TAG:\t");
        for (int i = 0; i < MD5_DIGEST_LENGTH; i++)
            printf("%02x", new_tag[i]);
        putchar ('\n');      

   }
   else {
      printf("Expected execution: ./attack <message_padded_file> <tag> <new_data_file>\n");
   }

    return 0;
}


//Llamar a set_ctx desde un estado nulo y pasando el tag, junto a los bloques totales
//Llamar a update con el forgery
//Obtener el nuevo tag tras llamar a Final

//Verificar con ssl