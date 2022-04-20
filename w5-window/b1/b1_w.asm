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
	leftrightdirection 	resd 1
	topbottomdirection  resd 1
	radius 				resd 1
	speed				resd 1
	
	hHeap 				resq 1
	ws					resb 80
	r					resb 16
	
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
	
	cmp		edx, 0xF
	jz		.WM_PAINT
	cmp		edx, 0x14
	jz		.WM_ERASEBKGND
	cmp		edx, 0x10
	jz		.WM_CLOSE
	cmp		edx, 0x2
	jz		.WM_DESTROY
	jmp		.DEFAULT
	
.WM_PAINT:
	
	;GetClientRect(hwnd, &ps.rcPaint) 
	mov		rcx, [rbp-8]
	lea		rdx, [rbp-104+PAINTSTRUCT.rcPaint]
	sub		rsp, 32
	call	GetClientRect
	add		rsp, 32
	
	;ps.fErase = true
	mov		dword [rbp-104+PAINTSTRUCT.fErase], 1
	
	;HDC hdc = BeginPaint(hwnd, &ps)
	mov 	rcx, [rbp-8]					;hwnd
	lea		rdx, [rbp-104]					;&ps
	sub		rsp, 32
	call	BeginPaint
	add		rsp, 32
	mov		[rbp-112], rax
	
	mov 	eax, [leftrightdirection]
	imul	eax, [speed]
	mov		ecx, [r+RECT.right]
	add		ecx, eax
	cmp 	ecx, [rbp-104+PAINTSTRUCT.rcPaint+RECT.right]
	jle		.donecheckright
	mov		eax, [leftrightdirection]
	neg		eax
	mov		[leftrightdirection], eax
.donecheckright:
	mov 	eax, [leftrightdirection]
	imul	eax, [speed]
	mov		ecx, [r+RECT.left]
	add		ecx, eax
	cmp 	ecx, 0
	jge		.donecheckleft
	mov		eax, [leftrightdirection]
	neg		eax
	mov		[leftrightdirection], eax
.donecheckleft:
	mov 	eax, [topbottomdirection]
	imul	eax, [speed]
	mov		ecx, [r+RECT.bottom]
	add		ecx, eax
	cmp 	ecx, [rbp-104+PAINTSTRUCT.rcPaint+RECT.bottom]
	jle		.donecheckbotom
	mov		eax, [topbottomdirection]
	neg		eax
	mov		[topbottomdirection], eax
.donecheckbotom:
	mov 	eax, [topbottomdirection]
	imul	eax, [speed]
	mov		ecx, [r+RECT.top]
	add		ecx, eax
	cmp 	ecx, 0
	jge		.donechecktop
	mov		eax, [topbottomdirection]
	neg		eax
	mov		[topbottomdirection], eax	
