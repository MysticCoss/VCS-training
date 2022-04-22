bits 64
default rel

segment .data
	chromeexe 		dw __utf16__('chrome.exe'), 0
	edgeexe 		dw __utf16__('msedge.exe'), 0
	firefoxexe 		dw __utf16__('firefox.exe'), 0
	_Format			dw __utf16__('Round %d: %d application closed\n'), 0
segment .bss
	hHeap 				resq 1
	hStdin				resq 1
	hStdout				resq 1
	closed				resq 1
segment .text
	extern ExitProcess
	extern HeapAlloc
	extern HeapReAlloc
	extern HeapFree
	extern GetProcessHeap     
	extern Sleep          
	extern GetLastError
	extern GetStdHandle
	extern EnumWindows
	extern StrStrW
	extern GetWindowThreadProcessId
	extern OpenProcess
	extern GetModuleFileNameExW
	extern TerminateProcess
	
global Start	

EnumWindowsProc: ;HWND hwnd, LPARAM lParam
				;		rcx		 	  rdx

	push	rbp
	mov 	rbp, rsp
	
	;local variable:
	;offset -120: 
	;offset -112: 
	;offset -104: 
	;offset -32 : 
	;offset -24 : 
	;offset -16 : 
	;offset -8  : DWORD pid
	sub		rsp, 256
	
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	
	push	rcx
	
	;buff[r15] = HeapAlloc(hHeap,8,2000)	
	mov 	rcx, [hHeap]							;hHeap
	mov 	edx, 8									;HEAP_ZERO_MEMORY 0x00000008
	mov 	r8d, 2000								;number of byte allocated
	sub 	rsp, 32									;Shadow store
	call	HeapAlloc
	add		rsp, 32
	mov		r15, rax
	
	;GetWindowThreadProcessId(hWnd, &pid)
	pop		rcx
	lea		rdx, [rbp-8]
	sub 	rsp, 32									
	call	GetWindowThreadProcessId
	add		rsp, 32
	
	;HANDLE hProc[r14] = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE, FALSE, pid)
	mov     r8d, dword [rbp-8] 						;dwProcessId
	xor     edx, edx        						;bInheritHandle
	mov     ecx, 0x411       						;dwDesiredAccess: PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE
	sub		rsp, 32
	call    OpenProcess
	add		rsp, 32
	mov		r14, rax
	
	call	GetLastError
	
	;if (GetModuleFileNameEx(hProc,NULL, (LPWSTR)buff, 1000) > 0)
	push	r14
	mov     r9d, 1000       						; nSize
	mov     r8, r15 								; lpFilename
	xor     edx, edx        						; hModule
	mov     rcx, r14 								; hProcess
	sub		rsp, 32
	call    GetModuleFileNameExW
	add		rsp, 40
	
	test	eax, eax
	jbe		.return
	
	sub		rsp, 8
	mov     rdx, chromeexe    						; "chrome.exe"
	mov     rcx, r15 								; pszFirst
	sub		rsp, 32
	call    StrStrW
	add		rsp, 40
	test    rax, rax
	jz      .L1
	
	sub		rsp, 8
	mov     edx, 0FFFFFFFFh 						; uExitCode
	mov     rcx, r14		 						; hProcess
	sub		rsp, 32
	call    TerminateProcess
	add		rsp, 40
	
	add		qword [closed], 1
	
.L1:
	sub		rsp, 8
	mov     rdx, edgeexe    						; "msedge.exe"
	mov     rcx, r15 								; pszFirst
	sub		rsp, 32
	call    StrStrW
	add		rsp, 40
	test    rax, rax
	jz      .L2
	
	sub		rsp, 8
	mov     edx, 0FFFFFFFFh 						; uExitCode
	mov     rcx, r14		 						; hProcess
	sub		rsp, 32
	call    TerminateProcess
	add		rsp, 40
	
	add		qword [closed], 1
	
.L2:
	sub		rsp, 8
	mov     rdx, firefoxexe    						; "firefox.exe"
	mov     rcx, r15 								; pszFirst
	sub		rsp, 32
	call    StrStrW
	add		rsp, 40
	test    rax, rax
	jz      .L3
	
	sub		rsp, 8
	mov     edx, 0FFFFFFFFh 						; uExitCode
	mov     rcx, r14		 						; hProcess
	sub		rsp, 32
	call    TerminateProcess
	add		rsp, 40
	
	add		qword [closed], 1

.L3:
	jmp		.return

.return:
	pop		rbx
	pop		r12
	pop		r13
	pop		r14
	pop		r15
	mov		rax, 1
	leave
	ret
	

Start: 	;(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
		;				rcx					rdx					r8				r9
	push 	rbp
	mov 	rbp, rsp
	
	sub 	rsp, 256						;Allocate 256 bytes in stack
	
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -80  :
    ;offset -72  :
    ;offset -64  :
    ;offset -56  :
    ;offset -48  :
    ;offset -40  :
    ;offset -32  :
    ;offset -24	 :
    ;offset -16  :
    ;offset -8   :
	
	;hHeap = GetProcessHeap()	
	sub 	rsp, 32									;Shadow store
	call 	GetProcessHeap	
	add 	rsp, 32									;Shadow store
	mov 	[hHeap], rax							;hHeap = GetProcessHeap()
	
	;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	ecx, -10								;STD_INPUT_HANDLE 
	call 	GetStdHandle 							;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	mov 	[hStdin], rax							
		
	;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)		
	mov 	ecx, -11								;STD_OUTPUT_HANDLE
	call 	GetStdHandle							;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	mov 	[hStdout], rax		
	
	;count[rbx] = 0
	xor		rbx, rbx
	mov		qword [closed], 0
MainLoop:
	
	xor		rdx, rdx
	mov		rcx, EnumWindowsProc
	sub		rsp, 32
	call	EnumWindows
	add		rsp, 32
	
	;count ++
	inc		rbx
		
	;closed = 0
	mov		qword [closed], 0
	
	mov		rcx, 5000
	sub		rsp, 32
	call	Sleep
	add		rsp, 32
	
	jmp		MainLoop
