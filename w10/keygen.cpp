//Run successfully on VisualStudio 2022
//Other versions have not ever been tested, but they may work flawlessly
//Probably not work on other compilers :3

#include <Windows.h>
#include <stdio.h>


char shuffer[] = { 9, 18, 15, 3, 4, 23, 6, 7, 8, 22, 10, 11, 33, 13, 14, 27, 16, 37, 17, 19, 20, 21, 5, 34, 24, 25, 26, 2, 12, 29, 30, 31, 32, 28, 0, 35, 36, 1 };
char option[] = { 6, 1, 7, 1, 3, 2, 4, 3, 6, 3, 7, 6, 1, 4, 7, 4, 1, 5, 7, 6, 7, 5, 6, 4, 5, 1, 7, 5, 2, 3, 1, 2, 3, 2, 1, 6, 2, 4 };
char thamsothu3[] = { 1, 3, 1, 1, 2, 1, 3, 1, 2, 2, 4, 4, 1, 3, 4, 4, 4, 1, 2, 1, 4, 1, 4, 3, 1, 2, 4, 4, 2, 2, 1, 3, 4, 2, 1, 2, 2, 3 };
unsigned char enc[] = { 14, 235, 243, 246, 209, 107, 167, 143, 61, 145, 133, 43, 134, 167, 107, 219, 123, 110, 137, 137, 24, 149, 103, 202, 95, 226, 84, 14, 211, 62, 32, 90, 126, 212, 184, 16, 194, 183 };
unsigned char mem_arr[] = { 54, 236, 0, 0, 54, 237, 0, 0, 54, 187, 0, 0, 54, 140, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 0, 0, 0, 108, 239, 153, 0, 25, 238, 225, 118, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };


char wtf_func(char a1, unsigned char* a2, int a3)
{
    int v4; // esi
    char v6; // bl
    unsigned int v7; // ecx
    unsigned short v8; // dx
    unsigned int v9; // edx
    char v10; // cl
    unsigned int v11; // edx
    char v12; // al
    bool v13; // zf
    unsigned char* v14; // ecx
    int v15; // esi
    char v16; // dl
    int v18; // [esp+14h] [ebp+8h]

    v4 = a3 - 1;
    v18 = 171;
    v6 = 0;
    do
    {
        if (v4 <= 5)
        {
            if (*(unsigned long*)(a2 + 4 * v4 + 16))
                v8 = *(unsigned short*)(a2 + 4 * v4 + 16);
            else
                v8 = *(unsigned short*)(a2 + 4 * v4);
            v7 = (v8 >> 1) | (unsigned short)(((unsigned short)(32 * v8) ^ (v8 ^ (unsigned short)(4 * (v8 ^ (2 * v8)))) & 0xFFE0) << 10);
            *(unsigned long*)(a2 + 4 * v4 + 16) = v7;
        }
        else
        {
            unsigned int kk = 0xFFFF0000;
            v7 &= kk;
        }
        v9 = v7 & 0x7FF;
        v10 = v7 & 7;
        v11 = v9 >> 3;
        if (a1)
            v12 = *(a2 + v11 + 44);
        else
            v12 = ~*(a2 + v11 + 44);
        v13 = v18-- == 1;
        *(a2 + v11 + 44) = v12 ^ (1 << v10);
    } while (!v13);
    v14 = a2 + 46;
    v15 = 64;
    do
    {
        v16 = *(v14 - 2);
        v14 += 4;
        v6 ^= *(v14 - 4) ^ *(v14 - 3) ^ *(v14 - 5) ^ v16;
        --v15;
    } while (v15);
    return v6;
}


int main()
{
    char key[39];
    char a;
    int i = 0;
    while (i < 38)
    {
        if (option[i] == 1 || option[i] == 4 || option[i] == 5)
            a = wtf_func(0, mem_arr, thamsothu3[i]);
        else
            a = wtf_func(1, mem_arr, thamsothu3[i]);

        key[shuffer[i]] = a ^ enc[i];
        i++;
    }
    printf("%s", key);
}

//key = I_10v3-y0U__wh3n Y0u=c411..M3 Senor1t4
//flag = vcstraining{Th3_U1tiM4t3_ant1_D3Bu9_ref3r3ncE}