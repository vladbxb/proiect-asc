# Sistem de gestiune a memoriei stocate pe disc scris in vanilla GNU Assembly x86 32-bit sintaxa AT&T

## In ce surse sunt respectate cerintele?
tema_unidimensional.s - Cerinta 0x00

tema_bidimensional.s - Cerinta 0x01

## Cum se pot compila?
simplu, trebuie ca package ul g++-multilib sa fie instalat pe sistemul dvs. GNU/Linux

apoi, unde nume_sursa este sursa GNU Assembly x86 sintaxa AT&T pe care vreti sa o testati, compilati cu comanda:

gcc -m32 "nume_sursa.s" -o nume_sursa -no-pie -g;

astfel, executabilul vostru va deveni numele fisierului sursa fara extensia .s
