;Compile & link command
;nasm -f elf64 -g ./b3_l.asm
;ld b3_l.o -o b3_l

bits 64
default rel
segment .data
	lf db 10
	invalid db "Invalid input", 0
	invalidlen equ $-invalid
	info0 db "Calculator program. Choose your option wisely", 13, 10, "1. Add", 13, 10, "2. Sub", 13, 10, "3. Mul", 13, 10, "4. Div", 13, 10, "Your option : ", 0
	info0len equ $-info0
	info1 db "Input first number (positive, max 50 digit) : ", 0
	info1len equ $-info1
	info2 db "Input second number (positive, max 50 digit. lower than 2^64-1 for division) : ", 0
	info2len equ $-info2
	info3 db "Your result : ", 0
	info3len equ $-info3
	outofrange db "Number out of range", 10, 0
	outofrangelen equ $-outofrange
	nan db "Not a number", 0
	nanlen equ $-nan
	max db "Max : ", 0
	maxlen equ $-max
	min db "Min : ", 0
	minlen equ $-min
	allocfail db "Allocation Failed", 10
	allocfaillen equ $-allocfail
segment .bss
	
segment .text
	
global _start




_start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 64								;Allocate 64 bytes in stack
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;Local variable:
	;offset -56  : QWORD option
	;offset -48  : QWORD PTR out[alen+blen]
	;offset -40  : QWORD PTR b[51]  //Include \n when read from console
	;offset -32  : QWORD PTR a[51] //Include \n when read from console
	;offset -24  : int64 writtenlen
	;offset -16	 : int64 blen
	;offset -8  : int64 alen
	

	;Ask for option
	mov 	rax, 1								;syscall write
	mov 	rdi, 1								;stdout
	mov 	rsi, info0
	mov 	rdx, info0len
	syscall	
	
	;Read option from user input
	mov 	rax, 0								;syscall read
	mov 	rdi, 0								;stdin
	lea 	rsi, [rbp-64]						
	mov 	rdx, 2
	syscall
	
	;Load our option in the first byte & convert it to int
	movzx 	rax, byte [rbp-64]
	sub 	rax, 48
	mov 	[rbp-56], rax
	
	;Validate option
	cmp 	rax, 1
	jl  	EndInvalid
	cmp 	rax, 4
	jg  	EndInvalid
	
	;===========================
	;Ask for first number
	mov 	rax, 1								;syscall write
	mov 	rdi, 1								;stdout
	mov 	rsi, info1
	mov 	rdx, info1len
	syscall	
	
	;Get top address of bss
	;syscall a = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-32], rax						;save current address
	
	;add 51 to that address. Allocate 51 bytes
	add 	rax, 51
	
	;change top of bss to new address 
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall : brk
	syscall
	
	;alen = read(stdin = 0, a, 101)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-32]						;void* a
	mov 	rdx, 51								;num byte read
	syscall
	mov 	[rbp-8], rax						;alen
	
	;alen -= 1
	mov		rax, [rbp-8]
	sub 	rax, 1								;alen -= 1 - cut away \n
	mov 	[rbp-8], rax
	
	;if user input nothing, just press Enter so we quit. Why should we obey such a dumb thing
	cmp		rax, 0
	jle		EndInvalid
	
	;resize a to claim unused bytes
	mov 	rbx, [rbp-32]						;load address of a
	add 	rax, rbx							;add it with alen in rax
	mov 	rdi, rax							;paramenter
	mov 	rax, 12								;syscall : brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-32]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed	
	
	;===========================
	;Ask for second number
	mov 	rax, 1								;syscall write
	mov 	rdi, 1								;stdout
	mov 	rsi, info2
	mov 	rdx, info2len
	syscall	
	
	;Get top address of bss
	;syscall b = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-40], rax						;save current address
	
	;add 51 to that address. Allocate 51 bytes
	add 	rax, 51
	
	;change top of bss to new address 
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall : brk
	syscall
	
	;blen = read(stdin = 0, b, 101)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-40]						;void* b
	mov 	rdx, 51								;num byte read
	syscall
	mov 	[rbp-16], rax						;blen
	
	;blen -= 1
	mov		rax, [rbp-16]
	sub 	rax, 1								;blen -= 1 - cut away \n
	mov 	[rbp-16], rax
	
	;if user input nothing, just press Enter so we quit. Why should we obey such a dumb thing
	cmp		rax, 0
	jle		EndInvalid
	
	;resize b to claim unused bytes
	mov 	rbx, [rbp-40]						;load address of a
	add 	rax, rbx							;add it with alen in rax
	mov 	rdi, rax							;paramenter
	mov 	rax, 12								;syscall : brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;===========================
	;Allocate output buffer
	;output buffer has the length equal to the sum of alen and blen
	
	;Get top address of bss
	;syscall out = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-48], rax						;save current address
	
	xor 	rbx, rbx
	mov 	ebx, dword [rbp-16]					;alen + blen
	add 	ebx, dword [rbp-8]
	add 	rax, rbx							;new bss address
	
	;call brk again to register new address
	mov 	rdi, rax
	mov 	rax, 12
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-48]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed	
	
	;===========================
	mov 	rax, [rbp-56]						;Load user option
	cmp		rax, 1
	je  	L_Add
	cmp 	rax, 2
	je  	L_Sub
	cmp 	rax, 3
	je  	L_Mul
	cmp 	rax, 4
	je  	L_Div
	
