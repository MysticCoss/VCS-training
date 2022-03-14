;Compile and link tool
;nasm -f win32 -o add.obj add.asm
;GoLink /files /console add.obj kernel32.dll user32.dll msvcrt.dll

bits 32
default rel
segment .data
    format db "%d", 0
    format_ld db "%lld",0
segment .text
    extern ExitProcess
    extern printf
    extern scanf
global Start





Start:
    push    ebp 			
    mov     ebp, esp		
	sub		esp, 8							;Allocate 8 bytes in stack

    lea     eax,[ebp-4]                     ;a
    push    eax
    push    format
    call    scanf                           ;scanf("%d",&a)

    lea     eax,[ebp-8]                     ;b
    push    eax
    push    format
    call    scanf                           ;scanf("%d",&b)

    mov     eax, [ebp-4]                    ;a
    mov     ebx, [ebp-8]                    ;b
    cdq                                     ;Set all bits in edx to the sign of eax
    xchg    ebx, eax                        ;eax = original ebx
    mov     ecx, edx                        ;ecx:ebx = original eax sign extended
    cdq                                     ;edx:eax = original ebx sign extended

    add     eax, ebx
    adc     edx, ecx                        ;edx:eax = eax + ebx

    mov     [ebp-8], eax                    ;offset -8: Lower bit
    mov     [ebp-4], edx                    ;offset -4: Higher bit
                                            ;Lower bit at low address
                                            ;Higher bit at high address

    mov     eax, [ebp-4]                    ;push higher bit first
    push    eax                             ;push lower bit later
    mov     eax, [ebp-8]                    ;Order discussed above is maintained in stack
    push    eax
    push    format_ld
    call    printf

    xor     eax, eax
    push    eax
    call    ExitProcess