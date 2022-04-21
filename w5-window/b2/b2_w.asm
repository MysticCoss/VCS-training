bits 64
default rel

segment .data
	g_szClassName 		dw __utf16__('myWindowClass'), 0
	windowtitle			dw __utf16__('Rì vợt tếch bóc'), 0
	message				dw __utf16__('Window Registration Failed!'), 0
	message1			dw __utf16__('Window Creation Failed!'), 0
	errormsg			dw __utf16__('Error!'), 0
	iconname			dw __utf16__('Awake.ico'), 0
segment .bss
	running				resq 1
	hHeap 				resq 1
	ws					resb 80
	hWndEditBoxSrc		resq 1
	hWndEditBoxDst		resq 1
	
	struc WNDCLASSEXW
		.cbSize         : resd 1                    
		.style          : resd 1                    
		.lpfnWndProc    : resq 1                    
		.cbClsExtra     : resd 1                    
		.cbWndExtra     : resd 1                    
		.hInstance      : resq 1                    
		.hIcon          : resq 1                    
		.hCursor        : resq 1                    
		.hbrBackground  : resq 1                    
		.lpszMenuName   : resq 1                    
		.lpszClassName  : resq 1                    
		.hIconSm        : resq 1                    
	endstruc
	
	struc RECT
		.left 			: resd 1
		.top			: resd 1
		.right			: resd 1
		.bottom			: resd 1
	endstruc
	
	struc PAINTSTRUCT   ;(sizeof=0x48, align=0x8)									
		.hdc            : resq 1
		.fErase         : resd 1
		.rcPaint        : resb 16 ;RECT
		.fRestore       : resd 1
		.fIncUpdate     : resd 1
		.rgbReserved    : resb 32 
						  alignb 8
	endstruc
	
	struc MSG           ; (sizeof=0x30, align=0x8, copyof_592)								
		.hwnd           : resq 1                    
		.message        : resd 1
						  alignb 8
		.wParam         : resq 1                
						  alignb 8
		.lParam         : resq 1
		.time           : resd 1
		.pt             : resd 2
		.lPrivate		: resd 1
	endstruc
	
segment .text
	extern ExitProcess
	extern HeapAlloc
	extern HeapReAlloc
	extern HeapFree
	extern GetProcessHeap
	extern LoadImageW
	extern LoadCursorW
	extern CreateSolidBrush
	extern RegisterClassExW
	extern MessageBoxW
	extern CreateWindowExW
	extern GetClientRect   
	extern BeginPaint     
	extern CreateCompatibleDC
	extern CreateCompatibleBitmap
	extern SelectObject   
	extern FillRect       
	extern DeleteObject   
	extern CreatePen       
	extern Ellipse          
	extern BitBlt                 
	extern DeleteDC       
	extern EndPaint       
	extern Sleep          
	extern InvalidateRect 
	extern DestroyWindow  
	extern PostQuitMessage
	extern DefWindowProcW
	extern ShowWindow	     
	extern UpdateWindow	   		          
	extern GetMessageW	    
	extern TranslateMessage
	extern DispatchMessageW
	extern GetModuleHandleW
	extern GetLastError

global Start	

WndProc: ;HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam
		 ;		rcx		  edx			r8				r9

	push	rbp
	mov 	rbp, rsp
	
	;local variable:
	;offset -120: HGDIOBJ oldhbm
	;offset -112: HDC hdc
	;offset -104: PAINTSTRUCT ps
	;offset -32 : LPARAM lParam
	;offset -24 : WPARAM wParam
	;offset -16 : UINT msg
	;offset -8  : HWND hwnd
	sub		rsp, 256
	
	mov     [rbp-32], r9
	mov     [rbp-24], r8
	mov     [rbp-16], edx
	mov     [rbp-8], rcx
	
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	
	cmp		edx, 0x10
	jz		.WM_CLOSE
	cmp		edx, 0x2
	jz		.WM_DESTROY
	cmp		edx, 0x1
	jz		.WM_CREATE
	jmp		.DEFAULT
.WM_CREATE:
	;hWndEditBoxSrc = CreateWindowExW(WS_EX_WINDOWEDGE, L"EDIT", NULL,
	;	WS_VISIBLE | WS_CHILD | WS_BORDER | ES_LEFT| ES_AUTOHSCROLL,
	;	10, 5, 665, 25,
	;	hwnd,
	;	(HMENU)5, NULL, NULL)
	push	0
	push 	0
	push	5
	mov		rax, [rbp-8]
	push	rax
	push	25
	push	665
	push	5
	push	10
	mov		r9d, 
	call	CreateWindowExW
	
	xor		rax, rax
	jmp		.return


.WM_CLOSE:
	mov		rcx, [rbp-8]
	sub		rsp, 32
	call	DestroyWindow
	add		rsp, 32
	xor		rax, rax
	jmp		.return	
	
.WM_DESTROY:
	xor		rcx, rcx
	sub		rsp, 32
	call	PostQuitMessage
	add		rsp, 32
	xor		rax, rax
	jmp		.return	