L_Add:
	sub 	rsp, 32
	mov 	rcx, [rbp-32]						;a
	mov 	rdx, [rbp-8]						;alen
	mov 	r8, [rbp-40]						;b
	mov 	r9, [rbp-16]						;blen
	mov 	rax, [rbp-48]							
	push 	rax									;pounter to out
	call	StrAdd
	add		rsp, 40
	jmp 	L_Print
L_Sub:
	sub 	rsp, 32
	mov 	rcx, [rbp-32]						;a
	mov 	rdx, [rbp-8]						;alen
	mov 	r8, [rbp-40]						;b
	mov 	r9, [rbp-16]						;blen
	mov 	rax, [rbp-48]							
	push 	rax									;pounter to out
	call	StrSub
	add		rsp, 40
	jmp 	L_Print
L_Mul:
	sub 	rsp, 32
	mov 	rcx, [rbp-32]						;a
	mov 	rdx, [rbp-8]						;alen
	mov 	r8, [rbp-40]						;b
	mov 	r9, [rbp-16]						;blen
	mov 	rax, [rbp-48]							
	push 	rax									;pounter to out
	call	StrMul
	add		rsp, 40
	jmp 	L_Print
L_Div:
	sub 	rsp, 32
	mov 	rcx, [rbp-40]
	mov 	rdx, [rbp-16]
	call 	Atoi
	add 	rsp, 32
	cmp 	rax, -1
	je 		End
	
	sub 	rsp, 32
	mov 	r8 ,rax								;divisor
	mov 	rcx, [rbp-32]						;a
	mov 	rdx, [rbp-8]						;alen
	mov 	r9, [rbp-48]						;out
	call 	StrDiv
	add 	rsp, 32
	jmp 	L_Print

	
	;===========================
	;Print result
L_Print:
	push 	rax
	
	;print info string
	mov 	rax, 1								;syscall write
	mov 	rdi, 1								;stdout
	mov 	rsi, info3
	mov 	rdx, info3len
	syscall
	
	pop 	rax
	
	mov 	rdx, rax 							;output length
	mov 	rax, 1								;syscall write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-48]						;output buffer
	syscall
	
	jmp 	End
	
EndInvalid:
	;Print invalid message
	mov 	rax, 1 								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, invalid
	mov 	rdx, invalidlen
	syscall	

	jmp 	End

End:
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf								;"\n"
	mov 	rdx, 1								;num char write
	syscall	

	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall
