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
	e_cblp 			db "e_cblp - Bytes on last page of file :          ", 0	                                   
	e_cp			db "e_cp - Pages in file :                 	       ", 0                           	       
	e_crlc 			db "e_crlc - Relocations :                 	       ", 0
	e_cparhdr 		db "e_cparhdr - Size of header in paragraphs :     ", 0
	e_minalloc 		db "e_minalloc - Minimum extra paragraphs needed : ", 0
	e_maxalloc 		db "e_maxalloc - Maximum extra paragraphs needed : ", 0
	e_ss 			db "e_ss - Initial (relative) SS value :           ", 0                                       
	e_sp 			db "e_sp - Initial SP value :                      ", 0                                        
	e_csum 			db "e_csum - Checksum :                            ", 0                                     
	e_ip 			db "e_ip - Initial IP value :                      ", 0                                       
	e_cs 			db "e_cs - Initial (relative) CS value :           ", 0
	e_lfarlc 		db "e_lfarlc - File address of relocation table :  ", 0
	e_ovno 			db "e_ovno - Overlay number :                      ", 0                                      
	e_res0 			db "e_res[0] - Reversed words :                    ", 0
	e_res1 			db "e_res[1] - Reversed words :                    ", 0
	e_res2 			db "e_res[2] - Reversed words :                    ", 0
	e_res3 			db "e_res[3] - Reversed words :                    ", 0                                     
	e_oemid 		db "e_oemid - OEM identifier :                     ", 0                                  
	e_oeminfo 		db "e_oeminfo - OEM information :                  ", 0                                   
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
	machine			db "Machine :                                      ", 0
	numberofsection db "Number of section :                            ", 0
	timedatestamp	db "Time date stamp :                              ", 0
	pointersymbol	db "Pointer to symbol table :                      ", 0
	numsymbol		db "Number of symbol :                             ", 0
	sizeopthdr		db "Size of optional header :                      ", 0
	characteristics db "Characteristics :                              ", 0

	;IMAGE OPTIONAL HEADER
	ioh1			db "+--------------------------------------------------------------------------------------------------+", 0
	ioh2			db "|                                       IMAGE OPTIONAL HEADER                                      |", 0
	ioh_len			equ $-ioh2
	magic			db "Magic :                                        ", 0
	majorlinkver	db "Major link version :                           ", 0
	minorlinkver	db "Minor link version :                           ", 0
	sizeofcode		db "Size of code :                                 ", 0
	sizeofinitdata	db "Size Of Initialized Data :                     ", 0
	sizeofuninitdat db "Size Of Uninitialized Data :                   ", 0
	addrentrypoint	db "Address Of Entry Point :                       ", 0
	baseofcode		db "Base of code                                   ", 0
	baseofdata		db "Base of data                                   ", 0
	imagebase		db "Image base :                                   ", 0
	sectionalign	db "Section alignment :                            ", 0
	filealign		db "File alignment :                               ", 0
	majorosver		db "Major operating system version :               ", 0
	minorosver		db "Minor operation system version :               ", 0
	majorimgver		db "Major image version :                          ", 0
	minorimgver		db "Minor image version :                          ", 0
	majorsubsysver	db "Major subsystem version :                      ", 0
	minorsubsysver	db "Minor subsystem version :                      ", 0
	win32ver		db "Win32 version value :                          ", 0
	sizeofimage		db "Size of image :                                ", 0
	sizeofheader	db "Size of header :                               ", 0
	checksum		db "Checksum :                                     ", 0
	subsystem		db "Subsystem :                                    ", 0
	dllchar			db "Dll Characteristics :                          ", 0
	sizeStackResv	db "Size Of Stack Reserve :                        ", 0
	sizeofstackcom	db "Size Of Stack Commit :                         ", 0
	sizeofheapres	db "Size Of Heap Reserve :                         ", 0
	sizeofheapcom	db "Size of heap commit :                          ", 0
	loaderflag		db "Loader Flags :                                 ", 0
	numofrvaandsize	db "Number Of Rva And Sizes :                      ", 0
	exportrva		db "Export RVA :                                   ", 0
	exportsize		db "Export size :                                  ", 0
	importrva		db "Import RVA :                                   ", 0
	importsize		db "Import size :                                  ", 0

	;IMAGE SECTION HEADER
	ish1			db "+--------------------------------------------------------------------------------------------------+", 0
	ish2			db "|                                       IMAGE SECTION HEADER                                       |", 0
	ish_len			equ $-ish2
	sectionname		db "Section name :                                 ", 0
    physicaladdress	db "Physical address :                             ", 0 	
    virtualsize		db "Virtual size :                                 ", 0
    virtualaddress	db "Virtual address :                              ", 0
    sizeofrawdata	db "Size of raw data :                             ", 0
    pointerrawdata	db "Pointer to raw data :                          ", 0
    pointerreloc	db "Pointer to relocations :                       ", 0
    pointerlinenum	db "Pointer to line numbers :                      ", 0
    numofrelocation	db "Number of relocations :                        ", 0
    numoflinenumber	db "Number of line numbers :                       ", 0
    icharacteristic	db "Characteristics :                              ", 0
	
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
	extern HeapFree
	extern GetProcessHeap
	extern GetCommandLineW
	extern CommandLineToArgvW
	extern CreateFileW
	extern GetLastError
	extern ReadFile
	extern CryptBinaryToStringA
	extern lstrlenA
