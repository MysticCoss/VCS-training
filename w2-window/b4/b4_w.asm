;Compile & link command
;nasm -f win64 -o b4_w.obj b4_w.asm 
;.\GoLink /files /console b4_w.obj kernel32.dll user32.dll

bits 64
default rel
segment .data
crlf db 13,10
segment .text
	extern ExitProcess
	extern GetStdHandle
	extern ReadConsoleA
	extern WriteConsoleA
	extern wsprintfA
	extern HeapAlloc
	extern HeapReAlloc
	extern GetProcessHeap
	extern FlushConsoleInputBuffer
global Start




Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 88							;Allocate 88 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -88  : int64 flag
	;offset -80  : HANDLE hHeap
	;offset -72  : char* out[21]
	;offset -64  : char* b[22]  //Include \r\n when read from console
	;offset -56  : char* a[22] //Include \r\n when read from console
	;offset -48	 : int64 count
	;offset -40  : int64 writtenlen
	;offset -32	 : int64 blen
	;offset -24  : int64 alen
	;offset -16	 : HANDLE hStdout
	;offset -8   : HANDLE hStdin
	
	;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	ecx, -10							;STD_INPUT_HANDLE 
	call 	GetStdHandle 						;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	[rbp-8], rax						
		
	;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)	
	mov 	ecx, -11							;STD_OUTPUT_HANDLE
	call 	GetStdHandle						;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	mov 	[rbp-16], rax	
	
	;hHeap = GetProcessHeap()
	sub 	rsp, 32								;Shadow store
	call 	GetProcessHeap
	mov 	[rbp-80], rax						;hHeap = GetProcessHeap()
	add 	rsp, 32								;Shadow store
	
	;a = HeapAlloc(hHeap,8,22)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 22								;number of byte allocated
	call	HeapAlloc							;a = HeapAlloc(hHeap,8,22)
	mov 	[rbp-56], rax	
	add 	rsp, 32								;Shadow store	
	
	;ReadConsoleA(hStdin, a, 22, &alen,0)
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-8]						;hStdin
	mov 	rdx, [rbp-56]						;a
	mov 	r8d, dword 22						;22
	lea 	r9, [rbp-24]						;&alen
	push 	0									;0
	call 	ReadConsoleA						;ReadConsoleA(hStdin, a, 22, &alen,0);
	add		rsp, 40								;Shadow store + clean up paramenter	
	
	;FlushConsoleInputBuffer(hStdin)
	sub 	rsp, 32 							;Shadow store
	mov 	rcx, [rbp-8]						;hStdin
	call 	FlushConsoleInputBuffer
	add 	rsp, 32
	
	;alen -= 2
	mov		rax, [rbp-24]
	sub 	rax, 2								;alen -= 2 - cut away \r\n
	mov 	[rbp-24], rax
	
	cmp		rax, 0
	jle		End
	
	;a = HeapReAlloc(hHeap, 0, a, alen)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	xor 	rdx, rdx							;0 - no flag
	mov 	r8, [rbp-56]						;ptr a
	mov 	r9d, [rbp-24]						;alen
	call	HeapReAlloc							;a = HeapAlloc(hHeap, 0, a, alen)
	mov 	[rbp-56], rax
	add 	rsp, 32
	
	;b = HeapAlloc(hHeap,8,22)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 22								;number of byte allocated
	call	HeapAlloc							;b = HeapAlloc(hHeap,8,22)
	mov 	[rbp-64], rax		
	add 	rsp, 32								;Shadow store
	
	;ReadConsoleA(hStdin, b, 22, &blen, 0);
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-8]						;hStdin
	mov 	rdx, [rbp-64]						;b
	mov 	r8d, dword 22						;22
	lea 	r9, [rbp-32]						;&blen
	push 	0									;0
	call 	ReadConsoleA						;ReadConsoleA(hStdin, c, 22, &blen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter											
	
	;blen -= 2
	mov 	rax, [rbp-32]
	sub 	rax, 2								;blen -= 2 - cut away \r\n	
	mov 	[rbp-32], rax
	
	cmp		rax, 0
	jle		End
	
	;b = HeapReAlloc(hHeap, 0, b, blen)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	xor 	rdx, rdx							;0 - no flag
	mov 	r8, [rbp-64]						;ptr b
	mov 	r9d, [rbp-32]						;blen
	call	HeapReAlloc							;b = HeapAlloc(hHeap, 0, b, blen)
	mov 	[rbp-64], rax
	add 	rsp, 32
	
	mov 	rax, [rbp-24]						;alen
	mov  	rbx, [rbp-32]						;blen
	;make sure a is longer
	cmp 	rax, rbx							
	jge		L0
	;swap alen, blen
	mov 	rax, [rbp-24]						;alen
	xchg	rax, [rbp-32]						
	mov		[rbp-24], rax						
	
	;swap alen, blen
	mov 	rax, [rbp-56]						;a
	xchg	rax, [rbp-64]						;b	
	mov		[rbp-56], rax						;swap a, b	
L0:
	
	mov 	rcx, [rbp-56]						;a
	mov 	rdx, [rbp-24]						;alen
	mov 	r8, [rbp-64]						;b
	mov 	r9, [rbp-32]						;blen	
	call	StrAdd 
	
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-16]						;hStdout
	mov 	rdx, [rbp-72]						;out
	mov 	r8d, eax							;outlen (stored on eax)
	mov		r9, [rbp-40]		
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, out, outlen, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter
	
	jmp 	End
StrAdd: ;int StrAdd(char* a, int alen, char* b, int blen)
		;                 RCX      RDX       R8       R9
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
	;out = HeapAlloc(hHeap,8,21)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, edi							;number of byte allocated
	call	HeapAlloc							;out = HeapAlloc(hHeap,8,21)
	mov 	[rbp-72], rax		
	add 	rsp, 32								;Shadow store
	
	;if carry flag still = 1 then push '1' to stack
	cmp 	r15, 1
	jne 	L8
	inc 	rdi
	push 	49
L8:	
	;for (int i = 0; i < count; i ++)
	;Initialization block
	mov 	r14, [rbp-72]						;ptr out = r14
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
	


End:
	mov 	rsp,rbp
	;0123456789
    xor     rcx, rcx
    call    ExitProcess