EndAllocationFailed:
	;print allocfail message
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, allocfail						
	mov 	rdx, allocfaillen					;num char write
	syscall	

	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall

StrAdd: ;int StrAdd(char* a, int alen, char* b, int blen, char* out)
		;RAX             RCX      RDX       R8       R9		rbp+16
	;return number of characters written to output buffer
	
	;r13: a begin
	;R8: b begin
	;R10: a.end() = iterator
	;R11: b.end() = iterator

	push 	rbp
	mov 	rbp, rsp
	
	push 	rdi
	push 	rbx
	push 	r15
	push 	r14
	push 	r13
	

	
	;make sure a is longer
	cmp 	rdx, r9								;compair alen with blen		
	jae		StrAddL0
	;swap alen, blen
	xchg 	rdx, r9					
	
	;swap a, b
	xchg 	rcx, r8
StrAddL0:
	;Initialization block
	mov 	r13, rcx							
	xor 	r15, r15							;r15 used as carry flag
	xor 	rdi, rdi 							;count
	lea 	rcx, [rcx+rdx-1]
	lea 	r11, [r8+r9-1]
StrAddLoop1:
	;comparison block
		
	jl 		StrAddProcess
	
	;loop block
	;load last byte of a and verify number
	movzx 	rax, byte [rcx]
	cmp 	al, 48
	jl  	End
	cmp 	al, 57
	jg  	End
	
	cmp 	r11, r8								;if iterator b >= b.begin -> Load byte from memory
	jge  	StrAddL3
	jmp 	StrAddL4
StrAddL3:
	;load last byte of b and verify number
	movzx 	rbx, byte [r11]						
	cmp 	bl, 48
	jb  	End
	cmp 	bl, 57
	jg  	End
	jmp 	StrAddL5
StrAddL4:	
	;load 48 (ascii 0) to rbx
	mov 	rbx, 48
	jmp 	StrAddL5
StrAddL5:
	add 	rax, rbx							;a last + b last
	add 	rax, r15							;a last + b last + carry (r15)
	xor 	r15, r15							;clear carry flag
	sub 	rax, 96
	
	cmp 	rax, 10
	jl		StrAddL2
	mov 	r15, 1								;set carry flag
	sub 	rax, 10								;lower decimal number
StrAddL2:
	add 	rax, 48								;ascii represent
	
	inc 	rdi									;count++
	push	rax
	
	;increment block
	dec 	r11
	cmp 	rcx, r13							;if iterator a < a.begin -> Quit loop
	;set ZF if rcx and r13 equal, which leads to loop terminate
	loopnz 	StrAddLoop1
	
StrAddProcess:
	
	;if carry flag still = 1 then push '1' to stack
	cmp 	r15, 1
	jnz 	StrAddL8
	inc 	rdi
	push 	49
	xor 	r15, r15  							;clear carry flag
StrAddL8:	
	;for (int i = 0; i < count; i ++)
	;Initialization block
	mov 	r14, [rbp+16]						;ptr out = r14
	xor 	r15, r15							;int i   = r15
												;count   = rdi
StrAddL7:
	;Comparison block
	;if (i < count then continue)
	cmp 	r15, rdi 							
	jl 		StrAddL6
	mov 	eax, edi							;number of char written
	jmp 	StrAddL9
	
StrAddL6:	;Loop block
	pop 	rax
	mov 	byte [r14], al
	
	inc 	r15
	inc 	r14
	;Increment block
	jmp 	StrAddL7
StrAddL9: ;end
	pop 	r13
	pop 	r14
	pop 	r15
	pop 	rbx
	pop 	rdi
	
	leave
	ret
