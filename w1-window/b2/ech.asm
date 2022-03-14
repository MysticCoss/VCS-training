bits 64
default rel
segment .data
;Compile & link command:
;nasm -f win64 -o ech.obj ech.asm | .\GoLink.exe /files /console ech.obj kernel32.dll

segment .text
extern ExitProcess
extern GetStdHandle
extern ReadConsoleA
extern WriteConsoleA
global Start




Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 132							;Allocate 132 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -132 : int64 count
	;offset -124 : char s[100]
	;offset -24  : int i
	;offset -16	 : HANDLE hStdout
	;offset -8   : HANDLE hStdin
	
	mov 	ecx, -10							;STD_INPUT_HANDLE 
	call 	GetStdHandle 						
	mov 	[rbp-8], rax						;hStdin = GetStdHandle(STD_INPUT_HANDLE)
	
	mov 	ecx, -11							;STD_OUTPUT_HANDLE 
	call 	GetStdHandle
	mov 	[rbp-16], rax						;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	
	mov		rcx, [rbp-8]						;hStdin
	lea 	rdx, [rbp-124]						;s
	mov 	r8d, 100							;100
	lea 	r9, [rbp-24]						;&i
	push 	0
	call 	ReadConsoleA						;ReadConsoleA(hStdin,s,100,&i)
	add		rsp, 8								;clean up stack
	
	mov		rcx, [rbp-16]						;hStdout
	lea 	rdx, [rbp-124]						;s
	mov 	r8d, dword [rbp-24]					;i
	lea		r9, [rbp-132]						;&count
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout,s,i,&count)
	add		rsp, 8								;clean up stack
	
	mov 	rsp,rbp
	;0123456789
    xor     rcx, rcx
    call    ExitProcess							;ExitProcess(0)
	
