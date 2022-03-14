;Compile & link command
;nasm -f elf64 -g ./b1_l.asm 
;ld b1_l.o -o b1_l

bits 64
default rel
segment .data
	space db ' '
	lf db 10
	AllocFail db "Allocation Failed", 10
segment .bss

segment .text

global _start


_start:
    push    rbp
    mov     rbp, rsp
	sub		rsp, 64								;Allocate 64 bytes in stack
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;syscall number in RAX
	;RCX and R11 destroyed
	;return value RAX
	
	;Local variable:
	;offset -56 : void* o[100]
	;offset -48 : void* c[11]
	;offset -40 : void* s[101]
	;offset -32  : int64 flag
	;offset -24	 : int64 count
	;offset -16	 : int64 clen
	;offset -8  : int64 slen
	
	
	;Allocate output buffer for convenient
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;Get top address of bss
	;syscall o = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-56], rax						;o = current address
	
	;add 100 to that address
	add 	rax, 100		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it mean that we have allocated 100 byte in bss session for o
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-56]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Initialization local variable
	lea		rax, [rbp-24]
	mov 	rax, 0 								;count = 0
	
	lea 	rax, [rbp-32]						
	mov 	rax, 0								;flag = 0
	
	;Get top address of bss
	;syscall s = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-40], rax						;save current address
	
	;add 101 to that address
	add 	rax, 101		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 101 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;slen = read(stdin = 0, s, 101)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-40]						;void* s
	mov 	rdx, 101							;num byte read
	syscall
	mov 	[rbp-8], rax
	
	;slen -= 1
	mov		rax, [rbp-8]
	sub 	rax, 1								;slen -= 1 - cut away \n
	mov 	[rbp-8], rax
	
	cmp 	rax, 0								;if slen = 0 then skip realloc (jump L0)
	je		L0
	
	;resize s to fit
	mov 	rbx, [rbp-40] 						;s address
	add 	rbx, rax 							;s+slen
	
	mov 	rax, 12								;syscall brk
	mov 	rdi, rbx 							;s+slen
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed

L0:	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	
	;Get top address of bss
	;syscall c = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-48], rax						;save current address
	
	;add 11 to that address
	add 	rax, 11		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it mean that we have allocated 11 byte in bss session for c
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-48]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	
	;clen = read(stdin = 0, c, 101)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-48]						;void* c
	mov 	rdx, 101							;num byte read
	syscall
	mov 	[rbp-16], rax						;clen
	
	;clen -= 1
	mov 	rax, [rbp-16]
	sub 	rax, 1								;clen -= 1 - cut away \n	
	mov 	[rbp-16], rax
	
	cmp 	rax, 0								;if clen = 0 then skip realloc (jump L2)
	je		L2
	
	;resize c to fit
	mov 	rbx, [rbp-48] 						;c address
	add 	rbx, rax 							;c+clen
	
	mov 	rax, 12								;syscall brk
	mov 	rdi, rbx 							;c+clen
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-48]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
L2:	
	jmp 	printposition
	
