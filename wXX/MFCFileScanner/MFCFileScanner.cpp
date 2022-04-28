#include "pch.h"
#include "MFCFileScanner.h"

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
			_T("OLALA"), 
			WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX, 
			CRect(10, 5, 665, 195), 
			NULL, 
			0, 
			0, 
			0);
	}

	int CSimpleWindow::OnCreate(LPCREATESTRUCT lpCreateStruct)
	{
		ctrl_edit_filepath.Create(
			WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
			CRect(10, 5, 10 + 605, 5 + 25),
			this,
			id_ctrl_edit_filepath);

		ctrl_edit_filename.Create(
			WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
			CRect(10, 35, 10 + 605, 35 + 25),
			this, 
			id_ctrl_edit_filename);

		ctrl_edit_filepath.SetCueBanner(_T("Enter your file path to search"), 1);

		ctrl_edit_filename.SetCueBanner(_T("Enter your file name to search"), 1);

		ctrl_button_search.Create(
			_T("Search"), 
			WS_VISIBLE, 
			CRect(10 + 250, 65, 10 + 605 - 250, 65 + 25), 
			this,
			id_ctrl_button_search);

		ctrl_list_foundfile.Create(
			LVS_REPORT,
			CRect(10, 95, 10 + 605, 95 + 25),
			this,
			id_ctrl_list_foundfile);

		ctrl_list_foundfile.SetBkColor(0xd4d4d3);

		int nCol = 0;
		CRect rect;
		ctrl_list_foundfile.GetClientRect(&rect);
		constexpr int baseColumnNumberOfUnit = 10;
		const int baseColumnWidth = rect.Width()/baseColumnNumberOfUnit;
		ctrl_list_foundfile.InsertColumn(nCol++, _T("File name"), LVCFMT_LEFT, baseColumnWidth*2);
		ctrl_list_foundfile.InsertColumn(nCol++, _T("Size"), LVCFMT_LEFT, baseColumnWidth*2);
		ctrl_list_foundfile.InsertColumn(nCol++, _T("Full path"), LVCFMT_LEFT, baseColumnWidth*2);
		ctrl_list_foundfile.InsertColumn(nCol++, _T("Date modified"), LVCFMT_LEFT, baseColumnWidth*2);
		ctrl_list_foundfile.InsertColumn(nCol++, _T("Date created"), LVCFMT_LEFT, rect.Width() - baseColumnWidth * 8);

		ctrl_edit_filepath.SetFont(&font, 1);

		ctrl_edit_filename.SetFont(&font, 1);

		ctrl_button_search.SetFont(&font, 1);

		return 0;
	}

	void CSimpleWindow::OnButtonClick_button_search()
	{
		CString searchPath = _T("");

		CString searcFileName = _T("");

		ctrl_edit_filepath.GetWindowText(searchPath);

		ctrl_edit_filename.GetWindowText(searcFileName);

		CString fullpath = searchPath + _T("\\") + searcFileName + _T("*");

		WIN32_FIND_DATA ffd;

		auto hFind = FindFirstFile(fullpath, &ffd);

		auto nItem = 0;

		LVITEM lvi;
		CString strItem;

		if (INVALID_HANDLE_VALUE == hFind)
		{
			//TODO: Create Msgbox to notify about this error
			return;
		}

		do
		{
			CString fileName = ffd.cFileName;

			CString sizeString;
			QWORD size = ffd.nFileSizeHigh;
			size <<= 4;
			size += ffd.nFileSizeLow;
			sizeString.Format(_T("%llu bytes"), size);

			CString fullPath = searchPath + _T("\\") + fileName;

			CString dateModifiedString;
			auto dateModified = ffd.ftLastWriteTime;
			auto hHeap = GetProcessHeap();
			auto buffer = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1024);
#ifdef UNICODE
			SHFormatDateTime(&dateModified, NULL, (LPWSTR)buffer, 512);
			dateModifiedString = CString((LPWSTR)buffer);
#else 
			SHFormatDateTime(&dateModified, NULL, (LPWSTR)buffer, 1024);
			dateModifiedString = CString((LPSTR)buffer);
#endif

			memset(buffer, 0, 1024);

			CString dateCreatedString;
			auto dateCreated = ffd.ftCreationTime;
#ifdef UNICODE
			SHFormatDateTime(&dateCreated, NULL, (LPWSTR)buffer, 512);
			dateCreatedString = CString((LPWSTR)buffer);
#else 
			SHFormatDateTime(&dateCreated, NULL, (LPWSTR)buffer, 1024);
			dateCreatedString = CString((LPSTR)buffer);
#endif

			//TODO: Insert data to CListCtrl
		} while (FindNextFile(hFind, &ffd) != 0);
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