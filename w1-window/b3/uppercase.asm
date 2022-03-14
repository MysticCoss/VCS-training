;Compile & link command:
;nasm -f win64 -o uppercase.obj uppercase.asm | .\GoLink.exe /files /console uppercase.obj kernel32.dll

bits 64
default rel
segment .data

segment .text
extern ExitProcess
extern GetStdHandle
extern ReadConsoleA
extern WriteConsoleA
global Start



Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 400							;Allocate 400bytes in stack
	
	;Local variable:
	;offset -400 : char s[100]
	;offset -32  : int64 count
	;offset -24	 : int64 input_length
	;offset -16  : HANDLE hStdout
	;offset -8   : HANDLE hStdin
	
	mov 	ecx, -10							;STD_INPUT_HANDLE 
	call 	GetStdHandle 						
	mov 	[rbp-8], rax						;hStdin = GetStdHandle(STD_INPUT_HANDLE)
	
	mov 	ecx, -11							;STD_OUTPUT_HANDLE 
	call 	GetStdHandle
	mov 	[rbp-16], rax						;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)	

	mov		rcx, [rbp-8]						;hStdin
	lea 	rdx, [rbp-400]						;s
	mov 	r8d, 100							;100
	lea 	r9, [rbp-24]						;&input_length
	push 	0
	call 	ReadConsoleA						;ReadConsoleA(hStdin,s,100,&input_length)
	add		rsp, 8								;clean up stack
	
	jmp 	Initialization
	
;For loop contains 4 components: Initialization block, Comparison block, Instruction block and Increment block

Initialization:									;Initialization block
	xor 	rdi, rdi							;int i = 0
	jmp		Comparison
Comparison:	
	mov		rax, [rbp-8]						;input_length
	cmp		rdi, rax							
	jl		L									;if i < input_length then loop
	jmp 	Printf								;else quit loop
L:
	movzx 	rax, byte [rbp-400+rdi]				;s[i]
	cmp 	al, 122								;if s[i] > 122 then jmp Increment
	jg 		Increment

	movzx 	rax, byte [rbp-400+rdi]				;s[i]
	cmp 	al, 96								;if s[i] <= 96 then jump Increment
	jle 	Increment

	sub 	al, 32								;if 97 <= s[i] <= 122 will reach this instruction
												;from a->z in ASCII table
	mov 	[rbp-400+rdi], al					;s[i] -= 32	
	jmp 	Increment
Increment:	
	inc 	rdi
	jmp 	Comparison
Printf:
	mov		rcx, [rbp-16]						;hStdout
	lea 	rdx, [rbp-400]						;s
	mov		r8d, dword [rbp-24]					;input_length
	lea 	r9, [rbp-32]						;&count
	call 	WriteConsoleA						;WriteConsoleA(hStdout,s,input_length,&count)
	add		rsp, 8								;clean up stack

	mov 	rsp,rbp
    xor     rcx, rcx
    call    ExitProcess							;ExitProcess(0)

	