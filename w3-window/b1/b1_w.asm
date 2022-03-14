;Compile & link command
;nasm -f win64 -g -o b1_w.obj b1_w.asm 
;.\GoLink /files /console /debug coff b1_w.obj kernel32.dll

bits 64
default rel
segment .data
	crlf db 13,10
	invalid db "Invalid input", 0
	invalidlen equ $-invalid
	info db "Input array number : ", 0
	infolen equ $-info
	outofrange db "Number out of range", 10, 0
	outofrangelen equ $-outofrange
	nan db "Not a number", 0
	nanlen equ $-nan
	max db "Max : ", 0
	maxlen equ $-max
	min db "Min : ", 0
	minlen equ $-min
segment .bss
	hStdin resq 1
	hStdout resq 1
	hHeap resq 1
segment .text
	extern ExitProcess
	extern GetStdHandle
	extern ReadConsoleA
	extern WriteConsoleA
	extern HeapAlloc
	extern HeapReAlloc
	extern GetProcessHeap
global Start




Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 64								;Allocate 64 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -56 : char* s[5] //Include \r\n when read from console
	;offset -48  : int64 slen
	;offset -40  : char* out[21]
	;offset -32  : char* a[21] //Include \r\n when read from console
	;offset -24	 : int64 count
	;offset -16  : int64 writtenlen
	;offset -8  : int64 alen
	

	;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	ecx, -10								;STD_INPUT_HANDLE 
	call 	GetStdHandle 							;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	[hStdin], rax							
		
	;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)		
	mov 	ecx, -11								;STD_OUTPUT_HANDLE
	call 	GetStdHandle							;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	mov 	[hStdout], rax		
		
	sub 	rsp, 32									;Shadow store
	mov		rcx, [hStdout]							;hStdout
	mov 	rdx, info								;"Input array number : ", 0
	mov 	r8d, infolen							;infolen
	mov		r9, [rbp-16]							;&writtenlen
	push 	0	
	call 	WriteConsoleA							;WriteConsoleA(hStdout, "Input array number : ", infolen, &writtenlen, 0);
	add		rsp, 40									;Shadow store + clean up paramenter
		
	;hHeap = GetProcessHeap()	
	sub 	rsp, 32									;Shadow store
	call 	GetProcessHeap	
	mov 	[hHeap], rax							;hHeap = GetProcessHeap()
	add 	rsp, 32									;Shadow store
		
	;a = HeapAlloc(hHeap,8,800)	
	sub 	rsp, 32									;Shadow store
	mov 	rcx, [hHeap]							;hHeap
	mov 	edx, 8									;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 800								;number of byte allocated
	;800 bytes for 100 int number	
	call	HeapAlloc								;a = HeapAlloc(hHeap,8,800)
	mov 	[rbp-32], rax	
	add 	rsp, 32									;Shadow store
							
		
	;out = HeapAlloc(hHeap,8,10)	
	sub 	rsp, 32									;Shadow store
	mov 	rcx, [hHeap]							;hHeap
	mov 	edx, 8									;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 10									;number of byte allocated
	;FYI: 10 digits for 2^32	
	call	HeapAlloc								;out = HeapAlloc(hHeap,8,10)
	mov 	[rbp-40], rax			
	add 	rsp, 32									;Shadow store
						
	;s = HeapAlloc(hHeap,8,1101)	
	sub 	rsp, 32									;Shadow store
	mov 	rcx, [hHeap]							;hHeap
	mov 	edx, 8									;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 1101								;number of byte allocated
	;FYI: "You may wonder why 1101? basically 100x10 (100 numbers) and 99 spaces between them + \r\n
	call	HeapAlloc							;s = HeapAlloc(hHeap,8,1101)
	mov 	[rbp-56], rax	
	add 	rsp, 32								;Shadow store	
	
	;ReadConsoleA(hStdin, s, 1101, &slen,0);
	sub 	rsp, 32								;Shadow store
	mov		rcx, [hStdin]						;hStdin
	mov 	rdx, [rbp-56]						;s
	mov 	r8d, dword 1101						;buf size = 1101
	lea 	r9, [rbp-48]						;&slen byte read
	push 	0									;0
	call 	ReadConsoleA						;ReadConsoleA(hStdin, s, 1101, &slen,0);
	add		rsp, 40								;Shadow store + clean up paramenter	
	
	;slen -= 2
	mov 	rax, [rbp-48]						;cut away \r\n 
	sub 	rax, 2								
	mov 	[rbp-48], rax
	
	cmp 	rax, 0
	je  	EndInvalid
	
	;s = HeapReAlloc(hHeap, 0, s, slen)
	sub 	rsp, 32								;Shadow store
	mov 	rcx, [hHeap]						;hHeap
	xor 	rdx, rdx							;0 - no flag
	mov 	r8, [rbp-56]						;ptr s
	mov 	r9d, [rbp-48]						;slen
	call	HeapReAlloc							;s = HeapReAlloc(hHeap, 0, s, slen)
	mov 	[rbp-56], rax
	add 	rsp, 32
	
	;Process input array and put int array to buffer a, put output length to alen
	sub 	rsp, 32
	mov 	rcx, [rbp-56] 						;ptr s
	mov 	rdx, [rbp-48]						;slen
	mov 	r8, [rbp-32]						;ptr int a[100]
	lea 	r9, [rbp-8]						;ptr alen
	call 	ProcessIntArray
	add 	rsp, 32
	;int ProcessIntArray(void* inBuffer, int64 inBufferLength, void* outBuffer, void* numberOfElement)
	;RaX 						RCX               RDX  					R8 					R9
	
	cmp 	rax, 0								;return value of previous call is not 0 indicates error in parsing data.
 	jne 	EndInvalid							;so the input should be mallicious
	
	;Resize a to reduce excess memory
	sub 	rsp, 32
	mov 	rcx, [hHeap]						;heap handle
	xor 	rdx, rdx							;no flag
	mov 	r8, [rbp-32]						;ptr a
	mov 	r9, [rbp-8]							;alen
	shl 	r9, 3								;alen*8
	call 	HeapReAlloc
	mov 	[rbp-32], rax
	add 	rsp, 32
	
	;Loop to get max & min value
	;Initialization
	xor 	r15, r15 							;r15 : max value
	mov 	r14, 0xFFFFFFFFFFFFFFFF				;r14 : min value
	
	mov 	rcx, [rbp-8]						;alen. This is loop counter
	mov 	r12, [rbp-32]						;ptr a