;End StrSub
;==============================================================================================================================================
StrSub: ;int StrSub(char* a, int alen, char* b, int blen, char* out)
		;RAX             RCX      RDX       R8       R9		rbp+16
	;return number of characters written to output buffer
	
	;r13: a begin
	;R8: b begin
	;R10: a.end() = iterator
	;R11: b.end() = iterator

	push 	rbp
	mov 	rbp, rsp
	
	sub 	rsp, 8
	;Local variable :
	;offset -8 : int sign (final result must be multipled with this sign)
	;sign = 0 means it's positive, 1 means it's negative. Default value is 0
	
	mov 	qword [rbp-8], 0
	
	push 	rbx
	push 	rdi
	push 	r15
	push 	r14
	push 	r13
	push 	r12
	
	mov 	r15, rcx 					;mov a pointer to another place for loopz 	
										;r15: a pointer
	;compair a and b to see which number is larger
	cmp 	rdx, r9
	;if a and b does not have equal length, we have to check which number is longer 
	jne  	StrSubL0


	;loop to compair each digit
	;Initialization

	mov 	rcx, rdx					;prepair rcx counter = alen
	mov 	r14, r15					;r14 for a iterator
	mov 	r13, r8						;r13 for b iterator
	dec 	r13
	dec 	r14
	
StrSubL2:
	inc 	r13
	inc 	r14
	movzx 	rax, byte [r13]
	movzx 	rbx, byte [r14]
	cmp 	bl, al
	ja  	StrSubL1					;a is greater	
	jb  	StrSubL3					;a is smaller
	loopz 	StrSubL2
	
	test 	rcx, rcx
	;if rcx = 0 then a and b is equal. We put '0' to output and quit
	jnz		StrSubL1
	mov 	rax, [rbp+16]
	mov 	byte [rax], 48
	mov 	eax, 1
	jmp 	StrSubEnd
StrSubL0:
	;rdx: alen , r9: blen
	cmp 	rdx, r9
	jg  	StrSubL1 	
	;if alen > blen we continue as normal (StrSubL1)
	jmp 	StrSubL3
	;else we change the result's sign and swap a and b
StrSubL3:
	;first change the result sign
	mov 	qword [rbp-8], 1 
	
	;second swap a and b
	xchg 	r15, r8				;swap pointer
	xchg 	rdx, r9				;swap length
	jmp 	StrSubL1
	
StrSubL1: ;calculate a-b with a>b
	;r14 for a iterator (reverse)
	;r13 for b iterator (reverse)
	;rcx = alen for loop counter
	;prepair register
	xor 	rdi, rdi					;output char counter
	xor 	r12, r12					;r12 for carry flag
	
	mov 	r14, r15					;a pointer
	add 	r14, rdx					
	dec 	r14							;r14 point to the end of a (a.end() in c++)
	
	mov 	r13, r8 					;b pointer
	add 	r13, r9 					
	dec 	r13							;r13 point to the end of b (b.end() in c++)
	
	mov 	rcx, rdx					;loop counter
	
StrSubL4: ;actual loop

	cmp 	r13, r8						;if r13 point out of b, load '0' instead
	jge  	StrSubL5
	mov 	rbx, 48
	jmp 	StrSubL7
StrSubL5:								;else load character from a and b 
	movzx 	rbx, byte [r13]				;b[i]
StrSubL7:
	movzx 	rax, byte [r14]				;load a[i]
	;add carry flag to bl and clear it 
	add 	rbx, r12
	xor 	r12, r12
	cmp 	al, bl
	jge 	StrSubL6					;if al >= bl we sub normally
	;else we add 10 to a[i] and set carry flag
	add 	rax, 10
	mov 	r12, 1

StrSubL6: 	;after a harsh time we can now happy sub 
	sub 	rax, rbx
	push 	rax
	inc 	rdi
	
	
	dec 	r13
	dec 	r14
	loopnz	StrSubL4
	
	
StrSubProcess: ;process output	
	;for (int i = 0; i < count; i ++)
	;Initialization block
	mov 	r14, [rbp+16]						;ptr out = r14
	xor 	r15, r15							;r15 loop counter
												;count   = rdi
	xor 	r12, r12 							;r12 is used as a flag to discard all leading zero in the result.
												;Default value is 0. Once a non-zero number meet, it is set to 1.
	xor 	r13, r13 							;r13 is number of char actually written to output											
	cmp  	qword [rbp-8], 1
	;if sign flag is 1 so we put a '-' to the output
	jne 	StrSubL8
	mov 	byte [r14], 45							;'-'
	inc 	r14
	inc 	r15
	inc 	rdi	
	inc 	r13
