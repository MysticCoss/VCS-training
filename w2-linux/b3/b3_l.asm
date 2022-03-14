;Compile & link command
;nasm -f elf64 -g ./b3_l.asm 
;ld b3_l.o -o b3_l

bits 64
default rel
segment .data
	lf db 10
	invalid db "Invalid input", 10
	AllocFail db "Allocation Failed", 10
segment .text

global _start




_start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 80								;Allocate 80 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -72 : int64 outlen
	;offset -64 : char* s[4] //Include \n when read from console
	;offset -56  : int64 slen
	;offset -48  : char* out[21]
	;offset -40  : char* b[21]  //Include \n when read from console
	;offset -32  : char* a[21] //Include \n when read from console
	;offset -24	 : int64 count
	;offset -16	 : int64 blen
	;offset -8  : int64 alen
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;syscall s = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-64], rax						;save current address
	
	;add 4 to that address
	add 	rax, 4		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 4 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-64]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;slen = read(stdin = 0, s, 4)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-64]						;void* s
	mov 	rdx, 4								;num byte read
	syscall
	mov 	[rbp-56], rax						;slen
	
	;slen -= 1
	mov		rax, [rbp-56]
	sub 	rax, 1								;slen -= 1 - cut away \n
	mov 	[rbp-56], rax
	
	;resize s to fit
	mov 	rbx, [rbp-64] 						;s address
	add 	rbx, rax 							;s+slen
	
	mov 	rax, 12								;syscall brk
	mov 	rdi, rbx 							;s+slen
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-64]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	

	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;syscall a = brk(null)						;Get top address of bss session
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
	;syscall b = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-40], rax						;save current address
	
	;add 21 to that address
	add 	rax, 21		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 21 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;syscall out = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-48], rax						;save current address
	
	;add 21 to that address
	add 	rax, 21		
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 21 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;check allocation failed
	cmp 	rax, qword [rbp-48]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack
	;count = stoi(s, slen)
	mov 	rdi, [rbp-64]						;ptr s
	mov 	rsi, [rbp-56]						;slen
	call	stoi								;stoi(char* a <rcx>, int length <rdx>)
	mov 	[rbp-24], rax						;count
	cmp 	rax, 100
	jg  	EndInvalid
	cmp 	rax, 0
	jle 	EndInvalid
	
	;NOTE: a is higher number
	
	;Initialization a = 1, b = 0
	
	;a[0] = '1'
	mov 	rax, [rbp-32]
	mov  	[rax], byte 49						;'1'
	
	
	;b[0] = '0'
	mov 	rax, [rbp-40]
	mov 	[rax], byte 48						;'0'
	
	;alen = 1
	mov 	qword [rbp-8], 1
	
	;blen = 1
	mov 	qword [rbp-16], 1
	
	
MainL1:	
	;Comparison
	mov 	rax, [rbp-24]						;count
	cmp 	rax, 0
	jg 		MainL0
	jmp 	End
	;Loop
	;[rax]return_length = StrAdd(a, alen, b, blen) 
	;Output string to *out
