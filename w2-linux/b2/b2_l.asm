;Compile & link command
;nasm -f elf64 -g ./b2_w.asm 
;ld b2_l.o -o b2_l

bits 64
default rel
segment .data
segment .text
	lf db 10
	AllocFail db "Allocation Failed", 10
global _start




_start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 16							;Allocate 16 bytes in stack
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	
	;Local variable:
	;offset -8  : int64 slen
	;offset -16	 : char* s[257]
	
	;allocate memory for s
	;syscall s = brk(null)						;Get top address of bss session
	mov 	rax, 12								;syscall number: brk
	xor 	rdi, rdi							;null		
	syscall
	mov 	[rbp-16], rax						;save current address
	
	;add 256 to that address
	add 	rax, 257							
	
	;syscall brk with new address
	;the bss session will be expanded to new addreess
	;it means we have allocated 256 byte in bss session
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	cmp 	rax, qword [rbp-16]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;slen = read(stdin = 0, s, 101)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-16]						;void* s
	mov 	rdx, 257							;num byte wanna read
	syscall
	mov 	[rbp-8], rax						;num byte read
	
	;if (slen < 256) slen -= 1 //terminal behaviour
	cmp 	rax, 256
	je 	    continue
	sub 	rax, 1
	mov 	[rbp-8], rax
	jmp 	continue
	
continue:

	;resize heap to fit s - avoid memory leak
	;syscall s = brk(null)						
	mov 	rdi, [rbp-16]						;address of s
	add 	rdi, [rbp-8]						;add that address with slen
	mov 	rax, 12								;syscall brk(new address)
	syscall

	;reverse(s, slen)
	mov 	rdi, [rbp-16]						;ptr s
	mov 	rsi, [rbp-8]						;slen
	call	reverse								;reverse(char* a <rcx>, int length <rdx>)
	
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-16]						;s
	mov 	rdx, [rbp-8]						;num char write = slen
	syscall	
	jmp 	End
End:
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf								;"\n"
	mov 	rdx, 1								;num char write
	syscall	

	;Exit
	mov 	rsp, rbp
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
;user mode calling convention parameter passing: RDI, RSI, RDX, RCX, R8, R9, stack
reverse: 										;void reverse(char* a <rdi>, int length <rsi>). 
												;reverse passed string
	push    rbp 			
    mov     rbp, rsp	
	
	push 	rbx									;callee-saved register
	;Parameter
	;rdi 		 : a
	;rsi 		 : length
	
	;Window x64 compatibility
	mov 	rcx, rdi
	mov 	rdx, rsi
	
	;Parameter
	;rcx 		 : a
	;rdx 		 : length
	
	mov 	rax, rcx							;a.begin 
	lea 	rbx, [rcx+rdx-1]					;a+length-1 (aka a.end)
loop:	;just swap first and last characters and move on to inner characters
	cmp 	rax, rbx
	jg  	rend
	mov 	cl, byte [rax]
    mov 	ch, byte [rbx]
    mov 	[rax], ch
    mov 	[rbx], cl
    dec 	rbx
    inc 	rax
    jmp 	loop
rend:
	pop 	rbx
	leave
	ret
;end of reverse