StrSubL8:
	;Comparison block
	;if (i < count then continue)
	cmp 	r15, rdi 							
	jl 		StrSubL9

	;prepair return value
	mov 	eax, r13d							;number of char written
	jmp 	StrSubEnd

;basic idea to eliminate leading zero is from to start, if we don't meet a non-zero number,
;this flag is still not set, and we will ignore everything. Once we meet a non-zero, this flag will be
;set, we will count everything after that.	
StrSubL9:	;Loop block
	pop 	rax	
	
	test 	rax, rax 
	jz 		StrSubL12								;if current number is zero, we won't set zeroflag
	;else we set it
	inc 	r12
	
StrSubL12:
	test 	r12, r12								;check if flag is set or not
	jz 		StrSubL10							;if flag is not set we won't write number to output														
	
StrSubL11:	
	add 	rax, 48
	mov 	byte [r14], al
	inc 	r13
	inc 	r14
StrSubL10:	
	inc 	r15
	;Increment block
	jmp 	StrSubL8	
StrSubEnd: ;end
	pop		r12
	pop 	r13
	pop 	r14
	pop 	r15
	pop 	rdi
	pop 	rbx
	
	leave
	ret

;==================================================================================================================================	
StrMul:	;int StrMul(char* a, int alen, char* b, int blen, char* out)
		;RAX             RCX      RDX       R8       R9		rbp+16
	;return number of characters written to output buffer
	push    rbp
	mov     rbp, rsp
	sub 	rsp, 32
	
	;Local paramenter
	;
	;--saving paramenter to free up register
	;offset +16 : QWORD PTR out
	;offset -8  : QWORD PTR a
	;offset -16 : QWORD alen
	;offset -24 : QWORD PTR b
	;offset -32 : QWORD blen
	
	
	
	mov 	qword [rbp-8], rcx
	mov 	qword [rbp-16], rdx
	mov 	qword [rbp-8], r8
	mov 	qword [rbp-16], r9

	
	push 	rbx
	push	rdi
	push	r15
	push 	r14
	push 	r13
	push 	r12
	
	;reverse a
	;paramenter already in rcx and rdx
	call 	Reverse
	
	;reverse b
	mov 	rcx, qword [rbp-8]
	mov 	rdx, qword [rbp-16]
	call 	Reverse
	
    ;//Multiplication of two numbers
    ;for (i(r15) = 0; i(r15) <= alen(rdx) - 1;++i(r15)) {
    ;    for (j(r14) = 0; j(r14) <= blen(r9) - 1;++j(r14)) {
    ;        C(r11)=(a(rcx)[i(r15)]-48) * (b(r8)[j(r15)]-48);
    ;        k(r13) = i(r15) + j(r14);
    ;        out[k(r13)] = out[k(r13)] + C(r11);
    ;        C(r11) = out[k(r13)];
    ;        for (l(r12) = 0; out[k(r13) + l(r12)] >= 10; ++l) {
    ;            out[k(r13) + l(r12)] = out[k(r13) + l(r12)] % 10;
    ;            out[k(r13) + l(r12) + 1] = C(r11) / 10 + out[k(r13) + l(r12) + 1];
    ;            C(r11) = out[k(r13) + l(r12) + 1];
    ;        }
    ;    }
    ;}	
	
	;rcx : a
	;rdx : alen
	;r8  : b
	;r9  : blen
	mov 	rcx, qword [rbp-8] 
	mov 	rdx, qword [rbp-16]
	mov 	r8, qword [rbp-8]
	mov 	r9, qword [rbp-16]
	
	xor 	rdi, rdi
	xor 	r13, r13 							;k
	xor 	r12, r12 							;l
	xor 	r11, r11 							;C
	
	;First for loop initialization
	xor 	r15, r15							;i
	
