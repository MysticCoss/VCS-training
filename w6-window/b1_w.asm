bits 64
default rel

segment .data
	g_szClassName 		dw __utf16__('myWindowClass'), 0
	windowtitle			dw __utf16__('Bao xinh bôn'), 0
	message				dw __utf16__('Window Registration Failed!'), 0
	message1			dw __utf16__('Window Creation Failed!'), 0
	errormsg			dw __utf16__('Error!'), 0
	iconname			dw __utf16__('bb.ico'), 0
segment .bss
	hHeap 				resq 1
	hStdin				resq 1
	hStdout				resq 1
segment .text
	extern ExitProcess
	extern HeapAlloc
	extern HeapReAlloc
	extern HeapFree
	extern GetProcessHeap     
	extern Sleep          
	extern GetLastError
	extern wprintf 

global Start	

WndProc: ;HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam
		 ;		rcx		  edx			r8				r9

	push	rbp
	mov 	rbp, rsp
	
	;local variable:
	;offset -120: 
	;offset -112: 
	;offset -104: 
	;offset -32 : 
	;offset -24 : 
	;offset -16 : 
	;offset -8  : 
	sub		rsp, 256
	
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	
	
	
.return:
	pop		rbx
	pop		r12
	pop		r13
	pop		r14
	pop		r15
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
	
	;Initalize global variable
	mov		dword [leftrightdirection], 1
	mov		dword [topbottomdirection], 1
	mov 	dword [speed], 3
	mov		dword [radius], 20
	
	mov		dword [r+RECT.left], 0
	mov		dword [r+RECT.top], 0
	mov		eax, [radius]							;radius*2
	shl		eax, 1
	mov		[r+RECT.right], eax
	mov		[r+RECT.bottom], eax
	
	;hInstance = GetModuleHandleW(NULL)
	xor		rcx, rcx
	sub		rsp, 32
	call	GetModuleHandleW
	add		rsp, 32
	mov		[rbp-56], rax
	
	;hHeap = GetProcessHeap()	
	sub 	rsp, 32									;Shadow store
	call 	GetProcessHeap	
	add 	rsp, 32									;Shadow store
	mov 	[hHeap], rax							;hHeap = GetProcessHeap()
	
	mov 	dword [ws+WNDCLASSEXW.cbSize], 80
	mov 	dword [ws+WNDCLASSEXW.style], 0
	mov		qword [ws+WNDCLASSEXW.lpfnWndProc], WndProc
	mov		dword [ws+WNDCLASSEXW.cbClsExtra], 0  
	mov		rax, [rbp-56]							;HINSTANCE hInstance
	mov		[ws+WNDCLASSEXW.hInstance], rax
	
	;hIcon = (HICON)LoadImageW(NULL, L"bb.ico", IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE | LR_SHARED)
	mov		rax, 8050								
	push	rax										;LR_LOADFROMFILE | LR_DEFAULTSIZE | LR_SHARED
	push	0										;int cy: 0
	xor		r9, r9									;int cx: 0
	mov		r8, 1									;UINT type: IMAGE_ICON
	mov		rdx, iconname							;L"bb.ico"
	xor		rcx, rcx								;hInstance: NULL
	sub		rsp, 32
	call	LoadImageW
	add		rsp, 48
	
	mov		qword [ws+WNDCLASSEXW.hIcon], rax
	push	rax
	
	xor		rcx, rcx
	mov 	edx, 0x7F00
	sub		rsp, 32
	call	LoadCursorW
	add		rsp, 32
	mov		qword [ws+WNDCLASSEXW.hCursor], rax
	
	mov     ecx, 0x00FFFFFF
	sub		rsp, 32
	call	CreateSolidBrush
	add		rsp, 32
	mov		qword [ws+WNDCLASSEXW.hbrBackground], rax
	
	
	mov		qword [ws+WNDCLASSEXW.lpszMenuName], 0
	mov		qword [ws+WNDCLASSEXW.lpszClassName], g_szClassName
	
	pop		rax
	mov		qword [ws+WNDCLASSEXW.hIconSm], rax  

	lea		rcx, [ws]
	sub		rsp, 32
	call	RegisterClassExW
	add		rsp, 32
	
	;if (!RegisterClassExW(&wc))
	movzx   rax, ax
	mov		r14, rax
	
	test	rax, rax
	jnz		L1
			
	mov     r9d, 30h 			; uType
	mov     r8, "Error!"     	; "Error!"
	mov     rdx, message    	; "Window Registration Failed!"
	xor     ecx, ecx        	; hWnd
	sub		rsp, 32
	call    MessageBoxW
	add		rsp, 32
	xor     eax, eax

L1:
	;hwnd = CreateWindowEx(
		;0,
		;g_szClassName,
		;L"This is a title",
		;(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX),
		;CW_USEDEFAULT, CW_USEDEFAULT, 700, 387,
		;NULL, NULL, hInstance, NULL);
	push	0							;lpParam
	mov     rax, [rbp-56]
	push	rax							;hInstance
	push	0 							;hMenu
	push	0 							;hWndParent
	push	387							;nHeight
	push	700							;nWidth
	push	0x80000000		 			;Y
	push	0x80000000		 			;X
	mov     r9d, 0CA0000h;0x00C80000;0x00CA0000   			;dwStyle: WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX;
	mov     r8, windowtitle		  		;"This is a title"
	mov     rdx, g_szClassName 			;lpClassName
	xor     rcx, rcx        			;dwExStyle
	sub		rsp, 32
	call    CreateWindowExW
	add 	rsp, 96
	mov 	r15, rax
	
	;if (hwnd == NULL)
	test 	rax, rax
	jnz		L2
	call	GetLastError
	
	mov     r9d, 0x30 		  					; uType
	mov     r8, errormsg    					; "Error!"
	mov     rdx, message1 						; "Window Creation Failed!"
	xor     ecx, ecx        					; hWnd
	sub		rsp, 32
	call    MessageBoxW
	add		rsp, 32
	xor     eax, eax
	jmp		return
L2:
	;ShowWindow(hwnd, 1)
	mov		edx, 1
	mov		rcx, r15
	sub		rsp, 32
	call	ShowWindow
	add		rsp, 32
	
	;UpdateWindow(hwnd)
	mov		rcx, r15
	sub		rsp, 32
	call	UpdateWindow
	add		rsp, 32
GetMsgLoop:
	;while (GetMessage(&Msg, NULL, 0, 0) > 0)
	xor 	r9, r9
	xor		r8, r8
	xor		rdx, rdx
	lea		rcx, [rbp-48]						;&Msg
	mov		rbx, rcx
	sub		rsp, 32
	call	GetMessageW
	add		rsp, 32
	
	test 	eax, eax
	jz		.endloop
	
	;TranslateMessage(&Msg)
	mov		rcx, rbx
	sub		rsp, 32
	call	TranslateMessage
	add		rsp, 32
	;DispatchMessage(&Msg)
	mov		rcx, rbx
	sub		rsp, 32
	call	DispatchMessageW
	add		rsp, 32
	jmp		GetMsgLoop
	
.endloop:
	mov		rax, [rbx+MSG.wParam]
	
return:
	mov		rsp, rbp
	call    ExitProcess
	
