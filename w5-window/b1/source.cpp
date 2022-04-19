#include <Windows.h>
const wchar_t g_szClassName[] = L"myWindowClass";
int leftrightdirection = 1;
int topbottomdirection = 1;
int radius = 20;
int speed = 3;
RECT r = { 0,0,2 * radius, 2 * radius };

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_PAINT:
	{
		RECT rct;
		auto b = sizeof(rct);
		
		GetClientRect(hwnd, &rct);
		PAINTSTRUCT ps;
		auto c = sizeof(ps.fIncUpdate);
		auto d = sizeof(ps.hdc);
		auto a = sizeof(ps);
		ps.fErase = true;
		GetWindowRect(hwnd, &ps.rcPaint);
		HDC hdc = BeginPaint(hwnd, &ps);


		if (r.right + leftrightdirection * speed > ps.rcPaint.right)
		{
			leftrightdirection = -leftrightdirection;
		}
		if (r.left + leftrightdirection * speed < 0)
		{
			leftrightdirection = -leftrightdirection;
		}
		if (r.bottom + topbottomdirection * speed > rct.bottom)
		{
			topbottomdirection = -topbottomdirection;
		}
		if (r.top + topbottomdirection * speed < 0)
		{
			topbottomdirection = -topbottomdirection;
		}

		r.left += leftrightdirection * speed;
		r.top += topbottomdirection * speed;
		r.right += leftrightdirection * speed;
		r.bottom += topbottomdirection * speed;

		//double buffer
		HDC memhdc = CreateCompatibleDC(hdc);
		HBITMAP memhbm = CreateCompatibleBitmap(hdc, rct.right - rct.left, rct.bottom - rct.top);
		HGDIOBJ oldhbm = SelectObject(memhdc, memhbm);
		

		//erase background
		HBRUSH newbrush = CreateSolidBrush(0x00FFFFFF);
		FillRect(memhdc, &rct, newbrush);
		DeleteObject(newbrush);

		//draw on hdc on memory
		auto newpen = CreatePen(PS_SOLID, 3, 0x00000000);
		auto x1 = GetLastError();
		auto newbrushh = CreateSolidBrush(0x002530D9);
		auto x2 = GetLastError();
		HGDIOBJ oldpen = SelectObject(memhdc, newpen);
		HGDIOBJ oldbrush = SelectObject(memhdc, newbrushh);
		Ellipse(memhdc, r.left, r.top, r.right, r.bottom);

		//set brush and pen back
		newbrushh = (HBRUSH)SelectObject(memhdc, oldbrush);
		newpen = (HPEN)SelectObject(memhdc, oldpen);
		//copy the hdc on memory to real one
		BitBlt(hdc, rct.left, rct.top, rct.right - rct.left, rct.bottom - rct.top, memhdc, 0, 0, SRCCOPY);

		//cleanup

		//set old bitmap back
		memhbm = (HBITMAP)SelectObject(memhdc, oldhbm);
		DeleteObject(memhbm);
		DeleteObject(newbrushh);
		DeleteObject(newpen);

		DeleteObject(memhdc);
		DeleteDC(memhdc);
		DeleteObject(hdc);
		DeleteDC(hdc);

		EndPaint(hwnd, &ps);
		Sleep(8);
		InvalidateRect(hwnd, NULL, TRUE);
		
		break;
	}
	case WM_ERASEBKGND:
		return (LRESULT)1; // Say we handled it.

	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	
	default:
		return DefWindowProc(hwnd, msg, wParam, lParam);
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
	LPSTR lpCmdLine, int nCmdShow)
{
	hInstance = GetModuleHandleW(NULL);
	WNDCLASSEX wc;
	HWND hwnd;
	MSG Msg;

	//Step 1: Registering the Window Class
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = 0;
	wc.lpfnWndProc = WndProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = CreateSolidBrush(0x00FFFFFF); //WHITE BRUSH
	wc.lpszMenuName = NULL;
	wc.lpszClassName = g_szClassName;
	wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION);

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
		L"This is a title",
		(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX),
		CW_USEDEFAULT, CW_USEDEFAULT, 700, 387,
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
	while (GetMessage(&Msg, NULL, 0, 0) > 0)
	{
		
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}
	return Msg.wParam;
}