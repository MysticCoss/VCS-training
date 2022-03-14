;Compile & link command:
;nasm -f elf add.asm -o add.o 
;ld -m elf_i386 add.o -o add

section .bss
a resb 10
b resb 10

value resb 100
trueValue resb 100

section .data
pa db "Input first number: "
pb db "Input second number: "
s  db "Sum: "

section .text
global _start

_start:
    push    ebp 			
    mov     ebp, esp		

	;Request user enter first number
	mov 	eax, 4							;__NR_write
	mov 	ebx, 1							;STDOUT_FILENO 1	
	mov 	ecx, pa							;"Input first number: \n"
	mov 	edx, 20							;number byte write
	int 	0x80							;syscall __NR_write (int fd = 1, const void *buf = "Input first number: ", size_t count = 20)
	
	mov 	eax, 3							;__NR_read						
	mov 	ebx, 0							;STDIN_FILENO 0				
	mov 	ecx, a							;&a				
	mov 	edx, 11							;number byte read				
	int 	0x80							;syscall __NR_read (int fd = 0, const void *buf = &a, size_t count = 11)	
	
	;Originally a is a string, we need to convert it to int
	call 	atoi							;return value placed on edx | yeah that's an accident
	push 	edx

	;call 	inpb
	mov 	eax, 4							;__NR_write
    mov 	ebx, 1                          ;STDOUT_FILENO 1	
    mov 	ecx, pb                         ;"Input second number: \n"
    mov 	edx, 21                         ;number byte write
    int 	0x80                            ;syscall __NR_write (int fd = 1, const void *buf = "Input second number: ", size_t count = 21)
	
	mov 	eax, 3							;__NR_read						
	mov 	ebx, 0                          ;STDIN_FILENO 0				
	mov 	ecx, b                          ;&b				
	mov 	edx, 11                         ;number byte read				
	int 	0x80                            ;syscall __NR_read (int fd = 0, const void *buf = &b, size_t count = 11)
	
	;Originally b is a string, we need to convert it to int
	call 	atoi							;return value placed on edx
	push 	edx

	pop 	eax								;b
	pop 	ebx								;a

	;cộng 2 số và lưu vào thanh ghi eax
	add 	eax, ebx
	;đẩy eax vào stack
	push 	eax
	call 	hex2chr							;convert int to char
								


;procedure để chuyển input nhập vào từ chuỗi thanh số
atoi:
	xor 	eax, eax
	xor 	ebx, ebx
	xor 	edx, edx
nextchar:
;chuyển từng ký tự từ char thành int
	mov 	bl, BYTE[ecx]
	cmp 	bl, 0xA
	jz 		end
	sub 	ebx, 0x30

;chuyển chuỗi sang số lấy 1 eax làm 1 base rồi nhân 10 lên theo từng vòng và cộng với số tiếp theo
	imul	eax, 10
	add 	eax, ebx
	mov 	edx, eax

	add 	ecx, 1
	jmp 	nextchar
end:
	ret


;procedure hex2char mang ý nghĩa chuyển ngược số đã được cộng thành kiểu string để có thê in ra màn hình 
hex2chr:
	mov 	eax, DWORD[esp+4]    
								
	
	
	lea 	ebx, [value]		 
	mov 	DWORD[esp + 8], 0 	
hex2chr1:
	mov 	ecx, 10             
	mov 	edx, 0              
	div 	ecx                 
	
	add 	dl, 0x30			
	mov 	BYTE[ebx], dl
	add 	ebx, 1             
	add 	DWORD[esp+8], 1      
	cmp 	eax, 0

 	jnz hex2chr1


;procedure hex2char đã chuyển tổng thành string nhưng bị ngược nên cần procedure reverse để đảo ngược lại string chứa tổng
reverse:
	mov 	eax, DWORD[esp + 8]  
	lea 	ecx, [trueValue]	

;trừ dần từ index là tổng số ký tự của string chứa tổng vào để biết lúc cần kết thúc rồi chuyển từng ký tự lại vào trueValue qua ecx
reverse1:
	mov 	dl, BYTE[value + eax - 1]
	mov 	BYTE[ecx], dl
	
	sub 	eax, 1
	add 	ecx, 1
	cmp 	eax, 0
	jnz 	reverse1
	mov 	byte[ecx], 0xA       ;kết thúc quá trình đảo ngược, chuyển giá trị xuống dòng cho trueValue



outp:
	mov 	eax, 4								;__NR_write
    mov 	ebx, 1                              ;STDOUT_FILENO 1	
    mov 	ecx, s                              ;"Sum: "
    mov 	edx, 5                              ;number byte write
    int 	0x80                                ;syscall __NR_write (int fd = 1, const void *buf = "Sum: ", size_t count = 5)
	                                            
	                                            
	mov 	eax, 4                              ;__NR_write						
	mov 	ebx, 1                              ;STDIN_FILENO 1				
	mov 	ecx, trueValue                      ;&trueValue				
	mov 	edx, 15                             ;number byte write				
	int 	0x80                                ;syscall __NR_write (int fd = 1, const void *buf = &trueValue, size_t count = 15)
	
exit:	
	mov 	eax, 1
	int 	0x80
