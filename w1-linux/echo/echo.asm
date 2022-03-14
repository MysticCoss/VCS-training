;Compile & link command:
;nasm -f elf echo.asm -o echo.o
;ld -m elf_i386 echo.o -o echo
section .data
ent db "Enter text to echo:", 0xA
ent_len equ $-ent 

section .bss
s resb 32

section .text 
global _start


_start:
	push    ebp 			
    mov     ebp, esp	
	sub 	esp, 4 				;allocate 4 bytes
	;Local variable
	;offset -4	: int byteread
	
	;call printEnter
	mov 	eax, 4				;__NR_write
	mov 	ebx, 1				;STDOUT_FILENO 1
	mov		ecx, ent			
	mov 	edx, ent_len		;syscall __NR_write (int fd = 1, const void *buf = ent, size_t count = ent_len)
	int 	0x80
	
	;call inp				
	mov 	eax, 3				;__NR_read	
	mov		ebx, 0				;STDIN_FILENO 0
	mov 	ecx, s				
	mov 	edx, 32				
	int 	0x80				;syscall __NR_read (int fd = 0, const void *buf = s, size_t count = 32)
	mov		[ebp-4], eax		;number of bytes read
	
	;call outp
	mov 	eax, 4				;__NR_write
	mov 	ebx, 1				;STDOUT_FILENO 1	
	mov 	ecx, s
	mov 	edx, [ebp-4]		;byteread
	int 	0x80				;syscall __NR_write (int fd = 1, const void *buf = s, size_t count = byteread)
	
	pop		ebp
	mov		esp, ebp
	
	mov eax, 1
	int 0x80					;exit


