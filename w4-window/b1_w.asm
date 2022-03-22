;Compile & link command
;nasm -f win64 -g -o b1_w.obj b1_w.asm 
;.\GoLink /files /console /debug coff b1_w.obj kernel32.dll shell32.dll

bits 64
default rel
segment .data
	crlf 			db 13,10
	invalid 		db "Invalid input", 0
	invalidlen 		equ $-invalid
	errormsg 		db "Some error occured: ", 0
	errormsglen 	equ $-errormsg
	info 			db "Input array number : ", 0
	infolen 		equ $-info
	outofrange 		db "Number out of range", 10, 0
	outofrangelen 	equ $-outofrange
	nan 			db "Not a number", 0
	nanlen 			equ $-nan
	max 			db "Max : ", 0
	maxlen 			equ $-max
	min 			db "Min : ", 0
	minlen 			equ $-min
	
	;+--------------------------------------------------------------------+
	;|                             DOS HEADER                             |
	;+--------------------------------------------------------------------+
	dos1			db "+--------------------------------------------------------------------------------------------------+", 0
	dos2			db "|                                            DOS HEADER                                            |", 0
	dos_len			equ $-dos2
	e_magic 		db "e_magic - Magic number :               	       ", 0
	e_magic_len 	equ $-e_magic	                                   
	e_cblp 			db "e_cblp - Bytes on last page of file :          ", 0
	e_cblp_len		equ $-e_cblp	                                   
	e_cp			db "e_cp - Pages in file :                 	       ", 0
	e_cp_len		equ $-e_cp                                 	       
	e_crlc 			db "e_crlc - Relocations :                 	       ", 0
	e_crlc_len 		equ $-e_crlc
	e_cparhdr 		db "e_cparhdr - Size of header in paragraphs :     ", 0
	e_cparhdr_len 	equ $-e_cparhdr
	e_minalloc 		db "e_minalloc - Minimum extra paragraphs needed : ", 0
	e_minalloc_len 	equ $-e_minalloc
	e_maxalloc 		db "e_maxalloc - Maximum extra paragraphs needed : ", 0
	e_maxalloc_len 	equ $-e_maxalloc
	e_ss 			db "e_ss - Initial (relative) SS value :           ", 0
	e_ss_len 		equ $-e_ss                                         
	e_sp 			db "e_sp - Initial SP value :                      ", 0
	e_sp_len		equ $-e_sp                                         
	e_csum 			db "e_csum - Checksum :                            ", 0
	e_csum_len 		equ $-e_csum                                       
	e_ip 			db "e_ip - Initial IP value :                      ", 0
	e_ip_sum 		equ $-e_ip                                         
	e_cs 			db "e_cs - Initial (relative) CS value :           ", 0
	e_cs_len 		equ $-e_cs
	e_lfarlc 		db "e_lfarlc - File address of relocation table :  ", 0
	e_lfarlc_len 	equ $-e_lfarlc
	e_ovno 			db "e_ovno - Overlay number :                      ", 0
	e_ovno_len 		equ $-e_ovno                                       
	e_res0 			db "e_res[0] - Reversed words :                    ", 0
	e_res1 			db "e_res[1] - Reversed words :                    ", 0
	e_res2 			db "e_res[2] - Reversed words :                    ", 0
	e_res3 			db "e_res[3] - Reversed words :                    ", 0
	e_res_len 		equ $-e_res3                                       
	e_oemid 		db "e_oemid - OEM identifier :                     ", 0
	e_oemid_len 	equ $-e_oemid                                      
	e_oeminfo 		db "e_oeminfo - OEM information :                  ", 0
	e_oeminfo_len 	equ $-e_oeminfo                                    
	e_res20 		db "e_res2[0] - Reversed words :                   ", 0
	e_res21 		db "e_res2[1] - Reversed words :                   ", 0
	e_res22 		db "e_res2[2] - Reversed words :                   ", 0
	e_res23 		db "e_res2[3] - Reversed words :                   ", 0
	e_res24 		db "e_res2[4] - Reversed words :                   ", 0
	e_res25 		db "e_res2[5] - Reversed words :                   ", 0
	e_res26 		db "e_res2[6] - Reversed words :                   ", 0
	e_res27 		db "e_res2[7] - Reversed words :                   ", 0
	e_res28 		db "e_res2[8] - Reversed words :                   ", 0
	e_res29 		db "e_res2[9] - Reversed words :                   ", 0
	e_res2_len 		equ $-e_res29
	e_lfanew 		db "e_lfanew - File address of new exe header :    ", 0
	e_lfanew_len 	equ $-e_lfanew
	
	;NT HEADER
	nt1				db "+--------------------------------------------------------------------------------------------------+", 0
	nt2				db "|                                            NT HEADER                                             |", 0
	nt_len			equ $-nt2
	signature		db "PE signature :                                 ", 0
	signature_len	equ $-signature
	machine			db "Machine :                                      ", 0
	machine_len		equ $-machine
	numberofsection db "Number of section :                            ", 0
	numberofsection_len equ $-numberofsection
	timedatestamp	db "Time date stamp :                              ", 0
	timedatestamp_len	equ $-timedatestamp
	pointersymbol	db "Pointer to symbol table :                      ", 0
	pointersymbol_len equ $-pointersymbol
	numsymbol		db "Number of symbol :                             ", 0
	numsymbol_len	equ $-numsymbol
	sizeopthdr		db "Size of optional header :                      ", 0
	sizeopthdr_len	equ $-sizeopthdr
	characteristics db "Characteristics :                              ", 0
	characteristics_len equ $-characteristics