StrMulL5:		
	;First loop comparison
	cmp 	r15, rdx 							;i <= alen
	jge  	StrMulL0

	;First loop
		
		;Second initialization
		xor 	r14, r14						;j
		
		;Second loop comparison
		StrMulL1:
		cmp 	r14, r9
		jge 	StrMulL2
		
		;Second loop
		movzx 	rax, byte [rcx+r15]				;a[i]
		sub 	rax, 48
		movzx 	rbx, byte [r8+r14]				;b[j]
		sub 	rbx, 48
		push 	rdx								;store rdx to avoid change from mul instruction
		mul 	rbx								;(a[i]-48)*(b[i]-48)
		pop 	rdx								
		mov 	r11, rax						;C = (a[i]-48)*(b[i]-48)
		mov 	r13, r15
		add 	r13, r14						;k = i + j
		mov 	rax, qword [rbp+16]				;out
		add 	rax, r13						;out[k]
		movzx 	rbx, byte [rax]					;out[k]
		add 	rbx, r11						;out[k] + C
		mov 	byte [rax], bl					;out[k] = out[k] + C
		
		;record highest pointer to track the last charactor of out buffer
		cmp 	r13, rdi						;if rdi < k then rdi = k
		jbe 	StrMulL7
		mov 	rdi, r13						;k (k=i+j)

		StrMulL7:
		mov 	r11, rbx						;C=out[k]
		
			;Third initialization
			xor 	r12, r12					;l
			
			StrMulL3:
			;Third loop comparison
			mov 	rbx, r13					;k
			add 	rbx, r12					;l
			mov 	rax, qword [rbp+16]			;out
			lea 	rax, [rax+rbx]				;out[k+l]
			movzx 	rax, byte[rax]
			cmp 	al, 10
			jl  	StrMulL4
			
			;Third loop
			push 	rdx
			xor 	rdx, rdx					;prepair for div instruction
			mov 	rbx, 10
			div 	rbx							;Quotient int rax, remainder in rdx
			
			mov 	rbx, r13					;k
			add 	rbx, r12					;l
			mov 	rax, qword [rbp+16]			;out
			mov 	byte [rax+rbx], dl			;out[k+l] = out[k+l]%10
			
			add 	rax, rbx
			add 	rax, 1						;k+l+1
			movzx 	r10, byte [rax] 			;out[k+l+1]
			mov 	rax, r11					;C
			xor 	rdx, rdx
			mov 	rbx, 10
			div 	rbx
			pop 	rdx
			add 	r10, rax
			
			mov 	rbx, r13					;k
			add 	rbx, r12					;l
			add 	rbx, 1						;k+l+1
			mov 	rax, qword [rbp+16]			;out
			add 	rax, rbx					;out[k+l+1]
			mov 	byte [rax], r10b			;out[k(r13) + l(r12) + 1] = C / 10 + out[k(r13) + l(r12) + 1]
								
			movzx 	r11, byte [rax]				;C = out[k+l+1]
			
			;record highest pointer to track the last charactor of out buffer
			cmp 	rbx, rdi
			jbe 	StrMulL8
			mov 	rdi, rbx					;out + k + l + 1
			
			StrMulL8:
			;Third increment
			inc 	r12							;l++
			
			jmp 	StrMulL3
			
		StrMulL4:
		;Second increment
		inc 	r14
		jmp 	StrMulL1
		
StrMulL2:		
	;First increment
	inc 	r15
	jmp 	StrMulL5
	
StrMulL0:
	inc 	rdi
	mov 	rcx, rdi				;prepair for loop instruction
StrMulL6:	
	;Loop
	mov 	rbx, [rbp+16]
	dec 	rbx
	movzx 	rax, byte [rbx+rcx]
	add 	rax, 48
	mov 	byte [rbx+rcx], al

	loop 	StrMulL6

