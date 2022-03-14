;Compile & link command:
;nasm -f elf helloworld.asm -o helloworld.o
;ld -m elf_i386 helloworld.o -o helloworld

bits 32
default rel
section .data					
s db "Hello world!" , 0xA		;"Hello world!\n"
s_len equ $-s					;s_len là độ lớn của biến s 


section .text					
global _start					;entry point

_start:							
	mov eax, 4					;__NR_write
	mov ebx, 1					;STDOUT_FILENO 1
	mov ecx, s                  ;s
	mov edx, s_len              ;s_len 
	int 0x80					;syscall __NR_write (int fd = 1, const void *buf = s, size_t count = s_len)

	mov eax, 1                  ;__NR_exit
	int 0x80					;syscall __NR_exit ()