.donechecktop:
	;leftrightdirection * speed -> eax
	mov 	eax, [leftrightdirection]
	imul	eax, [speed]
	
	;r.right += leftrightdirection * speed
	add 	dword [r+RECT.right], eax
	
	;r.left += leftrightdirection * speed
	add		dword [r+RECT.left], eax
	
	;topbottomdirection * speed
	mov 	eax, [topbottomdirection]
	imul	eax, [speed]
	
	;r.top += topbottomdirection * speed
	add		dword [r+RECT.top], eax
			
	;r.bottom += topbottomdirection * speed
	add		dword [r+RECT.bottom], eax
	
	;Implement double buffering to prevent screen flickering
	;HDC memhdc[r15] = CreateCompatibleDC(hdc)
	mov 	rcx, [rbp-112]		;hdc
	sub		rsp, 32
	call	CreateCompatibleDC
	add		rsp, 32
	mov		r15, rax
	
	;HBITMAP memhbm = CreateCompatibleBitmap(hdc, rct.right - rct.left, rct.bottom - rct.top)
	mov		r8d, [rbp-104+PAINTSTRUCT.rcPaint+RECT.bottom]
	mov		eax, [rbp-104+PAINTSTRUCT.rcPaint+RECT.top]
	sub 	r8d, eax			;rct.bottom - rct.top
	mov		edx, [rbp-104+PAINTSTRUCT.rcPaint+RECT.right]
	mov		eax, [rbp-104+PAINTSTRUCT.rcPaint+RECT.left]
	sub 	edx, eax			;rct.right - rct.left
	mov		rcx, [rbp-112]			;hdc
	sub		rsp, 32
	call	CreateCompatibleBitmap
	add		rsp, 32
	
	;HGDIOBJ oldhbm[r14] = SelectObject(memhdc, memhbm)
	mov 	rdx, rax			;memhbm
	mov		rcx, r15			;r15
	sub		rsp, 32
	call	SelectObject
	add		rsp, 32
	mov		r14, rax
	
	;erase background
	;HBRUSH newbrush[r13] = CreateSolidBrush(0x00FFFFFF)
	mov		ecx, 0x00FFFFFF
	sub		rsp, 32
	call	CreateSolidBrush
	add		rsp, 32
	mov		r13, rax
	
	;FillRect(memhdc, &rct, newbrush)
	mov		r8, r13								;newbrush
	lea 	rdx, [rbp-104+PAINTSTRUCT.rcPaint]	;ps.rcPaint
	mov		rcx, r15							;memhdc
	sub		rsp, 32
	call	FillRect
	add		rsp, 32
	
	;DeleteObject(newbrush)
	mov		rcx, r13
	sub		rsp, 32
	call 	DeleteObject
	add		rsp, 32
	
	;draw on hdc on memory
	;HGDIOBJ oldpen[r13] = SelectObject(memhdc, CreatePen(PS_SOLID,3,0x00000000))
	xor		r8d, r8d
	mov		edx, 3
	xor 	rcx, rcx
	sub		rsp, 32
	call	CreatePen	
	add		rsp, 32
	push	rax	;save for later clean up
	mov		rdx, rax					;CreatePen(PS_SOLID,3,0x00000000)
	mov		rcx, r15					;memhdc
	call	SelectObject
	mov		r13, rax
	
	;HGDIOBJ oldbrush[r12] = SelectObject(memhdc, CreateSolidBrush(0x002530D9))
	mov		ecx, 0x002530D9
	sub		rsp, 32
	call	CreateSolidBrush
	add		rsp, 32
	push	rax	;save for later clean up
	mov		rdx, rax					;CreateSolidBrush(0x002530D9)
	mov		rcx, r15					;memhdc
	sub		rsp, 32
	call	SelectObject
	add		rsp, 32
	mov		r12, rax
	
	;Ellipse(memhdc, r.left, r.top, r.right, r.bottom)
	mov		eax, [r+RECT.bottom]
	push 	rax							;r.bottom
	mov		r9d, [r+RECT.right]			;r.right
	mov		r8d, [r+RECT.top]			;r.top
	mov		edx, [r+RECT.left]			;r.left
	mov		rcx, r15					;memhdc
	sub		rsp, 32
	call	Ellipse
	add		rsp, 40
	
	;set brush and pen back
	;SelectObject(memhdc, oldbrush)
	mov		rdx, r12
	mov		rcx, r15
	sub		rsp, 32
	call	SelectObject
	add		rsp, 32
	
	;SelectObject(memhdc, oldpen)
	mov		rdx, r13
	mov		rcx, r15
	sub		rsp, 32
	call	SelectObject
	add		rsp, 32
	
	;copy the hdc on memory to real one
	;BitBlt(hdc, rct.left, rct.top, rct.right - rct.left, rct.bottom - \
		;rct.top, memhdc, 0, 0, SRCCOPY)
	push	0x00CC0020						;DWORD rop = SRCCOPY
	push	0								;int y1 = 0
	push	0								;int x1 = 0
	push	r15								;hdcSrc = memhdc
	mov		ecx, [rbp-104+PAINTSTRUCT.rcPaint+RECT.bottom]
	sub		ecx, dword [rbp-104+PAINTSTRUCT.rcPaint+RECT.top]
	push	rcx
	mov		r9d, [rbp-104+PAINTSTRUCT.rcPaint+RECT.right]
	sub		r9d, dword [rbp-104+PAINTSTRUCT.rcPaint+RECT.left]	
	mov		r8d, [rbp-104+PAINTSTRUCT.rcPaint+RECT.top]
	mov		edx, [rbp-104+PAINTSTRUCT.rcPaint+RECT.left]
	mov		rcx, [rbp-112]						;hdc
	sub		rsp, 32
	call	BitBlt
	add		rsp, 72
	
	;swap back all GDI object and clean up excess GDI object
	;prevent leaking
	
	;memhbm = (HBITMAP)SelectObject(memhdc, oldhbm)
	mov		rdx, r14				;oldhbm
	mov		rcx, r15				;memhdc
	sub		rsp, 32
	call	SelectObject
	add		rsp, 32
	
	;DeleteObject(memhbm)
	mov		rcx, rax
	sub		rsp, 32
	call	DeleteObject
	add		rsp, 32
	
	;Delete pen created before
	pop		rcx
	sub		rsp, 32
	call	DeleteObject
	add		rsp, 32
	
	;Delete brush created before
	pop		rcx
	sub		rsp, 32
	call	DeleteObject
	add		rsp, 32
	
	;DeleteObject(memhdc)
	mov		rcx, r15
	sub		rsp, 32
	call	DeleteObject
	add		rsp, 32
	
	;DeleteDC(memhdc)
	mov		rcx, r15
	sub		rsp, 32
	call	DeleteDC
	add		rsp, 32
	
	;DeleteObject(hdc)
	mov		rcx, rbx
	sub		rsp, 32
	call	DeleteObject
	add		rsp, 32
	
	;DeleteDC(hdc)
	sub		rsp, 32
	mov		rcx, rbx
	call	DeleteDC
	add		rsp, 32
	
	;EndPaint(hwnd, &ps)
	lea		rdx, [rbp-104]			;ps
	mov		rcx, [rbp-8]			;hwnd
	mov		rbx, rcx
	sub		rsp, 32
	call	EndPaint
	add		rsp, 32
	
	mov		ecx, 10
	sub		rsp, 32
	call	Sleep
	add		rsp, 32
	
	;InvalidateRect(hwnd, NULL, TRUE)
	mov		r8d, 1					;BOOL bErase: TRUE
	xor		rdx, rdx				;RECT* : NULL
	mov		rcx, rbx				;HWND : hwnd
	sub		rsp, 32
	call	InvalidateRect
	add		rsp, 32
	
	xor		rax, rax
	jmp		.return
	
.WM_ERASEBKGND:
	mov		eax, 1
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
	
