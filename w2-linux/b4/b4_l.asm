;Compile & link command
;nasm -f elf64 -g ./b4_l.asm 
;ld b4_l.o -o b4_l

bits 64
default rel
segment .data
	lf db 10
	invalid db "Invalid input", 10
	AllocFail db "Allocatation Failed", 10
segment .text

global _start


_start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 48							;Allocate 48 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -40  : char* out[21]
	;offset -32  : char* b[21]  //Include \n when read from console
	;offset -24  : char* a[21] //Include \n when read from console
	;offset -16	 : int64 blen
	;offset -8  : int64 alen
	
	;Get top address of bss
	;syscall a = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-24], rax						;save current address
	
	;add 21 to that address
	add 	rax, 21		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 21 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-24]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;alen = read(stdin = 0, a, 21)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-24]						;void* a
	mov 	rdx, 21								;num byte read
	syscall
	mov 	[rbp-8], rax
	
	;alen -= 1
	mov		rax, [rbp-8]
	sub 	rax, 1								;alen -= 1 - cut away \n
	mov 	[rbp-8], rax
	
	;verify alen > 0
	cmp		rax, 0
	jle		EndInvalid
	
	;resize a to fit
	mov 	rbx, [rbp-24] 						;a address
	add 	rbx, rax 							;a+alen
	
	mov 	rax, 12								;syscall brk
	mov 	rdi, rbx 							;a+slen
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-24]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Get top address of bss
	;syscall b = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-32], rax						;save current address
	
	;add 21 to that address
	add 	rax, 21		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 21 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-32]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;blen = read(stdin = 0, b, 21)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-32]						;void* b
	mov 	rdx, 21							;num byte read
	syscall
	mov 	[rbp-16], rax
	
	;blen -= 1
	mov		rax, [rbp-16]
	sub 	rax, 1								;blen -= 1 - cut away \n
	mov 	[rbp-16], rax
	
	;verify blen > 0
	cmp		rax, 0
	jle		EndInvalid
	
	;resize s to fit
	mov 	rbx, [rbp-32] 						;b address
	add 	rbx, rax 							;b+blen
	
	mov 	rax, 12								;syscall brk
	mov 	rdi, rbx 							;b+blen
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-32]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	
	mov 	rax, [rbp-8]						;alen
	mov  	rbx, [rbp-16]						;blen
	;make sure a is longer
	cmp 	rax, rbx							
	jge		L0
	;swap alen, blen
	mov 	rax, [rbp-8]						;alen
	xchg	rax, [rbp-16]						
	mov		[rbp-8], rax						
	
	;swap alen, blen
	mov 	rax, [rbp-24]						;a
	xchg	rax, [rbp-32]						;b	
	mov		[rbp-24], rax						;swap a, b	
L0:
	mov 	rdi, [rbp-24]						;a
	mov 	rsi, [rbp-8]						;alen
	mov 	rdx, [rbp-32]						;b
	mov 	rcx, [rbp-16]						;blen	
	call	StrAdd 
	;return on rax
	
	;syscall write(stdout=1,out,outlen)
	mov 	rdx, rax							;num char write
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-40]						;out
	syscall				
	
	jmp 	End
StrAdd: ;int StrAdd(char* a, int alen, char* b, int blen)
		;EAX 			  RDI      RSI	     RDX     RCX
		
	;Window x64 compatibility
	mov 	r9, rcx
	mov 	r8, rdx
	mov 	rdx, rsi
	mov 	rcx, rdi		
	
	;RCX: a begin
	;R8: b begin
	;R10: a.end() = iterator
	;R11: b.end() = iterator
	
	;Initialization block
	xor 	r15, r15							;r15 used as carry flag
	xor 	rdi, rdi 							;count
	lea 	r10, [rcx+rdx-1]
	lea 	r11, [r8+r9-1]
loop_1:
	;comparison block
	cmp 	r10, rcx							;if iterator a < a.begin -> Quit loop	
	jl 		process
	
	;loop block
	;load last byte of a and verify number
	movzx 	rax, byte [r10]
	cmp 	al, 48
	jl  	End
	cmp 	al, 57
	jg  	End
	
	cmp 	r11, r8								;if iterator b >= b.begin -> Load byte from memory
	jge  	L3
	jmp 	L4
L3:
	;load last byte of b and verify number
	movzx 	rbx, byte [r11]						
	cmp 	bl, 48
	jl  	End
	cmp 	bl, 57
	jg  	End
	jmp 	L5
L4:	
	;load 48 (ascii 0) to rbx
	mov 	rbx, 48
	jmp 	L5
L5:
	add 	rax, rbx							;a last + b last
	add 	rax, r15							;a last + b last + carry (r15)
	xor 	r15, r15							;clear carry flag
	sub 	rax, 96
	
	cmp 	rax, 10
	jl		L2
	mov 	r15, 1								;set carry flag
	sub 	rax, 10								;lower decimal number
L2:
	add 	rax, 48								;ascii represent
	
	inc 	rdi									;count++
	push	rax
	
	;increment block
	dec 	r10
	dec 	r11
	jmp 	loop_1
	
process:
	;Allocate output buffer
	push 	rdi
	;syscall out = brk(null)					;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-40], rax						;save current address
	
	pop 	rdi									;char counter
	
	;Add address to rdi and call brk again to allocate
	add 	rax, rdi
	push    rdi
	
	mov 	rdi, rax
	mov 	rax, 12
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	pop 	rdi
	;if carry flag still = 1 then push '1' to stack
	cmp 	r15, 1
	jne 	L8
	inc 	rdi
	push 	49
L8:	
	;for (int i = 0; i < count; i ++)
	;Initialization block
	mov 	r14, [rbp-40]						;ptr out = r14
	xor 	r15, r15							;int i   = r15
												;count   = rdi
L7:
	;Comparison block
	;if (i < count then continue)
	cmp 	r15, rdi 							
	jl 		L6
	mov 	eax, edi
	ret
L6:	;Loop block
	pop 	rax
	mov 	byte [r14], al
	
	inc 	r15
	inc 	r14
	;Increment block
	jmp 	L7
	
EndInvalid:
	;Print invalid message
		;syscall write(stdout=1,"Invalid input",14)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, invalid						;"Invalid input"
	mov 	rdx, 14								;num char write
	syscall	

	jmp 	EndSyscall

End:
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf								;"\n"
	mov 	rdx, 1								;num char write
	syscall	

	jmp 	EndSyscall
EndAllocationFailed:
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, AllocFail						
	mov 	rdx, 39								;num char write
	syscall	

	jmp 	EndSyscall
EndSyscall:
	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall

