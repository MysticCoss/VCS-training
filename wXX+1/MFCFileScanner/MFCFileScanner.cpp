#include "pch.h"
#include "MFCFileScanner.h"

BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
{
	return false;
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

	//SetupDynamicResize();
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
			clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100 + clientRect.Height() * 8 / 100),
		this,
		id_ctrl_button_search);

	ctrl_list_foundfile.Create(
		LVS_REPORT | WS_BORDER | WS_VISIBLE,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100),
		this,
		id_ctrl_list_foundfile);

	ctrl_list_foundfile.SetBkColor(0xd4d4d3);

	int nCol = 0;
	CRect rect;
	ctrl_list_foundfile.GetClientRect(&rect);
	constexpr int baseColumnNumberOfUnit = 10;
	const int baseColumnWidth = rect.Width()/baseColumnNumberOfUnit;
	ctrl_list_foundfile.InsertColumn(nCol++, _T("Id"), LVCFMT_LEFT, baseColumnWidth*2);
	ctrl_list_foundfile.InsertColumn(nCol++, _T("Description"), LVCFMT_LEFT, baseColumnWidth*2);
	ctrl_list_foundfile.InsertColumn(nCol++, _T("Name"), LVCFMT_LEFT, baseColumnWidth*2);
	ctrl_list_foundfile.InsertColumn(nCol++, _T("Command line"), LVCFMT_LEFT, baseColumnWidth*2);
	ctrl_list_foundfile.InsertColumn(nCol++, _T("Full path"), LVCFMT_LEFT, rect.Width() - baseColumnWidth * 8);

	ctrl_button_refresh.SetFont(&font, 1);

	return 0;
}

	void CSimpleWindow::OnButtonClick_button_search()
{
	auto hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

	if (hSnap == INVALID_HANDLE_VALUE)
	{
		CString info;
		info.FormatMessage(_T("CreateToolhelp32Snapshot failed with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		//assert(false);
	}

	PROCESSENTRY32 lppe;
	
	if (!Process32First(hSnap,&lppe))
	{
		CString info;
		info.FormatMessage(_T("Process32First failed with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		//assert(false);
	}

	LVITEM lvi;
	int count = 0;
	ctrl_list_foundfile.SetRedraw(false);
	ctrl_list_foundfile.DeleteAllItems();

	do
	{
		DWORD processId = lppe.th32ProcessID;



		int subItemCount = 0;

		//CString insertStr;
		lvi.mask = LVIF_TEXT;
		lvi.iItem = count++;
		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)fileName;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)fileName;
#endif
		ctrl_list_foundfile.InsertItem(&lvi);


		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)sizeString;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)sizeString;
#endif
		ctrl_list_foundfile.SetItem(&lvi);


		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)fullPath;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)fullPath;
#endif
		ctrl_list_foundfile.SetItem(&lvi);

		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)dateModifiedString;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)dateModifiedString;
#endif
		ctrl_list_foundfile.SetItem(&lvi);

		lvi.iSubItem = subItemCount++;
#ifdef UNICODE
		lvi.pszText = (LPWSTR)(LPCTSTR)dateCreatedString;
#else
		lvi.pszText = (LPCSTR)(LPCTSTR)dateCreatedString;
#endif
		ctrl_list_foundfile.SetItem(&lvi);
	}
	while (Process32Next(hSnap, &lppe));

	ctrl_list_foundfile.SetRedraw(true);
	
	if(!ctrl_list_foundfile.IsWindowVisible())
	{
		ctrl_list_foundfile.ShowWindow(SW_SHOW);
	}
}

void CSimpleWindow::OnSizing(UINT nType, LPRECT newsize)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 13;
	
	CRect clientRect;
	GetClientRect(&clientRect);
	CRect r;
	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_refresh.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);

	ctrl_list_foundfile.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CSimpleWindow::OnSize(UINT nType, int cx, int cy)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 13;

	CRect clientRect;

	GetClientRect(&clientRect);

	CRect r;

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_refresh.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);

	ctrl_list_foundfile.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
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
		CSimpleWindow* Tester = new CSimpleWindow();
		m_pMainWnd = Tester;
		// Show the window
		m_pMainWnd->ShowWindow(SW_SHOW);
		m_pMainWnd->UpdateWindow();
		return TRUE;
	}


CSimpleApp theApp;