global Start



Start:
    push    rbp 			
    mov     rbp, rsp		
	sub		rsp, 128								;Allocate 128 bytes in stack
	;x64 calling convention : left->right RCX, RDX, R8, R9
	;Local variable:
	;offset -104 : WORD* numberofsection
	;offset -96  : DWORD* importrva
	;offset -88  : DWORD* exportrva
	;offset -80  : WORD sizeofoptionalheader
	;offset -72  : LPVOID optionalheaderbase
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
	
;e_magic
	mov		rcx, e_magic
	mov 	rdx, rbx
	mov 	r8d, 2
	call 	PrintHex
	
;e_cblp
	add		rbx, 2
	
	mov 	rcx, e_cblp
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_cp
	
	add 	rbx, 2  
	
	mov 	rcx, e_cp
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_crlc
	
	add 	rbx, 2 
	
	mov 	rcx, e_crlc
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_cparhdr
	
	add 	rbx, 2 
	
	mov 	rcx, e_cparhdr
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_minalloc
	
	add 	rbx, 2 
	
	mov 	rcx, e_minalloc
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_maxalloc
	
	add 	rbx, 2 
	
	mov 	rcx, e_maxalloc
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_ss
	add 	rbx, 2 
	
	mov 	rcx, e_ss
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_sp
	add 	rbx, 2 
	
	mov 	rcx, e_sp
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_csum
	add 	rbx, 2 
	
	mov 	rcx, e_csum
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_ip	
	add 	rbx, 2 
	
	mov 	rcx, e_ip
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_cs
	
	add 	rbx, 2 
	
	mov 	rcx, e_cs
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_lfarlc
	
	add 	rbx, 2 
	
	mov 	rcx, e_lfarlc
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_ovno
	
	add 	rbx, 2 
	
	mov 	rcx, e_ovno
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_res0
	
	add 	rbx, 2 
	
	mov 	rcx, e_res0
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex	

;e_res1
	
	add 	rbx, 2 
	
	mov 	rcx, e_res1
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_res2
	
	add 	rbx, 2 
	
	mov 	rcx, e_res2
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res3
	
	add 	rbx, 2 
	
	mov 	rcx, e_res3
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_oemid
	
	add 	rbx, 2 
	
	mov 	rcx, e_oemid
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_oeminfo
	
	add 	rbx, 2 
	
	mov 	rcx, e_oeminfo
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_res20
	
	add 	rbx, 2 
	
	mov 	rcx, e_res20
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res21
	
	add 	rbx, 2 
	
	mov 	rcx, e_res21
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res22
	
	add 	rbx, 2 
	
	mov 	rcx, e_res22
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_res23
	
	add 	rbx, 2 
	
	mov 	rcx, e_res23
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res24

	add 	rbx, 2 
	
	mov 	rcx, e_res24
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res25
	add 	rbx, 2 
	
	mov 	rcx, e_res25
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res26
	add 	rbx, 2 
	
	mov 	rcx, e_res26
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res27
	add 	rbx, 2 
	
	mov 	rcx, e_res27
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
;e_res28
	add 	rbx, 2 
	
	mov 	rcx, e_res28
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex

