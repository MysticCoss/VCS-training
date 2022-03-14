;Compile & link command
;nasm -f win64 -o b3_w.obj b3_w.asm 
;.\GoLink /files /console b3_w.obj kernel32.dll user32.dll

bits 64
default rel
segment .data
crlf db 13,10
invalid db "Invalid input", 0
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
	sub		rsp, 112							;Allocate 112 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -112 : int64 outlen
	;offset -104 : char* s[5] //Include \r\n when read from console
	;offset -96  : int64 slen
	;offset -88  : int64 flag
	;offset -80  : HANDLE hHeap
	;offset -72  : char* out[21]
	;offset -64  : char* b[21]  //Include \r\n when read from console
	;offset -56  : char* a[21] //Include \r\n when read from console
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
	
	;a = HeapAlloc(hHeap,8,21)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 21								;number of byte allocated
	call	HeapAlloc							;a = HeapAlloc(hHeap,8,21)
	mov 	[rbp-56], rax	
	add 	rsp, 32								;Shadow store	
		
	;b = HeapAlloc(hHeap,8,21)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 21								;number of byte allocated
	call	HeapAlloc							;b = HeapAlloc(hHeap,8,21)
	mov 	[rbp-64], rax		
	add 	rsp, 32								;Shadow store
	
	;out = HeapAlloc(hHeap,8,21)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 21								;number of byte allocated
	call	HeapAlloc							;out = HeapAlloc(hHeap,8,21)
	mov 	[rbp-72], rax		
	add 	rsp, 32								;Shadow store
					
	;s = HeapAlloc(hHeap,8,5)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	mov 	edx, 8								;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 5								;number of byte allocated
	call	HeapAlloc							;s = HeapAlloc(hHeap,8,5)
	mov 	[rbp-104], rax	
	add 	rsp, 32								;Shadow store	
	
	;ReadConsoleA(hStdin, s, 5, &slen,0);
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-8]						;hStdin
	mov 	rdx, [rbp-104]						;s
	mov 	r8d, dword 5						;buf size = 5
	lea 	r9, [rbp-96]						;&slen byte read
	push 	0									;0
	call 	ReadConsoleA						;ReadConsoleA(hStdin, s, 5, &slen,0);
	add		rsp, 40								;Shadow store + clean up paramenter	
	
	;slen -= 2
	mov 	rax, [rbp-96]						;cut away \r\n			
	sub 	rax, 2
	mov 	[rbp-96], rax
	
	;append null byte to s
	;mov 	rbx, [rbp-104]
	;lea 	rcx, [rbx+rax]
	;mov 	rcx, 0
	
	;s = HeapReAlloc(hHeap, 0, s, slen)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [rbp-80]						;hHeap
	xor 	rdx, rdx							;0 - no flag
	mov 	r8, [rbp-104]						;ptr s
	mov 	r9d, [rbp-96]						;slen
	call	HeapReAlloc							;s = HeapReAlloc(hHeap, 0, s, slen)
	mov 	[rbp-104], rax
	add 	rsp, 32
	
	;count = stoi(s, slen)
	sub 	rsp, 32 							;Shadow store
	mov 	rcx, [rbp-104]						;ptr s
	mov 	rdx, [rbp-96]						;slen
	call	stoi								;stoi(char* a <rcx>, int length <rdx>)
	add 	rsp, 32
	mov 	[rbp-48], rax						;count
	cmp 	rax, 100
	jg  	EndInvalid
	cmp 	rax, 0
	jle 	EndInvalid
	
	;NOTE: a is higher number
	;Local variable:
	;offset -112 : int64 outlen
	;offset -104 : char* s[5] //Include \r\n when read from console
	;offset -96  : int64 slen
	;offset -88  : int64 flag
	;offset -80  : HANDLE hHeap
	;offset -72  : char* out[21]
	;offset -64  : char* b[21]  //Include \r\n when read from console
	;offset -56  : char* a[21] //Include \r\n when read from console
	;offset -48	 : int64 count
	;offset -40  : int64 writtenlen
	;offset -32	 : int64 blen
	;offset -24  : int64 alen
	;offset -16	 : HANDLE hStdout
	;offset -8   : HANDLE hStdin
	
	;Initialization a = 1, b = 0
	
	;a[0] = '1'
	mov 	rax, [rbp-56]
	mov  	[rax], byte 49						;'1'
	
	
	;b[0] = '0'
	mov 	rax, [rbp-64]
	mov 	[rax], byte 48						;'0'
	
	;alen = 1
	mov 	qword [rbp-24], 1
	
	;blen = 1
	mov 	qword [rbp-32], 1
	
	
