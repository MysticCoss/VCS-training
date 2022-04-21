#include <Windows.h>
const wchar_t g_szClassName[] = L"myWindowClass";
int leftrightdirection = 1;
int topbottomdirection = 1;
int radius = 20;
int speed = 3;
bool running = true;
HANDLE hHeap;
RECT r = { 0,0,2 * radius, 2 * radius };
HFONT hFont = NULL;
LONG_PTR WPA = NULL;
HWND hWndEditBoxSrc = NULL, hWndEditBoxDst = NULL;
LRESULT CALLBACK EditBoxProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
	if (msg == WM_CHAR && wParam == 1)
	{
		SendMessage(hwnd, EM_SETSEL, 0, -1);
		return 1;
	}
	return CallWindowProc((WNDPROC)WPA, hwnd, msg, wParam, lParam);
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_CREATE:
		{
		hWndEditBoxSrc = CreateWindowEx(WS_EX_WINDOWEDGE, L"EDIT", NULL,
			WS_VISIBLE | WS_CHILD | WS_BORDER | ES_LEFT| ES_AUTOHSCROLL,
			10, 5, 665, 25,
			hwnd,
			(HMENU)5, NULL, NULL);

		if(!hFont)
		{
			hFont = CreateFont(0, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE, ANSI_CHARSET,
				OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
				DEFAULT_PITCH | FF_DONTCARE, TEXT("Tahoma"));
		}
		SendMessage(hWndEditBoxSrc, WM_SETFONT, (WPARAM)hFont, TRUE);
		WPA = SetWindowLongPtr(hWndEditBoxSrc, GWLP_WNDPROC, (LONG_PTR)EditBoxProc);
		hWndEditBoxDst = CreateWindowEx(WS_EX_WINDOWEDGE, L"EDIT", NULL,
			WS_VISIBLE | WS_CHILD | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL | ES_READONLY,
			10, 35, 665, 25,
			hwnd,
			(HMENU)5, NULL, NULL);
		SendMessage(hWndEditBoxDst, WM_SETFONT, (WPARAM)hFont, TRUE);
		break;
		}
	case WM_CHAR:
		return 1;
	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		running = false;
		break;
	
	default:
		return DefWindowProc(hwnd, msg, wParam, lParam);
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
	LPSTR lpCmdLine, int nCmdShow)
{
	hHeap = GetProcessHeap();
	hInstance = GetModuleHandleW(NULL);
	WNDCLASSEX wc;
	HWND hwnd;
	MSG Msg;

	auto hIcon = (HICON)LoadImage( // returns a HANDLE so we have to cast to HICON
		NULL,             // hInstance must be NULL when loading from a file
		L"Awake.ico",   // the icon file name
		IMAGE_ICON,       // specifies that the file is an icon
		0,                // width of the image (we'll specify default later on)
		0,                // height of the image
		LR_LOADFROMFILE |  // we want to load a file (as opposed to a resource)
		LR_DEFAULTSIZE |   // default metrics based on the type (IMAGE_ICON, 32x32)
		LR_SHARED         // let the system release the handle when it's no longer used
	);

	//Step 1: Registering the Window Class
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = 0;
	wc.lpfnWndProc = WndProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = hIcon;
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = CreateSolidBrush(0x00FFFFFF); //WHITE BRUSH
	wc.lpszMenuName = NULL;
	wc.lpszClassName = g_szClassName;
	wc.hIconSm = hIcon;

	CONST ATOM WndClass = RegisterClassEx(&wc);
	if (!WndClass)
	{
		MessageBox(NULL, L"Window Registration Failed!", L"Error!",
			MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}
	
	// Step 2: Creating the Window
	auto a = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX;
	hwnd = CreateWindowEx(
		0,
		g_szClassName,
		L"Reverse text",
		(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX),
		CW_USEDEFAULT, CW_USEDEFAULT, 700, 105,
		NULL, NULL, hInstance, NULL);

	if (hwnd == NULL)
	{
		MessageBox(NULL, L"Window Creation Failed!", L"Error!",
			MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}

	ShowWindow(hwnd, 1);
	UpdateWindow(hwnd);
	int z = sizeof(Msg);
	// Step 3: The Message Loop
	while (running)
	{
		if(PeekMessage(&Msg, hwnd, 0, 0, PM_REMOVE))
		{
			TranslateMessage(&Msg);
			DispatchMessage(&Msg);
		}
		
		if(hWndEditBoxSrc!=NULL && hWndEditBoxDst!=NULL)
		{
			if (SendMessage(hWndEditBoxSrc, EM_GETMODIFY, 0, 0))
			{
				int msglength = SendMessage(hWndEditBoxSrc, WM_GETTEXTLENGTH, 0, 0);
				auto text = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, (++msglength) * 2);

				SendMessage(hWndEditBoxSrc, WM_GETTEXT, msglength, (LPARAM)text);
				int realmsglength = 0;
				while(*((LPWSTR)text + realmsglength)!=L'\0')
				{
					realmsglength++;
				}
				int j = realmsglength-1;
				int i = 0;
				while (i <= j)
				{
					WCHAR temp = *((LPWSTR)text + i);
					*((LPWSTR)text + i) = *((LPWSTR)text + j);
					*((LPWSTR)text + j) = temp;
					i++;
					j--;
				}
				SendMessage(hWndEditBoxDst, WM_SETTEXT, 0, (LPARAM)text);
				SendMessage(hWndEditBoxSrc, EM_SETMODIFY, 0, 0);
				HeapFree(hHeap, 0, text);
			}
		}
		
	}
	return Msg.wParam;
}