MainL0:

	;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack
	mov 	rdi, [rbp-32]						;a
	mov 	rsi, [rbp-8]						;alen
	mov 	rdx, [rbp-40]						;b
	mov 	rcx, [rbp-16]						;blen				
	call	StrAdd 					
	
	mov 	[rbp-72], rax						;outlen = StrAdd(a, alen, b, blen) -> write buffer : *out
	
	;syscall write(stdout=1,out,outlen)
	mov 	rdx, rax							;num char write = outlen
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-48] 						;out
	syscall	
	
	;syscall write(stdout=1,lf,1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf		 						;lf
	mov 	rdx, 1								;1
	syscall	
	
	mov 	r15, [rbp-40]						;b = r15
	
	;move a->b
	mov 	rax, [rbp-32]						;a
	mov 	[rbp-40], rax						;a->b
	;alen -> blen
	mov 	rax, [rbp-8]						;alen
	mov 	[rbp-16], rax						;alen->blen
	;and move out -> a
	mov 	rax, [rbp-48]						;out
	mov 	[rbp-32], rax						;out->a
	;move outlen -> alen
	mov 	rax, [rbp-72]						;outlen
	mov 	[rbp-8], rax						;outlen->alen
	
	;move b->out
	mov 	[rbp-48], r15
	
	;Incremet
	mov 	rax, [rbp-24]						;count++
	dec 	rax
	mov 	[rbp-24], rax
	
	jmp		MainL1
	
;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack	
StrAdd: ;int StrAdd(char* a, int alen, char* b, int blen)
		;EAX 			  RDI      RSI	     RDX     RCX
		
	;Window x64 compatibility
	mov 	r9, rcx
	mov 	r8, rdx
	mov 	rdx, rsi
	mov 	rcx, rdi
	
	;Some useful local variable
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
	jge  	StrAddL3
	jmp 	StrAddL4
StrAddL3:
	;load last byte of b and verify number
	movzx 	rbx, byte [r11]						
	cmp 	bl, 48
	jl  	End
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
	dec 	r10
	dec 	r11
	jmp 	loop_1
	
process: 
	;if carry flag still = 1 then push '1' = 49 to stack
	cmp 	r15, 1
	jne 	StrAddL8
	inc 	rdi
	push 	49

StrAddL8:	
	;for (int i = 0; i < count; i ++)
	;Initialization block
	mov 	r14, [rbp-48]						;ptr out = r14
	xor 	r15, r15							;int i   = r15
												;count   = rdi
StrAddL7:
	;Comparison block
	;if (i < count then continue)
	cmp 	r15, rdi 							
	jl 		StrAddL6
	mov 	eax, edi
	ret
StrAddL6:	;Loop block
	pop 	rax
	mov 	byte [r14], al
	
	inc 	r15
	inc 	r14
	;Increment block
	jmp 	StrAddL7
	
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
	;syscall write(stdout=1,"Allocation failed\n",1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, AllocFail						
	mov 	rdx, 18								;num char write
	syscall	

	jmp 	EndSyscall
EndSyscall:
	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall


;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack	
stoi: 											;fast_call int64 stoi(char* a <rdi>, int length <rsi>). 
												;convert string to int <rax>
	push    rbp 			
    mov     rbp, rsp	
	
	;Window x64 compatibility
	mov 	rcx, rdi
	mov 	rdx, rsi
	;Parameter
	;rcx 		 : a
	;rdx 		 : length
	;
	;Local variable
	;
	;
	
;For loop description:
;Index: i = 0
;Condition: i < length
;Increment: i++
;
;Initialization block
	xor 	rdi, rdi							;int i = 0	
	xor 	rax, rax							;for return value
L1: ;Comparison block
	cmp 	rdi, rdx							;i < length					
	jl  	loop		
	jmp 	end
loop:	;just swap first and last characters and move on to inner characters
	lea 	r11, [rcx+rdi]
	xor 	rbx, rbx
	mov 	bl, byte [r11]						;a[i]
	
	;Check if a[i] is digit or not
	;if a[i] is not digit then break
	cmp 	bl, 48								;48-57: 0-9 ASCII
	jl		Invalid							
	cmp 	bl, 57
	jg  	Invalid
	
	sub 	bl, 48
	
	; rax *= 10 . Use add for optimization
	mov 	r9, rax 							;1 rax
	add 	r9, rax								;2 rax								
	add 	r9, rax								;3 rax
	add 	r9, rax								;4 rax
	add 	r9, rax								;5 rax
	add 	r9, rax								;6 rax
	add 	r9, rax								;7 rax
	add 	r9, rax								;8 rax
	add 	r9, rax								;9 rax
	add 	r9, rax								;10 rax
	
	;rax += bl				
	add 	r9, rbx						
	mov		rax, r9
	
    jmp 	L9
L9: ;Increment block
	inc 	rdi
	jmp 	L1
end:	;After loop
	leave
	ret
;end of stoi

Invalid:
	mov 	rax, -1
	
	leave
	ret 	