#include "MFCProcessViewer.h"

BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
{
	return false;
}

void CSimpleWindow::SetupWmiClient()
{
	auto hr = CoInitializeEx(0, COINIT_MULTITHREADED);
	if (FAILED(hr))
	{
		CString info;
		info.Format(_T("Failed to initialize COM library with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}

	hr = CoInitializeSecurity(
		NULL,                        // security descriptor
		-1,                          // use this simple setting
		NULL,                        // use this simple setting
		NULL,                        // reserved
		RPC_C_AUTHN_LEVEL_DEFAULT,   // authentication level  
		RPC_C_IMP_LEVEL_IMPERSONATE, // impersonation level
		NULL,                        // use this simple setting
		EOAC_NONE,                   // no special capabilities
		NULL);              // reserved

	if (FAILED(hr))
	{
		CoUninitialize();
		CString info;
		info.Format(_T("Failed to initialize security with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}

	

	hr = CoCreateInstance(CLSID_WbemLocator, 0,
		CLSCTX_INPROC_SERVER, IID_IWbemLocator, (LPVOID*)&pLoc);

	if (FAILED(hr))
	{
		CString info;
		info.Format(_T("Failed to create IWbemLocator object with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		CoUninitialize();
		return;     // Program has failed.
	}

	// Connect to the ROOT\CIMV2 namespace with the current user.
	hr = pLoc->ConnectServer(
		BSTR(L"ROOT\\CIMV2"),  //namespace
		NULL,       // User name 
		NULL,       // User password
		0,         // Locale 
		NULL,     // Security flags
		0,         // Authority 
		0,        // Context object 
		&pSvc);   // IWbemServices proxy

	if (FAILED(hr))
	{
		CString info;
		info.Format(_T("Could not connect to WMI with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		pLoc->Release();
		CoUninitialize();
		return;      // Program has failed.
	}

	hr = CoSetProxyBlanket(pSvc,
		RPC_C_AUTHN_WINNT,
		RPC_C_AUTHZ_NONE,
		NULL,
		RPC_C_AUTHN_LEVEL_CALL,
		RPC_C_IMP_LEVEL_IMPERSONATE,
		NULL,
		EOAC_NONE
	);

	if (FAILED(hr))
	{
		CString info;
		info.Format(_T("Could not set proxy blanket with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		return;      // Program has failed.
	}
}

CSimpleWindow::CSimpleWindow()
{
	font.CreateFontW(
		0,
		0,
		0,
		0,
		FW_DONTCARE,
		FALSE,
		FALSE,
		FALSE,
		ANSI_CHARSET,
		OUT_TT_PRECIS,
		CLIP_DEFAULT_PRECIS,
		DEFAULT_QUALITY,
		DEFAULT_PITCH | FF_DONTCARE,
		TEXT("Arial"));

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

	auto wndclass = AfxRegisterWndClass(0, LoadCursor(NULL, IDC_ARROW), CreateSolidBrush(0x00FFFFFF), hIcon);

	Create(
		wndclass, 
		_T("Process Viewer"), 
		WS_OVERLAPPEDWINDOW,
		rectDefault, 
		NULL, 
		0, 
		0, 
		0);

	SetupWmiClient();
}

CSimpleWindow::~CSimpleWindow()
{
	pSvc->Release();
	pLoc->Release();
	CoUninitialize();
}

bool CSimpleWindow::IsProcessElevated()
{
	BOOL fIsElevated = FALSE;
	HANDLE hToken = NULL;
	TOKEN_ELEVATION elevation;
	DWORD dwSize;

	if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
	{
		printf("\n Failed to get Process Token :%d.", GetLastError());
		goto Cleanup;  // if Failed, we treat as False
	}


	if (!GetTokenInformation(hToken, TokenElevation, &elevation, sizeof(elevation), &dwSize))
	{
		printf("\nFailed to get Token Information :%d.", GetLastError());
		goto Cleanup;// if Failed, we treat as False
	}

	fIsElevated = elevation.TokenIsElevated;

Cleanup:
	if (hToken)
	{
		CloseHandle(hToken);
		hToken = NULL;
	}
	return fIsElevated;
}

int CSimpleWindow::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	CRect clientRect;
	GetClientRect(&clientRect);

	int percentPadHorizontal = 2;
	int percentPadVertical = 3;
	int percentButtonHeight = 8;

	ctrl_button_refresh.Create(
		_T("Refresh"), 
		WS_VISIBLE, 
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100, 
			clientRect.top + clientRect.Height() * percentPadVertical / 100, 
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100),
		this,
		id_ctrl_button_search);

	ctrl_list_process.Create(
		LVS_REPORT | WS_BORDER | WS_VISIBLE,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100),
		this,
		id_ctrl_list_process);

	ctrl_list_process.SetBkColor(0xd4d4d3);

	int nCol = 0;
	CRect rect;
	ctrl_list_process.GetClientRect(&rect);
	constexpr int baseColumnNumberOfUnit = 10;
	const int baseColumnWidth = rect.Width()/baseColumnNumberOfUnit;
	ctrl_list_process.InsertColumn(nCol++, _T("Id"), LVCFMT_LEFT, baseColumnWidth*1);
	ctrl_list_process.InsertColumn(nCol++, _T("Name"), LVCFMT_LEFT, baseColumnWidth*2);
	ctrl_list_process.InsertColumn(nCol++, _T("Command line"), LVCFMT_LEFT, baseColumnWidth*3.5);
	ctrl_list_process.InsertColumn(nCol++, _T("Full path"), LVCFMT_LEFT, rect.Width() - baseColumnWidth * 6.5-1);
	ctrl_button_refresh.SetFont(&font, 1);

	return 0;
}

void CSimpleWindow::OnButtonClick_button_search()
{
	if (!IsProcessElevated())
	{
		CString info;
		info.Format(_T("As designed, you can not retrieve some information as unprevileged user such as command line or executable path etc from some system process. You should relaunch this application as administrator"));
		::MessageBox(NULL, info, _T("Information"), MB_OK | MB_ICONINFORMATION);
	}

	LVITEM lvi;
	int count = 0;
	ctrl_list_process.SetRedraw(false);
	ctrl_list_process.DeleteAllItems();




	IEnumWbemClassObject* pEnumerator = NULL;
	auto hr = pSvc->ExecQuery(
		bstr_t("WQL"),
		bstr_t("SELECT * FROM Win32_process"),
		WBEM_FLAG_FORWARD_ONLY,
		NULL, &pEnumerator);

	if (FAILED(hr))
	{
		CString info;
		info.Format(_T("ExecQuery failed with error code: %#x"), hr);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		return;      // Program has failed.
	}

	IWbemClassObject* pclsObj = NULL;
	ULONG uReturn = 0;

	while(pEnumerator)
	{
		pEnumerator->Next(WBEM_INFINITE, 1,
			&pclsObj, &uReturn);

		if(uReturn == 0)
		{
			break;
		}

		VARIANT vtProp;

		pclsObj->Get(L"ProcessId", 0, &vtProp, 0, 0);

		CString processIdString;

		processIdString.Format(_T("%u"), vtProp.uintVal);

		VariantClear(&vtProp);

		//Insert process id
		int subItemCount = 0;

		lvi.mask = LVIF_TEXT;
		lvi.iItem = count++;
		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)processIdString;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)processIdString;
#endif
		ctrl_list_process.InsertItem(&lvi);

		//Insert process name
		pclsObj->Get(L"Name", 0, &vtProp, 0, 0);

		CString processName = vtProp.bstrVal;

		VariantClear(&vtProp);

		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)processName;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)processName;
#endif
		ctrl_list_process.SetItem(&lvi);


		//Insert process command line
		pclsObj->Get(L"CommandLine", 0, &vtProp, 0, 0);

		CString commandLine = vtProp.bstrVal;

		VariantClear(&vtProp);

		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)commandLine;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)commandLine;
#endif
		ctrl_list_process.SetItem(&lvi);

		//Insert process full path
		pclsObj->Get(L"ExecutablePath", 0, &vtProp, 0, 0);

		CString executablePath = vtProp.bstrVal;

		VariantClear(&vtProp);
		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)executablePath;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)executablePath;
#endif
		ctrl_list_process.SetItem(&lvi);
	}

	ctrl_list_process.SetRedraw(true);
	
	if(!ctrl_list_process.IsWindowVisible())
	{
		ctrl_list_process.ShowWindow(SW_SHOW);
	}
}

void CSimpleWindow::OnSizing(UINT nType, LPRECT newsize)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;
	
	CRect clientRect;
	GetClientRect(&clientRect);
	CRect r;
	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_button_refresh.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);

	ctrl_list_process.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CSimpleWindow::OnSize(UINT nType, int cx, int cy)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	CRect clientRect;

	GetClientRect(&clientRect);

	CRect r;

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_button_refresh.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);

	ctrl_list_process.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	int nCol = 0;
	CRect rect;
	ctrl_list_process.GetClientRect(&rect);
	constexpr int baseColumnNumberOfUnit = 9;
	const int baseColumnWidth = rect.Width() / baseColumnNumberOfUnit;
	ctrl_list_process.SetColumnWidth(nCol++, baseColumnWidth * 1);
	ctrl_list_process.SetColumnWidth(nCol++, baseColumnWidth * 2);
	ctrl_list_process.SetColumnWidth(nCol++, baseColumnWidth * 3);
	ctrl_list_process.SetColumnWidth(nCol++, rect.Width() - baseColumnWidth * 6 - 1);
}

void CSimpleWindow::OnGetMinMaxInfo(MINMAXINFO* lpMMI)
{
	lpMMI->ptMinTrackSize.x = 636;
	lpMMI->ptMinTrackSize.y = 404;
}

BOOL CSimpleApp::InitInstance()
	{
		// Use a pointer to the window's frame for the application
		// to use the window
		CSimpleWindow* myMainWindow = new CSimpleWindow();
		m_pMainWnd = myMainWindow;
		// Show the window
		m_pMainWnd->ShowWindow(SW_SHOW);
		m_pMainWnd->UpdateWindow();
		return TRUE;
	}


CSimpleApp theApp;
