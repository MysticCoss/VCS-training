;Compile & link command:
;nasm -f elf uppercase.asm -o uppercase.o
;ld -m elf_i386 uppercase.o -o uppercase

bits 32
default rel
section .data

section .bss

section .text
global _start


_start:
	push 	ebp
	mov		ebp, esp
	sub 	esp, 36							;allocate 4 bytes
	;Local variable			
	;offset -36 : char s[32]			
	;offset -4	: int byteread			
			
	;call inp      			
	mov 	eax, 3							;__NR_read	
	mov		ebx, 0							;STDIN_FILENO 0
	lea 	ecx, [ebp-36]					;s			
	mov 	edx, 32							
	int 	0x80							;byteread = syscall __NR_read (int fd = 0, const void *buf = s, size_t count = 32)
	mov		[ebp-4], eax					
				
	call 	toUpper			
				
	;call outp			
	mov 	eax, 4							;__NR_write
	mov 	ebx, 1							;STDOUT_FILENO 1	
	lea 	ecx, [ebp-36]					;s
	mov 	edx, [ebp-4]					;byteread
	int 	0x80							;syscall __NR_write (int fd = 1, const void *buf = s, size_t count = byteread)
			
	mov eax, 1			
	int 0x80			
			
;for loop			
toUpper:			
	xor 	edi, edi						;i = 0
Comparison:
	mov		eax, [ebp-4]					;byteread
	cmp		edi, eax							
	jl		L								;if i < byteread then loop
	ret										;else quit loop  
L:
	movzx 	eax, byte [ebp-36+edi] 			;s[i]
	cmp 	al, 122							;if s[i] > 122 then jmp Increment
	jg 		Increment

	movzx 	eax, byte [ebp-36+edi]			;s[i]
	cmp 	al, 96							;if s[i] <= 96 then jump Increment
	jle 	Increment

	sub 	al, 32							;if 97 <= s[i] <= 122 will reach this instruction
											;from a->z in ASCII table
	mov 	byte [ebp-36+edi], al				;s[i] -= 32	
	jmp 	Increment
Increment:
	inc 	edi
	jmp 	Comparison
