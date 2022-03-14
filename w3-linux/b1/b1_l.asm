;Compile & link command
;nasm -f elf64 -g ./b1_l.asm
;ld b1_l.o -o b1_l

bits 64
default rel
segment .data
	lf db 10
	invalid db "Invalid input", 0
	invalidlen equ $-invalid
	info db "Input array number : ", 0
	infolen equ $-info
	outofrange db "Number out of range", 10, 0
	outofrangelen equ $-outofrange
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
	sub		rsp, 48								;Allocate 48 bytes in stack
	;Kernel mode x64 calling convention : syscall number RAX, Param: left->right RDI, RSI, RDX, R10, R8 and R9
	;Local variable:
	;offset -40 : char* s[1100] //Include \n when read from console
	;offset -32  : int64 slen
	;offset -24  : char* out[10]
	;offset -16  : char* a[800] //Include \n when read from console
	;offset -8  : int64 alen
	
	;syscall write(stdout=1, "Input array number : ", 1)
	mov 	rax, 1									;write
	mov 	rdi, 1									;stdout
	mov 	rsi, info
	mov 	rdx, infolen
	syscall
	
	;===================================
	;syscall out = brk(null)
	mov 	rax, 12									;brk
	xor 	rdi, rdi								;null
	syscall
	mov 	[rbp-24], rax							;save current address
	
	;out+=10
	add 	rax, 10
	
	;syscall brk(out): allocate 10 byte for out (FYI: 10 digits for 2^32)
	mov 	rdi, rax								;new address
	mov 	rax, 12									;brk
	syscall	
	
	;check allocation failed
	cmp 	rax, qword [rbp-24]						;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;====================================
	;syscall s = brk(null)
	mov 	rax, 12									;brk
	xor 	rdi, rdi								;null
	syscall
	mov 	[rbp-40], rax							;save current address
	
	;s+=1100: 100x10 (100 numbers) and 99 spaces between them + \n
	add 	rax, 1100
	
	;syscall brk(s): allocate 1100 byte for out 
	mov 	rdi, rax								;new address
	mov 	rax, 12									;brk
	syscall	
	
	;check allocation failed
	cmp 	rax, qword [rbp-40]						;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;=====================================
	;slen = read(stdin = 0, s, 1100)
	mov 	rax, 0								;syscall read
	mov 	rdi, 0 								;stdin
	mov 	rsi, [rbp-40]						;void* s
	mov 	rdx, 1100							;num byte read
	syscall
	
	mov 	[rbp-32], rax						;slen
	
	;if input string has 1 char, probably user input nothing
	cmp 	rax, 1								
	je  	EndInvalid
	
	mov 	rbx, [rbp-40] 						;s
	add 	rax, rbx
	
	;resize s to fit
	mov 	rdi, rax 							;new address
	mov 	rax, 12								;syscall number: brk
	syscall
	
	;======================================
	;syscall a = brk(null)
	mov 	rax, 12									;brk
	xor 	rdi, rdi								;null
	syscall
	mov 	[rbp-16], rax							;save current address
	
	;a+=800
	add 	rax, 800
	
	;syscall brk(a): allocate 800 byte for a
	mov 	rdi, rax								;new address
	mov 	rax, 12									;brk
	syscall	
	
	;check allocation failed
	cmp 	rax, qword [rbp-16]					;if brk still return old address -> allocation failed
	je  	EndAllocationFailed
	
	;Process input array and put int array to buffer a, put output length to alen
	sub 	rsp, 32
	mov 	rcx, [rbp-40] 						;ptr s
	mov 	rdx, [rbp-32]						;slen
	mov 	r8, [rbp-16]						;ptr int a[100]
	lea 	r9, [rbp-8]						;ptr alen
	call 	ProcessIntArray
	add 	rsp, 32
	;int ProcessIntArray(void* inBuffer, int64 inBufferLength, void* outBuffer, void* numberOfElement)
	;RaX 						RCX               RDX  					R8 					R9
	
	cmp 	rax, 0								;return value of previous call is not 0 indicates error in parsing data.
 	jne 	EndInvalid							;so the input should be mallicious
	
	mov 	rax, [rbp-16]						;a
	mov 	rbx, [rbp-8]						;alen
	add 	rax, rbx							;new brk address
	
	mov 	rdi, rax							;new address
	mov 	rax, 12                             ;syscall number: brk
	syscall
	
	
	;Loop to get max & min value
	;Initialization
	xor 	r15, r15 							;r15 : max value
	mov 	r14, 0xFFFFFFFFFFFFFFFF				;r14 : min value
	
	mov 	rcx, [rbp-8]						;alen. This is loop counter
	mov 	r12, [rbp-16]						;ptr a
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
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout	
	mov 	rsi, max							;buffer
	mov 	rdx, maxlen							;num char write
	syscall	
	
	;convert int to its ascii representation
	mov 	rcx, r15							;input number
	mov 	rdx, [rbp-24]						;output buffer
	mov 	r8, 10								;buffer limit
	call 	Itoa 								;int numberOfCharWritten[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
	
	;print it
	mov 	rdx, rax							;num char write
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-24]
	syscall 

	;Print lf
	mov 	rax, 1 								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, lf
	mov 	rdx, 1
	syscall	
	
	
	;print funny string for dumbs, again
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout	
	mov 	rsi, min							;buffer
	mov 	rdx, minlen							;num char write
	syscall
	
	;convert int to its ascii representation
	mov 	rcx, r14							;input number
	mov 	rdx, [rbp-24]						;output buffer
	mov 	r8, 10								;buffer limit
	call 	Itoa 								;int numberOfCharWritten[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
	
	;and print it
	mov 	rdx, rax							;num char write
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, [rbp-24]
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
	;syscall write(stdout=1,'\n',1)
	mov 	rax, 1								;write
	mov 	rdi, 1								;stdout
	mov 	rsi, allocfail						
	mov 	rdx, allocfaillen					;num char write
	syscall	

	mov 	rsp,rbp
    xor     rdi, rdi							;exit(0)
	mov 	rax, 60 							;syscall exit
    syscall

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
	cmp 	al, 10								;'\n' indicates end of string
	je  	ProcessIntArrayL1
	cmp 	al, 32								;' '
	je 		ProcessIntArrayL1					;if this char is space char then go parse it
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
	