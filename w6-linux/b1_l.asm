bits 64
default rel

section .data
	killcmd 	db "/usr/bin/pkill", 0
	agrument1 	db "nc", 0

	argv 		dq  killcmd, agrument1, 0x0

	timeval:
		tv_sec  dq 0
		tv_usec dq 0



section .text
global _start

_start:

.L0:
	;Sleep for 10 seconds and 0 nanoseconds
	mov qword [tv_sec], 10
	mov qword [tv_usec], 0
	mov rax, 35						;sys_nanosleep
	mov rdi, timeval
	xor rsi, rsi        
	syscall

	mov rax, 57 			
	syscall							;sys_fork	
	
	cmp rax, 0 		
	jz KillProcess			

	;Parrent process
	;waitpid - 32bit  	
	mov ebx, eax 					;waitpid - 32bit  
	mov eax, 7 
	mov ecx, 0
	int 0x80 
	jmp .L0

	;child process
KillProcess:						;execv
    mov rax, 59
    mov rdi, killcmd
    mov rsi, argv
    mov rdx, 0
    syscall 


	mov rax, 60
	mov rdi, 0
	syscall							;sys_exit