segment .bss
	hStdin resq 1
	hStdout resq 1
	hHeap resq 1
segment .text
	extern ExitProcess
	extern GetStdHandle
	extern ReadConsoleA
	extern WriteConsoleA
	extern WriteConsoleW
	extern HeapAlloc
	extern HeapReAlloc
	extern GetProcessHeap
	extern GetCommandLineW
	extern CommandLineToArgvW
	extern CreateFileW
	extern GetLastError
	extern ReadFile
	extern CryptBinaryToStringA
global Start



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
	mov 	ecx, -10								;STD_INPUT_HANDLE 
	sub		rsp, 32
	call 	GetStdHandle 							;hStdin = GetStdHandle(STD_INPUT_HANDLE);
	add 	rsp, 32
	mov 	[hStdin], rax					
		
	;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)	

	mov 	ecx, -11								;STD_OUTPUT_HANDLE
	sub 	rsp, 32
	call 	GetStdHandle							;hStdout = GetStdHandle(STD_OUTPUT_HANDLE)
	add 	rsp, 32	
	mov 	[hStdout], rax		

	;hHeap = GetProcessHeap()	
	sub 	rsp, 32									;Shadow store
	call 	GetProcessHeap	
	add 	rsp, 32									;Shadow store
	mov 	[hHeap], rax							;hHeap = GetProcessHeap()

	
	;get a single string of cmd argument
	;LPWSTR cmd = GetCommandLineW();
	sub 	rsp, 32
	call 	GetCommandLineW
	add 	rsp, 32
	;return cmd on rax
	
	;parse argument to argv and argc
	;LPWSTR* cmdarr = CommandLineToArgvW(cmd, &numarg);
	mov 	rcx, rax								;cmd
	lea 	rdx, [rbp-24]							;&numarg
	call 	CommandLineToArgvW 		
	sub 	rsp, 32
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
	push 	0										;hTemplateFile: nullptr
	push	128										;dwFlagsAndAttributes: FILE_ATTRIBUTE_NORMAL
	push	3										;dwCreationDisposition: OPEN_EXISTING
	xor 	r9, r9									;lpSecurityAttributes: nullptr
	mov 	r8d, 2									;dwShareMode: FILE_SHARE_WRITE
	mov 	edx, 0x80000000							;dwDesiredAccess: GENERIC_READ
	mov 	rcx, [rax]								;lpFileName: cmdarr[1]
	sub 	rsp, 32
	call 	CreateFileW							
	add 	rsp, 56
	
	cmp 	rax, -1									;Check return value is INVALID_HANDLE_VALUE
	je  	EndError

	mov  	[rbp-40], rax							;HANDLE hFile

	
	;LPVOID buffer = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1024)
	mov     r8d, 1024       						;dwBytes: 1024
	mov     edx, 8          						;dwFlags: HEAP_ZERO_MEMORY
	mov     rcx, [hHeap] 							;hHeap
	sub 	rsp, 32
	call    HeapAlloc
	add 	rsp, 32
	
	mov 	[rbp-48], rax 							;LPVOID buffer
	
	;ReadFile(hFile, buffer, 1024, &byteread, nullptr)
	push 	0										;LPOVERLAPPED lpOverlapped: nullptr
	lea 	r9, [rbp-56] 							;LPDWORD lpNumberOfBytesRead: &byteread
	mov 	r8d, 1024								;nNumberOfBytesToRead
	mov 	rdx, rax								;LPVOID lpBuffer: buffer
	mov 	rcx, [rbp-40]							;HANDLE hFile: hFile
	sub 	rsp, 32
	call 	ReadFile
	add 	rsp, 40
	
	;if (ReadFile == 0) then exit error
	cmp 	rax, 0
	je  	EndError
	
	;rbx is used as iterator on buffer memory zone
	mov 	rbx, [rbp-48]							;LPVOID buffer
	
	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, dos_len
	mov 	rdx, dos1
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, "|                             DOS HEADER                             |", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, dos_len
	mov 	rdx, dos2
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, dos_len
	mov 	rdx, dos1
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_magic
	;WriteConsoleA(hStdout, "e_magic - Magic number : " (e_magic), e_magic_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, e_magic_len
	mov 	rdx, e_magic
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;call CryptBinaryToStringA with null pszString to calculate buffer length to allocate
	;CryptBinaryToStringA((BYTE*)buffer, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]                           
	push 	rax                                     ;DWORD* pcchString  : &writtenlen
	xor 	r9, r9                                  ;LPSTR   pszString  : nullptr
	mov 	r8d, 5                                  ;DWORD      dwFlags : CRYPT_STRING_HEXASCII
	mov 	rdx, 2                                  ;DWORD     cbBinary : 2 (2 bytes)
	mov 	rcx, rbx                                ;BYTE *pbBinary 	: buffer + 2
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;allocate buffer
	;LPVOID out = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, writtenlen)
	mov 	r8d, [rbp-16]							;SIZE_T dwBytes : writtenlen
	mov 	edx, 8									;DWORD  dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]							;HANDLE hHeap
	sub 	rsp, 32
	call 	HeapAlloc								
	add		rsp, 32			

	mov 	[rbp-64], rax
	
	;call CryptBinaryToStringA again with allocated buffer
	;CryptBinaryToStringA((BYTE*)buffer, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15
	mov	 	r9, rax									;LPVOID out
	mov 	r8d, 5
	mov 	rdx, 2
	mov 	rcx, rbx
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;nullptr
	lea 	r9, [rbp-16]							;LPDWORD writtenlen
	mov 	r8d, [rbp-16]							;DWORD writtenlen
	mov 	rdx, [rbp-64]							;LPVOID out
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_cblp
	
	;WriteConsoleA(hStdout, "e_cblp - Bytes on last page of file :  " (e_cblp), e_cblp_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved				: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_cblp_len                         ;DWORD   nNumberOfCharsToWrite  : e_cblp_len
	mov 	rdx, e_cblp                             ;VOID    *lpBuffer              : "e_cblp - Bytes on last page of file : "
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput         : hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   								;buffer += 2
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 2, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD      *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR      pszString   : null
	mov 	r8d, 5                                  ;DWORD      dwFlags		: CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD      cbBinary	: 2;
	mov 	rcx, rbx                                ;BYTE 		*pbBinary	: buffer + 2;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T     	dwBytes	: writtenlen
	mov 	r8, [rbp-64]							;LPVOID 		lpMem 	: out
	mov 	edx, 8                                  ;DWORD          dwFlags	: HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE         hHeap	: hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 2, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD      *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR      pszString   : out
	mov 	r8d, 5									;DWORD      dwFlags		: CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD      cbBinary	: 2
	mov 	rcx, rbx								;BYTE 		*pbBinary	: buffer + 2
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_cp
	
	;WriteConsoleA(hStdout, "e_cp - Pages in file : ", 24, &writtenlen, nullptr)
	push 	0                                       ;
	lea 	r9, [rbp-16]                            ;
	mov 	r8d, e_cp_len                           ;
	mov 	rdx, e_cp								;
	mov 	rcx, [hStdout]                          ;HANDLE hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 4, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD      *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR      pszString   : null
	mov 	r8d, 5                                  ;DWORD      dwFlags		: CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD      cbBinary	: 2;
	mov 	rcx, rbx                                ;BYTE 		*pbBinary	: buffer + 4;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T     	dwBytes	: writtenlen
	mov 	r8, [rbp-64]							;LPVOID 		lpMem 	: out
	mov 	edx, 8                                  ;DWORD          dwFlags	: HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE         hHeap	: hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 4, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD      *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR      pszString   : out
	mov 	r8d, 5									;DWORD      dwFlags		: CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD      cbBinary	: 2
	mov 	rcx, rbx								;BYTE 		*pbBinary	: buffer + 4
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_crlc
	
	;WriteConsoleA(hStdout, "e_crlc - Relocations : ", e_crlc_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_crlc_len                        	;DWORD   nNumberOfCharsToWrite 	: e_crlc_len
	mov 	rdx, e_crlc								;VOID    *lpBuffer 				: e_crlc
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 6, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD      *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR      pszString   : null
	mov 	r8d, 5                                  ;DWORD      dwFlags		: CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD      cbBinary	: 2;
	mov 	rcx, rbx                                ;BYTE 		*pbBinary	: buffer + 6;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T     	dwBytes	: writtenlen
	mov 	r8, [rbp-64]							;LPVOID 		lpMem 	: out
	mov 	edx, 8                                  ;DWORD          dwFlags	: HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE         hHeap	: hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 6, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD      *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR      pszString   : out
	mov 	r8d, 5									;DWORD      dwFlags		: CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD      cbBinary	: 2
	mov 	rcx, rbx								;BYTE 		*pbBinary	: buffer + 6
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_cparhdr
	
	;WriteConsoleA(hStdout, "e_cparhdr - Size of header in paragraphs : ", e_cparhdr_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_cparhdr_len                      ;DWORD   nNumberOfCharsToWrite 	: e_cparhdr_len
	mov 	rdx, e_cparhdr							;VOID    *lpBuffer 				: e_cparhdr
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 8, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 8;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 8, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 8
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_minalloc
	
	;WriteConsoleA(hStdout, "e_minalloc - Minimum extra paragraphs needed : ", e_minalloc_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_minalloc_len                     ;DWORD   nNumberOfCharsToWrite 	: e_minalloc_len
	mov 	rdx, e_minalloc							;VOID    *lpBuffer 				: e_minalloc
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 10, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 10;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 10, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 10
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_maxalloc
	
	;WriteConsoleA(hStdout, "e_maxalloc - Maximum extra paragraphs needed : ", e_maxalloc_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_maxalloc_len                     ;DWORD   nNumberOfCharsToWrite 	: e_maxalloc_len
	mov 	rdx, e_maxalloc							;VOID    *lpBuffer 				: e_maxalloc
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 12, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 12;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 12, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 12
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;////e_ss
	
	;WriteConsoleA(hStdout, "e_ss - Initial (relative) SS value : ", e_ss_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_ss_len                     		;DWORD   nNumberOfCharsToWrite 	: e_ss_len
	mov 	rdx, e_ss								;VOID    *lpBuffer 				: e_ss
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 14, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 14;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 14, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 14
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		
	
	;////e_sp
	
	;WriteConsoleA(hStdout, "e_sp - Initial SP value : ", e_sp_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_sp_len                     		;DWORD   nNumberOfCharsToWrite 	: e_sp_len
	mov 	rdx, e_sp								;VOID    *lpBuffer 				: e_sp
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 16, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 16;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 16, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 16
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;////e_csum
	
	;WriteConsoleA(hStdout, "e_csum - Checksum : ", e_csum_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_csum_len                     	;DWORD   nNumberOfCharsToWrite 	: e_csum_len
	mov 	rdx, e_csum								;VOID    *lpBuffer 				: e_csum
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 18, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 18;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 18, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 18
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;////e_ip
	
	;WriteConsoleA(hStdout, "e_ip - Initial IP value : ", e_ip_sum, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_ip_sum                     		;DWORD   nNumberOfCharsToWrite 	: e_ip_sum
	mov 	rdx, e_ip								;VOID    *lpBuffer 				: e_ip
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 20, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 20;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 20, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 20
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;////e_cs
	
	;WriteConsoleA(hStdout, "e_cs - Initial (relative) CS value : ", e_cs_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_cs_len                     		;DWORD   nNumberOfCharsToWrite 	: e_cs_len
	mov 	rdx, e_cs								;VOID    *lpBuffer 				: e_cs
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 22, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 22;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 22, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 22
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		

	;////e_lfarlc
	
	;WriteConsoleA(hStdout, "e_lfarlc - File address of relocation table : ", e_lfarlc_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_lfarlc_len                     	;DWORD   nNumberOfCharsToWrite 	: e_lfarlc_len
	mov 	rdx, e_lfarlc							;VOID    *lpBuffer 				: e_lfarlc
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 24, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 24;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 24, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 24
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		
	
	;////e_ovno
	
	;WriteConsoleA(hStdout, "e_ovno - Overlay number : ", e_ovno_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_ovno_len                     	;DWORD   nNumberOfCharsToWrite 	: e_ovno_len
	mov 	rdx, e_ovno							;VOID    *lpBuffer 				: e_ovno
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 26, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 26;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 26, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 26
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		
	
	;////e_res0
	
	;WriteConsoleA(hStdout, "e_res[0] - Reversed words : ", e_res_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res_len
	mov 	rdx, e_res0								;VOID    *lpBuffer 				: e_res0
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 28, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 28;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 28, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 28
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		

	;////e_res1
	
	;WriteConsoleA(hStdout, "e_res[1] - Reversed words : ", e_res_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res_len
	mov 	rdx, e_res1								;VOID    *lpBuffer 				: e_res1
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 30, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 30;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 30, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 30
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40		
	
	;////e_res2
	
	;WriteConsoleA(hStdout, "e_res[2] - Reversed words : ", e_res_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res_len
	mov 	rdx, e_res2								;VOID    *lpBuffer 				: e_res2
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 322222, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 32;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 32, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 32
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res3
	
	;WriteConsoleA(hStdout, "e_res[3] - Reversed words : ", e_res_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res_len
	mov 	rdx, e_res3								;VOID    *lpBuffer 				: e_res3
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 34, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 34;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 34, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 34
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_oemid
	
	;WriteConsoleA(hStdout, "e_oemid - OEM identifier : ", e_oemid_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_oemid_len                     		;DWORD   nNumberOfCharsToWrite 	: e_oemid_len
	mov 	rdx, e_oemid								;VOID    *lpBuffer 				: e_oemid
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 362222, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 36;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 36, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 36
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_oeminfo
	
	;WriteConsoleA(hStdout, "e_oeminfo - OEM information : ", e_oeminfo_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_oeminfo_len                     		;DWORD   nNumberOfCharsToWrite 	: e_oeminfo_len
	mov 	rdx, e_oeminfo								;VOID    *lpBuffer 				: e_oeminfo
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 38, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 38;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 38, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 38
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_res20
	
	;WriteConsoleA(hStdout, "e_res2[0] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res20								;VOID    *lpBuffer 				: e_res20
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 40, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 40;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 40, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 40
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res21
	
	;WriteConsoleA(hStdout, "e_res2[1] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res21								;VOID    *lpBuffer 				: e_res21
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 42, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 42;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 42, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 42
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res22
	
	;WriteConsoleA(hStdout, "e_res2[2] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     		;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res22								;VOID    *lpBuffer 				: e_res22
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 44, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 44;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 44, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 44
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_res23
	
	;WriteConsoleA(hStdout, "e_res2[3] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res23							;VOID    *lpBuffer 				: e_res23
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 46, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 46;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 46, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 46
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res24
	
	;WriteConsoleA(hStdout, "e_res2[4] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res24							;VOID    *lpBuffer 				: e_res24
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 48, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 48;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 48, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 48
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res25
	
	;WriteConsoleA(hStdout, "e_res2[5] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res25							;VOID    *lpBuffer 				: e_res25
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 50, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 50;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 50, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 50
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res26
	
	;WriteConsoleA(hStdout, "e_res2[6] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res26							;VOID    *lpBuffer 				: e_res26
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 52, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 52;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 52, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 52
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res27
	
	;WriteConsoleA(hStdout, "e_res2[7] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res27							;VOID    *lpBuffer 				: e_res27
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 54, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 54;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 54, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 54
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_res28
	
	;WriteConsoleA(hStdout, "e_res2[8] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res28							;VOID    *lpBuffer 				: e_res28
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 56, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 56;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 56, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 56
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;////e_res29
	
	;WriteConsoleA(hStdout, "e_res2[9] - Reversed words : ", e_res2_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_res2_len                     	;DWORD   nNumberOfCharsToWrite 	: e_res2_len
	mov 	rdx, e_res29							;VOID    *lpBuffer 				: e_res28
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 58, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 58;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 58, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 58
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;////e_lfanew
	
	;WriteConsoleA(hStdout, "e_lfanew - File address of new exe header : ", e_lfanew_len, &writtenlen, nullptr)
	push 	0                                       ;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]                            ;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, e_lfanew_len                     	;DWORD   nNumberOfCharsToWrite 	: e_lfanew_len
	mov 	rdx, e_lfanew							;VOID    *lpBuffer 				: e_lfanew
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40                                 
						
	;Increase iterator to 2
	add 	rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + 60, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax                                     ;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9                                  ;LPSTR   pszString   : null
	mov 	r8d, 5                                  ;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2                                  ;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx                                ;BYTE 	 *pbBinary	 : buffer + 60;
	sub 	rsp, 32  
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 60, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 60
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	movzx 	rbx, word [rbx]
	mov 	rax, [rbp-48]
	add 	rbx, rax								;load address of PE header

	
	
	
	
	
	
	
	
	
	
	
	;NT HEADER
	
	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, nt_len
	mov 	rdx, nt1
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, "|                             NT HEADER                             |", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, nt_len
	mov 	rdx, nt2
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, nt_len
	mov 	rdx, nt1
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;//Signature 
	;WriteConsoleA(hStdout, "PE signature :                                 ", signature_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, signature_len						;DWORD   nNumberOfCharsToWrite 	: signature_len
	mov 	rdx, signature							;VOID    *lpBuffer 				: signature
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 2
	;add		rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew, 4, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 4									;DWORD   cbBinary	 : 4;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + 60, 4, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 4									;DWORD   cbBinary	 : 4
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + 60
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	
	;// IMAGE FILE HEADER
	
	;//Machine
	;WriteConsoleA(hStdout, "Machine :                                      ", machine_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, machine_len						;DWORD   nNumberOfCharsToWrite 	: machine_len
	mov 	rdx, machine							;VOID    *lpBuffer 				: signature
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 4
	add		rbx, 4
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 4, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2									;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 4;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 4, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 4
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	

	
	;//NumberOfSections
	;WriteConsoleA(hStdout, "Number of section :                            ", numberofsection_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, numberofsection_len				;DWORD   nNumberOfCharsToWrite 	: numberofsection_len
	mov 	rdx, numberofsection					;VOID    *lpBuffer 				: numberofsection
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 2
	add		rbx, 2
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 6, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2									;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 6;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 6, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 6
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	

	;//TimeDateStamp 
	;WriteConsoleA(hStdout, "Time date stamp :                              ", timedatestamp_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, timedatestamp_len						;DWORD   nNumberOfCharsToWrite 	: timedatestamp_len
	mov 	rdx, timedatestamp							;VOID    *lpBuffer 				: timedatestamp
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 2
	add		rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 8, 4, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 4									;DWORD   cbBinary	 : 4;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 8;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 8, 4, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 4									;DWORD   cbBinary	 : 4
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 8
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	

	
;//PointerToSymbolTable 
	;WriteConsoleA(hStdout, "Pointer to symbol table :                      ", pointersymbol_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, pointersymbol_len						;DWORD   nNumberOfCharsToWrite 	: pointersymbol_len
	mov 	rdx, pointersymbol							;VOID    *lpBuffer 				: pointersymbol
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 4
	add		rbx, 4   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 12, 4, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 4									;DWORD   cbBinary	 : 4;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 12;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 12, 4, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 4									;DWORD   cbBinary	 : 4
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 12
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;//NumberOfSymbols 
	;WriteConsoleA(hStdout, "Number of symbol :                             ", numsymbol_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, numsymbol_len						;DWORD   nNumberOfCharsToWrite 	: numsymbol_len
	mov 	rdx, numsymbol							;VOID    *lpBuffer 				: numsymbol
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 4
	add		rbx, 4   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 16, 4, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 4									;DWORD   cbBinary	 : 4;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 16;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 16, 4, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 4									;DWORD   cbBinary	 : 4
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 16
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;//SizeOfOptionalHeader 
	;WriteConsoleA(hStdout, "Size of optional header :                      ", sizeopthdr_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, sizeopthdr_len						;DWORD   nNumberOfCharsToWrite 	: sizeopthdr_len
	mov 	rdx, sizeopthdr							;VOID    *lpBuffer 				: sizeopthdr
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 4
	add		rbx, 4   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 20, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2									;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 20;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 20, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 20
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	;//Characteristics 
	;WriteConsoleA(hStdout, "Characteristics :                              ", characteristics_len, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, characteristics_len						;DWORD   nNumberOfCharsToWrite 	: characteristics_len
	mov 	rdx, characteristics							;VOID    *lpBuffer 				: characteristics
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
						
	;Increase iterator to 2
	add		rbx, 2   
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 22, 2, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-16]							
	push 	rax										;DWORD   *pcchString : &writtenlen;
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII;
	mov 	rdx, 2									;DWORD   cbBinary	 : 2;
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 22;
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapReAlloc(hHeap, HEAP_ZERO_MEMORY, out, writtenlen)
	mov 	r9d, [rbp-16]							;SIZE_T  dwBytes : writtenlen
	mov 	r8, [rbp-64]							;LPVOID  lpMem 	 : out
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapReAlloc								
	add		rsp, 32						

	mov 	[rbp-64], rax
	
	;CryptBinaryToStringA((BYTE*)buffer + e_lfanew + 22, 2, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r15, [rbp-16]
	push 	r15										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, 2									;DWORD   cbBinary	 : 2
	mov 	rcx, rbx								;BYTE 	 *pbBinary	 : buffer + e_lfanew + 22
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-16]							;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-16]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-64]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40	
	
	jmp 	End
;====================================================================================================================	
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
	mov 	rsp, rbp

    xor     rcx, rcx
    call    ExitProcess