;e_res29
	add 	rbx, 2 
	
	mov 	rcx, e_res29
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
;e_lfanew
	add 	rbx, 2 
	
	mov 	rcx, e_lfanew
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
	
	
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
	
	
;Signature 
	mov 	rcx, signature							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	


	
; IMAGE FILE HEADER
	
;Machine
	add 	rbx, 4

	mov 	rcx, checksum							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex	
	
;NumberOfSections
	add 	rbx, 2
	
	;Store number of section for later processing
	mov 	qword [rbp-104], rbx 
	
	mov 	rcx, numberofsection					;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex	

;TimeDateStamp 
	add 	rbx, 2

	mov 	rcx, timedatestamp						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;PointerToSymbolTable
	add 	rbx, 4

	mov 	rcx, pointersymbol						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;NumberOfSymbols 
	add 	rbx, 4

	mov 	rcx, numsymbol							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;SizeOfOptionalHeader
	add 	rbx, 4
	
	;store size of optional header
	movzx	rax, word [rbx]
	mov		word [rbp-80], ax	
	
	mov 	rcx, sizeopthdr							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex
	
;Characteristics 
	add 	rbx, 2

	mov 	rcx, characteristics					;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex



;IMAGE OPTIONAL HEADER

	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, ioh_len
	mov 	rdx, ioh1
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
	
	;WriteConsoleA(hStdout, "|                                       IMAGE OPTIONAL HEADER                                      |", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, ioh_len
	mov 	rdx, ioh2
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
	mov 	r8d, ioh_len
	mov 	rdx, ioh1
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
	
;Magic 
	add 	rbx, 2

	;Store Image optional header's base
	mov 	[rbp-72], rbx
	
	mov 	rcx, magic								;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex


	movsx 	rax, word [rbx]
	cmp 	rax, 0x10B
	je		PrintPE32
	cmp 	rax, 0x20B
	je		PrintPE64

PrintPE32:
;MajorLinkerVersion 
	add 	rbx, 2

	mov 	rcx, majorlinkver						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 1									;buffer length
	call	PrintHex

;MinorLinkerVersion 
	add 	rbx, 1

	mov 	rcx, minorlinkver						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 1									;buffer length
	call	PrintHex

;SizeOfCode 
	add 	rbx, 1

	mov 	rcx, sizeofcode							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex


;SizeOfInitializedData
	add 	rbx, 4

	mov 	rcx, sizeofinitdata						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;SizeOfUninitializedData 
	add 	rbx, 4

	mov 	rcx, sizeofuninitdat						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;AddressOfEntryPoint
	add 	rbx, 4

	mov 	rcx, addrentrypoint						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;BaseOfCode
	add 	rbx, 4

	mov 	rcx, baseofcode							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;BaseOfData
	add 	rbx, 4

	mov 	rcx, baseofdata							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;ImageBase
	add 	rbx, 4

	mov 	rcx, imagebase							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	

;SectionAlignment
	add 	rbx, 4

	mov 	rcx, sectionalign						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;FileAlignment
	add 	rbx, 4

	mov 	rcx, filealign						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;majorosver
	add 	rbx, 4

	mov 	rcx, majorosver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex

;minorosver
	add 	rbx, 2

	mov 	rcx, minorosver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex


;majorimgver
	add 	rbx, 2

	mov 	rcx, majorimgver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex


;minorimgver
	add 	rbx, 2

	mov 	rcx, minorimgver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex


;majorsubsysver
	add 	rbx, 2

	mov 	rcx, majorsubsysver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex


;minorsubsysver
	add 	rbx, 2

	mov 	rcx, minorsubsysver						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex

;win32 ver

	add 	rbx, 2

	mov 	rcx, win32ver							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;size of image

	add 	rbx, 4

	mov 	rcx, sizeofimage						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;size of header

	add 	rbx, 4

	mov 	rcx, sizeofheader						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex

;check sum

	add 	rbx, 4

	mov 	rcx, checksum							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	
	
;subsystem
	add 	rbx, 4

	mov 	rcx, subsystem							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex

;Dllchar
	add 	rbx, 2

	mov 	rcx, dllchar							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 2									;buffer length
	call	PrintHex	
	
;SizeOfStackReserve
	add 	rbx, 2

	mov 	rcx, sizeStackResv						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex		
	
;SizeOfStackCommit
	add 	rbx, 4

	mov 	rcx, sizeofstackcom						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex		

;SizeOfHeapReversed
	add 	rbx, 4

	mov 	rcx, sizeofheapres						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;SizeOfHeapCommit
	add 	rbx, 4

	mov 	rcx, sizeofheapcom						;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;LoaderFlags
	add 	rbx, 4

	mov 	rcx, loaderflag							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	

;NumberOfRvaAndSizes
	add 	rbx, 4

	mov 	rcx, numofrvaandsize					;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex		

;ExportDirectory RVA Address
	add		rbx, 4
	
	mov 	qword [rbp-88], rbx
	
	mov 	rcx, exportrva							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;ExportDirectory Size
	add		rbx, 4
	
	mov 	rcx, exportsize							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;ImportDirectory RVA Address
	add		rbx, 4
	
	mov 	qword [rbp-96], rbx
	
	mov 	rcx, importrva							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex
	
;ImportDirectory Size
	add		rbx, 4
	
	mov 	rcx, importsize							;Debug string
	mov 	rdx, rbx								;buffer
	mov		r8d, 4									;buffer length
	call	PrintHex	


	
;IMAGE SECTION HEADER
	
	;calculate section table offset
	mov 	rcx, [rbp-72]
	movzx	rdx, word [rbp-80]
	add		rcx, rdx	
	mov		rbx, rcx

	;WriteConsoleA(hStdout, "+--------------------------------------------------------------------+", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, ish_len
	mov 	rdx, ish1
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
	
	;WriteConsoleA(hStdout, "|                                       IMAGE SECTION HEADER                                       |", dos_len, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, ish_len
	mov 	rdx, ish2
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
	mov 	r8d, ish_len
	mov 	rdx, ish1
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

	;Load number of section to counter
	mov 	r8, [rbp-104]
	movzx 	rdi, word [r8]
	
	
imgsec:

;Name

	mov 	rcx, sectionname
	mov 	rdx, rbx
	mov 	r8d, 8
	call	PrintHex

;VirtualSize
	add 	rbx, 8

	mov 	rcx, virtualsize
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;VirtualAddress
	add 	rbx, 4

	mov 	rcx, virtualaddress
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;SizeOfRawData
	add 	rbx, 4

	mov 	rcx, sizeofrawdata
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;PointerToRawData
	add 	rbx, 4

	mov 	rcx, pointerrawdata
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;PointerToRelocations
	add 	rbx, 4

	mov 	rcx, pointerreloc
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;PointerToLinenumbers
	add 	rbx, 4

	mov 	rcx, pointerlinenum
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
;NumberOfRelocations
	add 	rbx, 4

	mov 	rcx, numofrelocation
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
;NumberOfLinenumbers
	add 	rbx, 2

	mov 	rcx, numoflinenumber
	mov 	rdx, rbx
	mov 	r8d, 2
	call	PrintHex
;Characteristics
	add 	rbx, 2

	mov 	rcx, icharacteristic
	mov 	rdx, rbx
	mov 	r8d, 4
	call	PrintHex
	add		rbx, 4
	
	;WriteConsoleA(hStdout, crlf, 2, &writtenlen, nullptr)
	push 	0
	lea 	r9, [rbp-16]
	mov 	r8d, 2
	mov 	rdx, crlf
	mov 	rcx, [hStdout]
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40


	sub		rdi, 1
	cmp		rdi, 0
	jne		imgsec
	
	
	
;Import Directory
	mov 	rax, [rbp-96]
	mov 	eax, dword [rax]
	
	test 	rax, rax
	jz		L1
	
	
	
L1:
;Export Directory
	mov 	rax, [rbp-88]
	mov 	eax, dword [rax]
	
	test 	rax, rax
	jz		L2


L2:
	jmp		End
PrintPE64:

	jmp		End

;====================================================================================================================	
Itoa: ;int[rax] Itoa(int64[rcx], void* buf[rdx], int bufferlen[r8d])
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

PrintHex: ;rcx: Debug string, rdx: data to print, r8d: data size in byte

	push	rbp
	mov 	rbp, rsp

	sub 	rsp, 16
	
	push 	r13
	push 	r14
	push	r15
	
	mov 	r14, rdx
	mov 	r15, r8
	mov 	r13, rcx
	

	call	lstrlenA
	mov 	r8d, eax

	;WriteConsoleA(hStdout, minorsubsysver, lstrlenA(minorsubsysver), &writtenlen, nullptr)

	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-8]								;LPDWORD lpNumberOfCharsWritten : &writtenlen
													;DWORD   nNumberOfCharsToWrite 	: lstrlenA(minorsubsysver)
	mov 	rdx, r13								;VOID    *lpBuffer 				: baseofdata
	mov 	rcx, [hStdout]							;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40
	
	;call CryptBinaryToStringA with pszString paramenter null to calculate output buffer size (in TCHAR)
	;CryptBinaryToStringA((BYTE*)buffer, bufferlength, CRYPT_STRING_HEXASCII, nullptr, &writtenlen)                               
	lea 	rax, [rbp-8]							
	push 	rax										;DWORD   *pcchString : &writtenlen
	xor 	r9, r9									;LPSTR   pszString   : null
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	edx, r15d								;DWORD   cbBinary	 : bufferlength
	mov 	rcx, r14								;BYTE 	 *pbBinary	 : buffer
	sub 	rsp, 32
	call 	CryptBinaryToStringA
	add 	rsp, 40
	
	;LPVOID out = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, writtenlen)
	mov 	r8d, [rbp-8]							;SIZE_T  dwBytes : writtenlen
	mov 	edx, 8                                  ;DWORD   dwFlags : HEAP_ZERO_MEMORY
	mov 	rcx, [hHeap]                            ;HANDLE  hHeap	 : hHeap
	sub 	rsp, 32
	call 	HeapAlloc								
	add		rsp, 32						

	mov 	[rbp-16], rax
	
	;CryptBinaryToStringA((BYTE*)buffer, bufferlength, CRYPT_STRING_HEXASCII, (LPSTR)out, &writtenlen)
	lea 	r10, [rbp-8]
	push 	r10										;DWORD   *pcchString : &writtenlen
	mov	 	r9, rax									;LPSTR   pszString   : out
	mov 	r8d, 5									;DWORD   dwFlags	 : CRYPT_STRING_HEXASCII
	mov 	rdx, r15									;DWORD   cbBinary	 : bufferlength
	mov 	rcx, r14								;BYTE 	 *pbBinary	 : buffer
	sub 	rsp, 32									
	call 	CryptBinaryToStringA
	add 	rsp, 40

	;WriteConsoleA(hStdout, out, writtenlen, &writtenlen, nullptr)
	push 	0										;LPVOID  lpReserved 			: nullptr
	lea 	r9, [rbp-8]								;LPDWORD lpNumberOfCharsWritten : &writtenlen
	mov 	r8d, [rbp-8]							;DWORD   nNumberOfCharsToWrite 	: writtenlen
	mov 	rdx, [rbp-16]							;VOID    *lpBuffer 				: out
	mov 	rcx, [hStdout]                          ;HANDLE  hConsoleOutput			: hStdout
	sub 	rsp, 32
	call 	WriteConsoleA
	add 	rsp, 40

	;HeapFree(hHeap, 0, out)
	mov 	r8, [rbp-16]
	xor 	rdx, rdx
	mov 	rcx, [hHeap]
	sub 	rsp, 32
	call	HeapFree
	add 	rsp, 32
	
	pop 	r15
	pop		r14
	pop		r13
	
	leave
	ret