L0:
	;Comparison

	
	;Loop
	mov 	qword rax, [r12]
	cmp 	rax, r15							;if rax > r15 then r15 = rax
	jbe 	L1									;else do nothing
	mov 	r15, rax							
L1:
	cmp 	rax, r14							;if rax < r14 then r14 = rax
	jae 	L2									;else do nothing
	mov 	r14, rax
L2:	
	;Increment
	add 	r12,8

	loopnz 	L0									;Loopnz instruction as requested :)
	
PrintOutput:

	;print funny string for dumbs
	sub 	rsp, 32								;shadow store
	mov		rcx, [hStdout]						;just print:
	mov 	rdx, max							;"Max : "	
	mov 	r8d, maxlen		
	mov		r9, [rbp-16]			
	push 	0
	call 	WriteConsoleA			
	add		rsp, 40					
	
	;convert int to its ascii representation
	mov 	rcx, r15							;input number
	mov 	rdx, [rbp-40]						;output buffer
	mov 	r8, 10								;buffer limit
	call 	Itoa 								;int numberOfCharWritten[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
	
	;and print it
	sub 	rsp, 32					
	mov		rcx, [hStdout]			
	mov 	rdx, [rbp-40]			
	mov 	r8d, eax							;return value from previous call	
	mov		r9, [rbp-16]			
	push 	0
	call 	WriteConsoleA			
	add		rsp, 40					
	
	
	;Print crlf
	sub 	rsp, 32					
	mov		rcx, [hStdout]			
	mov 	rdx, crlf			
	mov 	r8d, 2							
	mov		r9, [rbp-16]			
	push 	0
	call 	WriteConsoleA			
	add		rsp, 40		
	
	
	;print funny string for dumbs, again
	sub 	rsp, 32								;shadow store
	mov		rcx, [hStdout]						;just print:
	mov 	rdx, min							;"Min : "	
	mov 	r8d, minlen		
	mov		r9, [rbp-16]			
	push 	0
	call 	WriteConsoleA			
	add		rsp, 40					
	
	;convert int to its ascii representation
	mov 	rcx, r14							;input number
	mov 	rdx, [rbp-40]						;output buffer
	mov 	r8, 10								;buffer limit
	call 	Itoa 								;int numberOfCharWritten[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
	
	;and print it
	sub 	rsp, 32					
	mov		rcx, [hStdout]			
	mov 	rdx, [rbp-40]			
	mov 	r8d, eax							;return value from previous call	
	mov		r9, [rbp-16]			
	push 	0
	call 	WriteConsoleA			
	add		rsp, 40	
	
	jmp 	End
	
EndInvalid:
	;Print invalid message
	sub 	rsp, 32								;Shadow store
	mov		rcx, [hStdout]						;hStdout
	mov 	rdx, invalid						;"Invalid input"
	mov 	r8d, invalidlen						;14
	mov		r9, [rbp-16]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, "Invalid input", 14, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter

	jmp 	End

End:
	mov 	rsp,rbp

    xor     rcx, rcx
    call    ExitProcess

;========================================================================================================================================
Atoi: 											;fast_call int64 Atoi(char* a <rcx>, int length <rdx>). 
												;convert string to int <rax>
	push    rbp 			
    mov     rbp, rsp	
	
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
	leave
	ret
AtoiOutOfRange:
;Print out of range message
	sub 	rsp, 32								;Shadow store
	mov		rcx, [hStdout]						;hStdout
	mov 	rdx, outofrange						;"Number out of range"
	mov 	r8d, outofrangelen			
	lea		r9, [rsp-40]						;&writtenlen //JUST DISCARD IT
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout,"Number out of range" , outofrangelen, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter
	
	jmp 	AtoiInvalid
	
AtoiInvalid:
	mov 	rax, -1

	jmp 	AtoiEnd
;end of Atoi
;========================================================================================================================================
	
Itoa: ;int[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
;Convert number in RCX to ascii-decimal representation on buffer point to by RDX. 
;Return number of characters written

;Pre-check
	push rdi ;Non volatile register - callee save
	push r15
	push r14
	
	cmp rcx,0
	jg ItoaL0
	mov byte[rdx], 48
	mov r15d, 1
	jmp ItoaEnd
;Initialization
ItoaL0:
	
	xor  	r15, r15							;r15: char count = 0
	mov 	r14, rdx							;r14: buffer
	mov 	rax, rcx							;rax: dividend
ItoaL1:
	;Comparison
	cmp  	rax, 0								;check if fully converted
	je  	ItoaL2
	cmp 	r15, r8								;check if ran out of buffer
	jg  	ItoaL2
	;Loop
	xor 	rdx, rdx							;[rdx:rax] = rax (zero rdx)
	mov 	rdi, 10											
												;rax / 10
	div 	rdi 								;rax: Quotient, rdx: Remainder
	
	add 	rdx, 48								;convert to ascii char
	push	rdx									;push remainter on stack
	inc 	r15									;counter++
	jmp 	ItoaL1
ItoaL2:	;Processing characters to data buffer
	;for (rcx -> 0, rcx--)
	;Initialization

	mov 	rcx, r15							;rcx is loop counter

ItoaL3:
	pop 	rax
	mov		byte [r14], al
	inc 	r14
	loopnz 	ItoaL3
ItoaEnd:
	mov 	eax, r15d							;return char count
	
	pop 	r14									;Callee save register
	pop 	r15
	pop		rdi
	
	ret
;========================================================================================================================================

ProcessIntArray:
;int ProcessIntArray(void* inBuffer, int64 inBufferLength, void* outBuffer, int* numberOfElement)
;RaX 						RCX               RDX  					R8 					R9
;  RETURN int: 0 : no error; non zero: error
;       inBuffer : char buffer represent an int array separated by space ' '
; inBufferLength : length of inBuffer
;      outBuffer : buffer to get pure int array out
;numberOfElement : number of element

	
	push	rbp
	mov 	rbp, rsp
	
	sub 	rsp, 64
	
	push 	r15
	push 	r14
	push 	r13
	
	mov 	[rbp-8], rcx  ;inBuffer
	mov 	[rbp-16], rdx ;inBufferLength
	mov 	[rbp-24], r8  ;outBuffer
	mov 	[rbp-32], r9  ;numberOfElement

	
	;Simple idea: just iterate through input buffer and parse buffer between 2 space chars

;Initialization	
	xor 	r14, r14							;first iterator	
	xor 	r15, r15							;last iterator
	xor 	r13, r13							;elementCounter
;Comparison
ProcessIntArrayComparison:
	cmp 	r15, rdx							;if r15 < buffer then go to loop
	jb 		ProcessIntArrayL0
	cmp 	r14, r15							;if r15 < buffer and r14 < r15 then we have last number to parse
	je 		ProcessIntArrayReturnNoError
	
	;parse last number
	jmp 	ProcessIntArrayL1
	
;Loop
ProcessIntArrayL0:	
	mov 	al, byte[rcx+r15]
	cmp 	al, 32								;' '
	je 	ProcessIntArrayL1						;if this char is space char then go parse it
	inc 	r15									;else increase last iterator and comback checking
	jmp		ProcessIntArrayComparison
ProcessIntArrayL1:
	push 	rcx									;volatile register
	push 	rdx									;caller-saved
	
	;first iterator and last iterator specify a data zone. Which we pass it to Atoi
	sub 	rsp, 32								;shadow store
	lea 	rcx, [rcx+r14] 						;buffer in
	mov 	rdx, r15							
	sub 	rdx, r14							;buf len = r15 - r14
	call 	Atoi
	add 	rsp, 32
	
	pop 	rdx
	pop 	rcx
	
	cmp 	rax, -1								;Atoi return -1 means error. Stop execution
	jne 	continue
	jmp 	ProcessIntArrayReturnError
continue:
	;put data to buffer
	mov 	qword [r8+r13*8], rax
	
	;increase elementCounter
	inc 	r13
	mov 	r14, r15
	inc 	r14									;first&last iterater point to next character
	mov 	r15, r14
	jmp 	ProcessIntArrayComparison
ProcessIntArrayReturnNoError:
	mov 	r9, [rbp-32]
	mov 	[r9], r13							;move numberOfElement to buffer
	mov 	rax, 0								;prepair return value
	jmp 	ProcessIntArrayExit
ProcessIntArrayReturnError:
	mov 	r9, [rbp-32]
	mov 	qword [r9], 0
	mov 	rax, 1
	jmp 	ProcessIntArrayExit
ProcessIntArrayExit:
	pop 	r13
	pop 	r14
	pop 	r15
	
	leave
	ret
	