;=
	mov 	rcx, [rbp+16]
	mov 	rdx, rdi
	call 	Reverse
	
	mov 	rax, rdi
	
	pop 	r12
	pop 	r13
	pop 	r14
	pop 	r15
	pop 	rdi
	pop 	rbx
	
	leave
	ret
;==================================================================================================================================
Reverse: 										;fast_call void Reverse(char* a <rcx>, int length <rdx>). 
												;Reverse passed string
	push    rbp 			
    mov     rbp, rsp	
	push 	rbx
	;Parameter
	;rcx 		 : a
	;rdx 		 : length
	;
	;Local variable
	;
	
	mov 	rax, rcx							;a.begin 
	lea 	rbx, [rcx+rdx-1]					;a+length-1 (aka a.end)
ReverseLoop:	;just swap first and last characters and move on to inner characters
	cmp 	rax, rbx
	ja  	ReverseEnd
	mov 	cl, byte [rax]
    mov 	ch, byte [rbx]
    mov 	[rax], ch
    mov 	[rbx], cl
    dec 	rbx
    inc 	rax
    jmp 	ReverseLoop
ReverseEnd:
	pop 	rbx
	leave
	ret
;end of reverse
;==================================================================================================================================
StrDiv: ;int StrDiv(char* dividend, int dividendlen, int divisor, char* out)
		;RAX                 RCX            RDX            R8            R9
	;return number of characters written to output buffer
	
	;Algorithm in C
	;// A function to perform division of large numbers
	;int StrDiv(char* dividend, int dividendlen, int divisor, char* out)
	;{
	;
	;    // Find prefix of dividend that is larger than divisor.
	;    int idx(rdx) = 0;
	;    int temp(r15) = dividend[idx(rdx)] - '0';
	;    while (temp(r15) < divisor)
	;        temp(r15) = temp(r15) * 10 + (dividend[++idx(rdx)] - '0');
	;
	;    // Repeatedly divide divisor with temp. After
	;    // every division, update temp to include one
	;    // more digit.
	;    int outlen(r14) = 0;
	;    while (dividendlen > idx(rdx)) {
	;        // Store result in answer i.e. temp / divisor
	;        out[outlen(r14)++] = (temp(r15) / divisor) + '0';
	;        
	;        // Take next digit of dividend
	;        temp(r15) = (temp(r15) % divisor) * 10 + dividend[++idx(rdx)] - '0';
	;    }
	;
	;    // If divisor is greater than dividend
	;    if (outlen(r14) == 0) {
	;        out[outlen(r14)] = '0';
	;        outlen(r14)++;
	;    }
	;    
	;    //return outlen
	;    return outlen(r14);
	;}	
	
	;new stack frame									
	push    rbp
	mov     rbp, rsp
	sub 	rsp, 32
	
	;Local paramenter
	;
	;--saving paramenter to free up register
	;offset -8  : QWORD PTR dividend
	;offset -16 : QWORD dividendlen
	;offset -24 : QWORD divisor
	;offset -32 : QWORD PTR out
	
	mov 	qword [rbp-8], rcx			;QWORD PTR dividend
	mov 	qword [rbp-16], rdx         ;QWORD dividendlen
	mov 	qword [rbp-8], r8          ;QWORD divisor
	mov 	qword [rbp-16], r9          ;QWORD PTR out
	
	push 	rbx
	push	rdi
	push	r15
	push 	r14
	
	;Find prefix of dividend that is larger than divisor.
	xor 	rdi, rdi					;idx = 0
	
	movzx 	r15, byte [rcx+rdi]			;temp = dividend[idx]
	sub 	r15, 48						;temp = dividend[idx] - '0'
	
StrDivL0:
	cmp 	r15, r8						;while (temp < divisor)
	jae 	StrDivL1
	
	mov 	rax, r15
	shl 	rax, 3 						
	shl 	r15, 1
	add 	r15, rax					;temp *= 10
	
	inc 	rdi							;++idx
	movzx 	rax, byte [rcx+rdi]			
	sub 	rax, 48						;dividend[++idx] - '0'
	
	add 	r15, rax					;temp) = temp * 10 + (dividend[++idx)] - '0')
	jmp 	StrDivL0
