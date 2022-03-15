;Compile & link command
;nasm -f win64 -g -o b1_w.obj b1_w.asm 
;.\GoLink /files /console /debug coff b1_w.obj kernel32.dll shell32.dll

bits 64
default rel
segment .data
	crlf db 13,10
	invalid db "Invalid input", 0
	invalidlen equ $-invalid
	errormsg db "Some error occured ", 0
	errormsglen equ $-errormsg
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
	e_magic db "e_magic - Magic number : ", 0  ;;????
	e_cblp db "e_cblp - Bytes on last  page of file : ",0
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
	extern GetCommandLineW
	extern CommandLineToArgvW
	extern CreateFileW
	extern GetLastError
global Start

Itoa: ;int[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
;Convert number in RCX to ascii-decimal representation on buffer point to by RDX. 
;Return number of characters written

;Pre-check
	push rdi ;Non volatile register - callee save
	push r15
	push r14
	push r13
	
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
	;for (r13 = 0 , (loop counter)r13 < r15(char counter), r13++)
	;Initialization
	xor 	r13, r13 							;loop counter = 0
ItoaL3:	
	;Comparison
	cmp 	r13, r15							;if r13 < r15 -> enter loop
	jl  	ItoaL4								;else quit
	jmp 	ItoaEnd
ItoaL4:
	pop 	rax
	mov		byte [r14], al
	inc 	r13
	inc 	r14
	jmp 	ItoaL3
ItoaEnd:
	mov 	eax, r15d							;return char count
	
	pop 	r13									;Callee save register
	pop 	r14
	pop 	r15
	pop		rdi
	
	ret
;========================================================================================================================================

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

EndError:
	;r15 = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1024)
	sub 	rsp, 32
	mov     r8d, 400h       					;dwBytes: 1024
	mov     edx, 8          					;dwFlags: HEAP_ZERO_MEMORY
	mov		rcx, [hHeap] 						;hHeap
	call    HeapAlloc
	add 	rsp, 32
	mov 	r15, rax

	;Print error message
	sub 	rsp, 32								;Shadow store
	mov		rcx, [hStdout]						;hStdout
	mov		rdx, errormsg						;"Some error occured "
	mov 	r8d, errormsglen					;19
	mov		r9, [rbp-16]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, "Some error occured ", 19, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter

	;GetLastError()
	call 	GetLastError

	;Convert error code to string
	sub 	rsp, 32
	mov		rcx, rax
	mov 	rdx, r15
	mov 	r8, 1024
	call 	Itoa								;int writtenlen[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8])
	add 	rsp, 32

	;Print error code string
	sub 	rsp, 32								;Shadow store
	mov		rcx, [hStdout]						;hStdout
	mov 	rdx, r15							;Buffer store error code
	mov 	r8, rax								;Buffer length
	mov		r9, [rbp-16]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, errorcode, errorcodelen, &writtenlen, 0);
	add		rsp, 40								;Shadow store + clean up paramenter

	jmp 	End