.DEFAULT:
	mov     r9, [rbp-32]
	mov     r8, [rbp-24]
	mov     edx, [rbp-16]
	mov     rcx, [rbp-8]
	sub		rsp, 40
	call	DefWindowProcW
	add		rsp, 40
	jmp		.return	
	
	
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
    ;offset -56  :HINSTANCE hInstance
    ;offset -48  :MSG Msg
    ;offset -40  :
    ;offset -32  :
    ;offset -24	 :
    ;offset -16  :
    ;offset -8   :
	
	;Initalize global variable
	mov		qword [running], 1
	mov		qword [hWndEditBoxDst], 0
	mov		qword [hWndEditBoxSrc], 0
	
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
		;windowtitle,
		;(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX),
		;CW_USEDEFAULT, CW_USEDEFAULT, 700, 105,
		;NULL, NULL, hInstance, NULL);
	push	0							;lpParam
	mov     rax, [rbp-56]
	push	rax							;hInstance
	push	0 							;hMenu
	push	0 							;hWndParent
	push	105							;nHeight
	push	700							;nWidth
	push	0x80000000		 			;Y
	push	0x80000000		 			;X
	mov     r9d, 0CA0000h				;dwStyle: WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX;
	mov     r8, windowtitle		  		;windowtitle
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
	;while (running)
	mov		rax, [running]
	test 	rax, rax
	jz		.endloop

	;if(PeekMessage(&Msg, hwnd, 0, 0, PM_REMOVE))
	push	1									;PM_REMOVE
	xor 	r9, r9
	xor		r8, r8
	xor		rdx, rdx
	lea		rcx, [rbp-48]						;&Msg
	mov		rbx, rcx
	sub		rsp, 32
	call	PeekMessageW
	add		rsp, 32
	
	test 	rax, rax
	jz		.peekzero
	
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
	
.peekzero:
	;if(hWndEditBoxSrc!=NULL && hWndEditBoxDst!=NULL)
	mov		rcx, [hWndEditBoxDst] 
	mov		rdx, [hWndEditBoxSrc]
	test	rcx, rcx
	jz		.GetMsgLoop
	test	rdx, rdx
	jz		.GetMsgLoop
	
	;if (SendMessageW(hWndEditBoxSrc, EM_GETMODIFY, 0, 0))
	xor		r9, r9
	xor		r8, r8
	mov		edx, 0x000000B8
	mov		rcx, [hWndEditBoxSrc]
	call	SendMessageW
	
	test	rax, rax
	jz		GetMsgLoop
	
	;int msglength = SendMessageW(hWndEditBoxSrc, WM_GETTEXTLENGTH, 0, 0);
	xor		r9, r9
	xor		r8, r8
	mov		edx, 0x0000000E
	mov		rcx, [hWndEditBoxSrc]
	call	SendMessageW
	
	;++msglength
	mov		r15d, eax
	inc		r15d
	
	;LPVOID text = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (++msglength) * 2);
	mov		r8d, r15d
	shl		r8d, 1
	mov		edx, 8
	mov		rcx, [hHeap]
	call	HeapAlloc
	
	mov		r14, rax
	
	;SendMessageW(hWndEditBoxSrc, WM_GETTEXT, msglength, (LPARAM)text)
	mov		r9, r14
	mov		r8d, r15d
	mov		edx, 0x0000000D
	mov		rcx, [hWndEditBoxSrc]
	call	SendMessageW

.L1:
	mov		rax, r14
	add		rax, r15
	movzx	rax, word[rax]
	test 	rax, rax
	jnz		EndL1
	dec		r15
	jmp		.L1
	
	
.EndL1:
	xor		r13, r13
.L2
	;while (i <= j)
	
	cmp		r13, r15
	jg		.L2End
	mov		rax, r14
	add		rax, r13
	mov		cx, word[rax]
	
	mov		rdx, r14
	add		rdx, r15
	mov		bx, word[rdx]
	
	mov		word[rax], bx
	mov		word[rdx], cx
	inc		r13
	dec		r15
	
	jmp		.L2
.L2End:
	;SendMessageW(hWndEditBoxDst, WM_SETTEXT, 0, (LPARAM)text)
	mov		r9, r14
	xor		r8, r8
	mov		edx, 0x0000000C
	mov		rcx, [hWndEditBoxDst]
	call	SendMessageW
	
	;SendMessageW(hWndEditBoxSrc, EM_SETMODIFY, 0, 0)
	xor		r9, r9
	xor		r8, r8
	mov		edx, 0x000000B9
	mov		rcx, [hWndEditBoxSrc]
	call	SendMessageW
	
	mov		r8, r14
	xor		rdx, rdx
	mov		rcx, [hHeap]
	call	HeapFree
	
	jmp		GetMsgLoop

.endloop:
	xor		rax, rax
	
return:
	mov		rsp, rbp
	call    ExitProcess
	