StrDivL1:
	xor 	r14, r14					;outlen = 0
StrDivL2:
	cmp 	rdx, rdi					;while (dividendlen > idx)
	jle 	StrDivL3
	
	;temp / divisor
	push 	rdx
	xor 	rdx, rdx
	mov 	rax, r15
	div 	r8							;temp / divisor
	
	;Quotient stored on rax, remainder on rdx
	add 	rax, 48						;temp / divisor + '0'
	
	mov 	byte [r9+r14], al			;out[outlen] = (temp / divisor) + '0';
	inc 	r14							;outlen ++
	
	mov 	rax, rdx 					;temp % divisor
	shl 	rdx, 1
	shl 	rax, 3
	add 	rdx, rax					;(temp % divisor) * 10 => rdx
	
	inc 	rdi							;++idx
	movzx 	r15, byte [rcx+rdi]			
	sub 	r15, 48						;dividend[++idx] - '0' => r15
	
	add 	r15, rdx					;temp = (temp % divisor) * 10 + dividend[++idx] - '0';
	
	pop 	rdx
	
	jmp 	StrDivL2
	
StrDivL3:
	test 	r14, r14
	jnz 	StrDivL4
	mov 	byte [r9+r14], 48
	inc 	r14
	
StrDivL4:	
	mov 	rax, r14 					;return value
	
	pop 	r14
	pop 	r15
	pop 	rdi
	pop 	rbx
	
	leave
	ret
	
;========================================================================================================================================
Atoi: 											;fast_call int64 Atoi(char* a <rcx>, int length <rdx>). 
												;convert string to int <rax>
	push    rbp 			
    mov     rbp, rsp	
	
	push 	rbx
	push 	rdi									;Non volatile register
	push 	r15									;callee-saved
												;according to window x64 calling convention
	;Parameter
	;rcx 		 : a
	;rdx 		 : length
	;
	;Local variable
	;
	;
	cmp 	rdx, 0								;check for length = 0
	je  	AtoiInvalid
;For loop description:
;Index: i = 0
;Condition: i < length
;Increment: i++
;
;Initialization block
	mov 	r15, rcx							;r15 is pointer to input buffer a
	;move to prepair for loopnz instruction
	mov 	rcx, rdx							;rcx is loop counter
	
	xor 	rdi, rdi							;int i = 0	
	xor 	rax, rax							;for return value

AtoiLoop:	
	lea 	r11, [r15+rdi]
	xor 	rbx, rbx
	mov 	bl, byte [r11]						;a[i]
	
	;Check if a[i] is digit or not
	;if a[i] is not digit then break
	cmp 	bl, 48								;48-57: 0-9 ASCII
	jl		AtoiInvalid							
	cmp 	bl, 57
	jg  	AtoiInvalid
	
	sub 	bl, 48
	
	; rax = rax * 10 + rbx . Use shl and add for optimization
	mov 	r9, rax 							;1 rax
	shl 	r9, 3								;8 rax
	add 	r9, rax								;9 rax	
	jc  	AtoiOutOfRange
	add 	r9, rax								;10 rax
	jc  	AtoiOutOfRange
	;rax += bl				
	add 	r9, rbx								;rax*10 + rbx
	jc  	AtoiOutOfRange
	mov		rax, r9
	
	;Increment block
	inc 	rdi
	loopnz 	AtoiLoop
AtoiEnd:	;After loop
	pop 	r15
	pop 	rdi
	pop 	rbx
	leave
	ret
AtoiOutOfRange:
;Print out of range message
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, outofrange
	mov 	rdx, outofrangelen
	syscall
	
	jmp 	AtoiInvalid
	
AtoiInvalid:
	mov 	rax, -1

	jmp 	AtoiEnd
;end of Atoi