End:
	mov 	rsp,rbp

    xor     rcx, rcx
    call    ExitProcess

Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 64								;Allocate 64 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -64  : LPVOID out
	;offset -56  : DWORD byteread 
	;offset -48  : LPVOID buffer
	;offset -40  : HANDLE hFile
	;offset -32  : LPWSTR* cmdarr
	;offset -24	 : int64 numarg
	;offset -16  : int64 writtenlen
	;offset -8   : int64 filepath
	
	;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	sub		rsp, 32
	mov 	ecx, -10								;STD_INPUT_HANDLE 
	call 	GetStdHandle 							;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	[hStdin], rax					
	add 	rsp, 32
		
	;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)	
	sub 	rsp, 32
	mov 	ecx, -11								;STD_OUTPUT_HANDLE
	call 	GetStdHandle							;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	mov 	[hStdout], rax		
	add 	rsp, 32
		
	;hHeap = GetProcessHeap()	
	sub 	rsp, 32									;Shadow store
	call 	GetProcessHeap	
	mov 	[hHeap], rax							;hHeap = GetProcessHeap()
	add 	rsp, 32									;Shadow store
	
	;get a single string of cmd argument
	;LPWSTR cmd = GetCommandLineW();
	sub 	rsp, 32
	call 	GetCommandLineW
	add 	rsp, 32
	;return cmd on rax
	
	;parse argument to argv and argc
	;LPWSTR* cmdarr = CommandLineToArgvW(cmd, &numarg);
	sub 	rsp, 32
	mov 	rcx, rax								;cmd
	lea 	rdx, [rbp-24]							;&numarg
	call 	CommandLineToArgvW 		
	mov 	qword [rbp-32], rax						;address gv
	add 	rsp, 32
	
	;if there are more than 1 argument, the second one is our path
	;if (numarg != 2) return 0;
	mov 	rbx, [rbp-24]							;numarg
	cmp 	rbx, 2
	jne 	EndInvalid
	
	;load second argument
	;filepath = cmdarr[1]
	add 	rax, 8									;cmdarr[1]
		
	;Create a file stream
	;HANDLE hFile = CreateFileW(filepath, GENERIC_READ, FILE_SHARE_WRITE, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
	sub 	rsp, 32
	push 	0										;hTemplateFile: nullptr
	push	128										;dwFlagsAndAttributes: FILE_ATTRIBUTE_NORMAL
	push	3										;dwCreationDisposition: OPEN_EXISTING
	xor 	r9, r9									;lpSecurityAttributes: null
	mov 	r8d, 2									;dwShareMode: FILE_SHARE_WRITE
	mov 	edx, 0x80000000							;dwDesiredAccess: GENERIC_READ
	mov 	rcx, [rax]								;lpFileName: cmdarr[1]
	call 	CreateFileW							
	add 	rsp, 56
	
	cmp 	rax, -1									;Check return value is INVALID_HANDLE_VALUE
	je  	EndError

	mov  	[rbp-40], rax							;HANDLE hFile
	
	;LPVOID buffer = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1024)
	sub 	rsp, 32
	mov     r8d, 1024       						;dwBytes: 1024
	mov     edx, 8          						;dwFlags: HEAP_ZERO_MEMORY
	mov     rcx, [hHeap] 							;hHeap
	call    HeapAlloc
	add 	rsp, 32
	
	mov 	[rbp-48], rax 							;LPVOID buffer
	
	;ReadFile(hFile, buffer, 1024, &byteread, nullptr)
	sub 	rsp, 32
	push 	0										;LPOVERLAPPED lpOverlapped: nullptr
	lea 	r9, [rbp-56] 							;LPDWORD lpNumberOfBytesRead: &byteread
	mov 	r8d, 1024								;nNumberOfBytesToRead
	mov 	rdx, rax								;LPVOID lpBuffer: buffer
	mov 	rcx, [rbp-40]							;HANDLE hFile: hFile
	add 	rsp, 40
	
	;if (ReadFile == 0) then exit error
	cmp 	rax, 0
	je  	EndError
	
	;rbx is used as iterator on buffer memory zone
	mov 	rbx, [rbp-48]							;LPVOID buffer
	
	;////e_magic
	;WriteConsoleA(hStdout, "e_magic - Magic number : ", 26, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 26
	mov 	rdx, e_magic
	mov 	rcx, [hStdout]
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, buffer, 2, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, rbx
	mov 	rcx, [hStdout]
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0
	lea		r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	add 	rsp, 40
	
	;////e_cblp
	
	;WriteConsoleA(hStdout, "e_cblp - Bytes on last page of file : ", 39, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0                                       ;
	lea 	r9, [rbp-16]                            ;
	mov 	r8d, 39                                 ;
	mov 	rdx, e_cblp                             ;
	mov 	rcx, [hStdout]                          ;
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2                                  
	;CryptBinaryToStringA((BYTE*)buffer + 2, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)
	sub 	rsp, 32                                 
	lea 	rax, [rbp-16]                           ;
	push 	rax                                     ;
	xor 	r9, r9                                  ;
	mov 	r8d, 5                                  ;
	mov 	rdx, 2                                  ;
	mov 	rcx, rbx                                ;
	add 	rsp, 40
	
	;LPVOID out = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, writtenlen)
	sub 	rsp, 32
	mov 	r8d, [rbp-16]							;writtenlen
	mov 	edx, 8									;HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]							;hHeap
	call 	HeapAlloc								
	add		rsp, 32			

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 2, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	sub 	rsp, 32
	lea 	r15, [rbp-16]
	push 	r15
	mov	 	r9, rax									;LPVOID out
	mov 	r8d, 5
	mov 	rdx, 2
	mov 	rcx, rbx
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, out, 5, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0										;nullptr
	lea 	r9, [rbp-16]							;LPDWORD writtenlen
	mov 	r8d, 5									;5
	mov 	rdx, [rbp-64]							;LPVOID out
	mov 	rcx, [hStdout]
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	sub 	rsp, 32
	push 	0
	lea		r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	add 	rsp, 40
	