MainL1:	
	;Comparison
	mov 	rax, [rbp-48]						;count
	cmp 	rax, 0
	jg 		MainL0
	jmp 	End
	;Loop
	;[rax]return_length = StrAdd(a, alen, b, blen) 
	;Output string to *out
MainL0:

	
	mov 	rcx, [rbp-56]						;a
	mov 	rdx, [rbp-24]						;alen
	mov 	r8, [rbp-64]						;b
	mov 	r9, [rbp-32]						;blen				
	call	StrAdd 					
	
	mov 	[rbp-112], rax						;outlen = StrAdd(a, alen, b, blen) -> write buffer : *out
	
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-16]						;hStdout
	mov 	rdx, [rbp-72]						;out
	mov 	r8d, eax							;outlen (stored on eax)
	mov		r9, [rbp-40]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, out, outlen, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter
	
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-16]						;hStdout
	mov 	rdx, crlf							;crlf
	mov 	r8d, 2								;2
	mov		r9, [rbp-40]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, crlf, 2, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter
	
	;Local variable:
	;offset -112 : int64 outlen
	;offset -104 : char* s[5] //Include \r\n when read from console
	;offset -96  : int64 slen
	;offset -88  : int64 flag
	;offset -80  : HANDLE hHeap
	;offset -72  : char* out[21]
	;offset -64  : char* b[21]  //Include \r\n when read from console
	;offset -56  : char* a[21] //Include \r\n when read from console
	;offset -48	 : int64 count
	;offset -40  : int64 writtenlen
	;offset -32	 : int64 blen
	;offset -24  : int64 alen
	;offset -16	 : HANDLE hStdout
	;offset -8   : HANDLE hStdin
	
	
	mov 	r15, [rbp-64]						;b = r15
	
	;move a->b
	mov 	rax, [rbp-56]						;a
	mov 	[rbp-64], rax						;a->b
	;alen -> blen
	mov 	rax, [rbp-24]						;alen
	mov 	[rbp-32], rax						;alen->blen
	;and move out -> a
	mov 	rax, [rbp-72]						;out
	mov 	[rbp-56], rax						;out->a
	;move outlen -> alen
	mov 	rax, [rbp-112]						;outlen
	mov 	[rbp-24], rax						;outlen->alen
	
	;move b->out
	mov 	[rbp-72], r15
	
	;Incremet
	mov 	rax, [rbp-48]						;count++
	dec 	rax
	mov 	[rbp-48], rax
	
	jmp		MainL1
	
	
StrAdd: ;int StrAdd(char* a, int alen, char* b, int blen)
		;EAX                RCX      RDX       R8       R9
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
	mov 	r14, [rbp-72]						;ptr out = r14
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
	sub 	rsp, 32								;Shadow store
	mov		rcx, [rbp-16]						;hStdout
	mov 	rdx, invalid						;"Invalid input"
	mov 	r8d, 14								;14
	mov		r9, [rbp-40]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, "Invalid input", 14, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter

	mov 	rsp,rbp
    xor     rcx, rcx
    call    ExitProcess

End:
	mov 	rsp,rbp
	;0123456789
    xor     rcx, rcx
    call    ExitProcess

stoi: 											;fast_call int64 stoi(char* a <rcx>, int length <rdx>). 
												;convert string to int <rax>
	push    rbp 			
    mov     rbp, rsp	
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