printposition:
	mov 	rax, [rbp-8]						;slen
	mov 	rbx, [rbp-16]						;clen
	cmp 	rax, rbx							;if (slen < clen) then skip compair
	jl		Quitloop
	
	;for(int i=0;i<slen-clen+1;i++) { //skip checking when remaining digits is fewer than clen :) 
initialization_1:	
	xor 	r15, r15							;loop index i = 0
Comparison_1:
	mov 	rax, [rbp-8]						;slen
	mov 	rbx, [rbp-16]						;clen
	sub 	rax, rbx							;slen - clen
	add 	rax, 1								;slen - clen + 1
	cmp 	r15, rax							
	jl		Loop_1								;if (i<slen)
	jmp		Quitloop
Loop_1:
	mov 	r9, [rbp-40]								;s address
	movzx 	rax, byte [r9+r15]					;s[i]
	mov 	r9, [rbp-48]								;c address
	movzx 	rbx, byte [r9]						;c[0]
	cmp 	al, bl
	jne 	Increment_1							;if (s[i] == c[0]) call match(s+i,c,clen)
	mov 	rdi, [rbp-40]								;s
	add 	rdi, r15							;s+i
	mov 	rsi, [rbp-48]								;c
	mov		rdx, [rbp-16]						;clen
	call	match								;match(s+i,c,clen)
	cmp 	rax, 0
	je 		Increment_1							;if return value of match == 0, skip
	
	mov 	rax, [rbp-32] 						;flag
	cmp 	rax, 0								;if flag == 0 then skip
	je 		L1	
	mov 	rdi, r15							;else PrintInt(rdi)
	call 	PrintInt
L1:
	mov 	rax, [rbp-24]							
	add		rax, 1								;else count++
	mov 	[rbp-24], rax
	jmp 	Increment_1
Increment_1:
	inc 	r15 								;loop counter i++
	jmp 	Comparison_1
	
;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack
match: 											;fast_call int64 match(char* a <RDI>, char* b <RSI>, int limit <RDX>). 
												;Ret 1 means string equal, ret 0 means not equal (RAX)
	push    rbp 			
    mov     rbp, rsp	
	
	push 	r15									;callee-saved register
	
	;for window x64 compatibility
	mov 	r8, rdx
	mov 	rcx, rdi
	mov 	rdx, rsi
	xor 	rax, rax
	;Parameter
	;rcx 		 : a
	;rdx 		 : b
	;r8 		 : limit
	;Local variable
	;offset -8   : int64 i
	
	;for(int i = 0; i < limit ; i++)
Initialization_2:
	xor 	r9, r9								;r9 is reverse for i

Comparison_2:
	cmp 	r9, r8								
	jl		Loop_2								;if i <r9>  <  limit <r8> then go to Loop_2
	jmp 	R1									;exit loop	
Loop_2:
	movzx	rax, byte [rcx + r9]				;a[i]
	movzx 	rbx, byte [rdx + r9]				;b[i]
	cmp 	al, bl								;if a[i] == b[i] then move to the next loop
	je		Increment_2							;else return 0
	jmp 	R0									;return 0
Increment_2:
	inc 	r9 									;i++
	jmp 	Comparison_2
R0: ;return 0
	xor 	rax, rax							;prepair return value
	jmp 	REND
R1: ;return 1
	mov 	rax, 1								;prepair return value
	jmp 	REND									
REND:
	pop 	r15
	leave
	ret
;end of match()
Quitloop:

	mov 	rax, [rbp-32]						;flag						
	cmp 	qword [rbp-32], 1					;if flag == 1 then end
	je 		End
	
	mov 	rdi, [rbp-24]						;count
	call 	PrintInt							;PrintInt(count)
	
	;print line feed
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf								;"\n"
	mov 	rdx, 1								;num char write
	syscall										
	
	;flag = 1
	mov 	qword [rbp-32], 1
	
	jmp 	printposition
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
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, AllocFail						
	mov 	rdx, 18								;num char write
	syscall	

	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall
	
;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9
PrintInt: ;int64[RAX] PrintInt(int i[rdi])
;Return number of chars written

	;rdi : i
	mov 	rsi, [rbp-56]
	call 	itoa								;return number of char in rax = outlen
	
	;syscall write(stdout=1,out,outlen)
	mov 	rdx, rax							;num char write = outlen
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-56] 								;out
	syscall	
	
	;syscall write(stdout=1,out,1)
	mov 	rdx, 1								;num char write = outlen
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, space 							;space
	syscall	
	
	ret

;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9
itoa: ;int[rax] itoa(int64[rdi], void* buf[rsi])
;Convert number in RDI to ascii-decimal representation on buffer point to by RSI. 
;Return number of characters written

;Pre-check
 
	push 	r15									;Non volatile register - callee save
	push 	r14
	push 	r13
	push 	r12
	
	mov 	rcx, rdi							;Maintain compatibility with win x64 calling convention
	mov 	rdx, rsi
	
	cmp 	rcx,0
	jg 		itoaL0
	mov 	byte[rdx], 48
	mov 	r15d, 1
	jmp 	itoaEnd
;Initialization
itoaL0:
	
	xor  	r15, r15							;r15: char count = 0
	mov 	r14, rdx							;r14: buffer
	mov 	rax, rcx							;rax: dividend
itoaL1:
	;Comparison
	cmp  	rax, 0
	je  	itoaL2
	
	;Loop
	xor 	rdx, rdx							;[rdx:rax] = rax (zero rdx)
	mov 	r12, 10											
												;rax / 10
	div 	r12 								;rax: Quotient, rdx: Remainder
	
	add 	rdx, 48								;convert to ascii char
	push	rdx									;push remainter on stack
	inc 	r15									;counter++
	jmp 	itoaL1
itoaL2:
	;for (r13 = 0 , (loop counter)r13 < r15(char counter), r13++)
	;Initialization
	xor 	r13, r13 							;loop counter = 0
itoaL3:	
	;Comparison
	cmp 	r13, r15							;if r13 < r15 -> enter loop
	jl  	itoaL4								;else quit
	jmp 	itoaEnd
itoaL4:
	pop 	rax
	mov		byte [r14], al
	inc 	r13
	inc 	r14
	jmp 	itoaL3
itoaEnd:
	mov 	eax, r15d							;return char count
	
	pop 	r12
	pop 	r13									;Callee save register
	pop 	r14
	pop 	r15
	
	ret
	