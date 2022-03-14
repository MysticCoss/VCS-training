;Compile & link command:
;nasm -f win64 -o helloworld.obj helloworld.asm | .\GoLink.exe /files /console helloworld.obj kernel32.dll

bits 64
default rel
segment .data
    msg db "Hello world!",0

segment .text
extern ExitProcess
extern GetStdHandle
extern WriteConsoleA
global Start

Start:
    push    rbp 			
    mov     rbp, rsp	
	sub 	rsp, 16								;allocate 8 bytes
	;Local variable
	;offset -8	HANDLE hstdout
	;offset -16 int64 writtenlen
	
	mov 	ecx, -11							;STD_OUTPUT_HANDLE
	call 	GetStdHandle
	mov 	[rbp-8], rax						;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	
	mov		rcx, [rbp-8]						;hStdout
	lea 	rdx, [msg]							;msg "Hello world!"
	mov 	r8d, 12								;12
	lea		r9, [rbp-16]						;&writtenlen
	push 	0
	call 	WriteConsoleA						;WriteConsoleA(hStdout, "Hello world!", 12, &writtenlen, 0);
	add		rsp, 8
	
	mov 	rsp,rbp
	;0123456789
    xor     rcx, rcx
    call    ExitProcess
	
