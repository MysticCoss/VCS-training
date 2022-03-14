;Compile & link command
;nasm -f win64 -o b2_w.obj b2_w.asm 
;.\GoLink /files /console b2_w.obj kernel32.dll user32.dll

bits 64
default rel
segment .data
segment .text
	extern ExitProcess
	extern GetStdHandle
	extern ReadConsoleA
	extern WriteConsoleA
	extern wsprintfA
	extern HeapAlloc
	extern HeapReAlloc
	extern GetProcessHeap
global Start




Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 48							;Allocate 48 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -48 : HANDLE hHeap
	;offset -40 : char* s[258] //Include \r\n when read from console
	;offset -32  : int64 writtenlen
	;offset -24  : int64 slen
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
	mov 	[rbp-48], rax						;hHeap = GetProcessHeap()
	add 	rsp, 32								;Shadow store
	
	;s = HeapAlloc(hHeap,8,258)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-48]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 258							;number of byte allocated
	call	HeapAlloc							;s = HeapAlloc(hHeap,8,258)
	mov 	[rbp-40], rax	
	add 	rsp, 32								;Shadow store	
	
	;ReadConsoleA(hStdin, s, 258, &slen,0);
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-8]						;hStdin
	mov 	rdx, [rbp-40]						;s
	mov 	r8d, dword 258						;buf size = 258
	lea 	r9, [rbp-24]						;&slen byte read
	push 	0									;0
	call 	ReadConsoleA						;ReadConsoleA(hStdin, s, 258, &slen,0);
	add		rsp, 40								;Shadow store + clean up paramenter	
	
	;slen -= 2
	mov 	rax, [rbp-24]						;cut away \r\n			
	sub 	rax, 2
	mov 	[rbp-24], rax
	
	;append null byte to s
	mov 	rbx, [rbp-40]
	lea 	rcx, [rbx+rax]
	mov 	rcx, 0
	
	;s = HeapReAlloc(hHeap, 0, s, slen)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-48]						;hHeap
	xor 	rdx, rdx							;0 - no flag
	mov 	r8, [rbp-40]						;ptr s
	mov 	r9d, [rbp-24]						;slen
	call	HeapReAlloc							;s = HeapAlloc(hHeap, 0, s, slen)
	mov 	[rbp-56], rax
	add 	rsp, 32
	
	;reverse(s, slen)
	sub 	rsp, 32 							;Shadow store
	mov 	rcx, [rbp-40]						;ptr s
	mov 	rdx, [rbp-24]						;slen
	call	reverse								;reverse(char* a <rcx>, int length <rdx>)
	add 	rsp, 32
	
	;WriteConsoleA(hStdout, s, slen, &writtenlen, 0)
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-16]						;hStdout
	mov 	rdx, [rbp-40]						;s
	mov 	r8d, [rbp-24]						;slen
	lea		r9, [rbp-32]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, s, slen, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter
	
	;Exit
	mov 	rsp,rbp
    xor     rcx, rcx
    call    ExitProcess
	

reverse: 										;fast_call void reverse(char* a <rcx>, int length <rdx>). 
												;reverse passed string
	push    rbp 			
    mov     rbp, rsp	
	push 	rbx
	;Parameter
	;rcx 		 : a
	;rdx 		 : length
	;
	;Local variable
	;
	
	mov 	rax, rcx								;a.begin 
	lea 	rbx, [rcx+rdx-1]						;a+length-1 (aka a.end)
loop:	;just swap first and last characters and move on to inner characters
	cmp 	rax, rbx
	jg  	end
	mov 	cl, byte [rax]
    mov 	ch, byte [rbx]
    mov 	[rax], ch
    mov 	[rbx], cl
    dec 	rbx
    inc 	rax
    jmp 	loop
end:
	pop 	rbx
	leave
	ret
;end of reverse

	
	
