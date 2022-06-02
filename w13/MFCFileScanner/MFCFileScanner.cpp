#include "MFCFileScanner.h"

#include <regex>
#include <stack>
#include <vector>

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
		_T("OLALA"), 
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
	int percentButtonHeight = 13;

	ctrl_edit_filepath.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100, 
			clientRect.top + clientRect.Height() * percentPadVertical / 100, 
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100, 
			clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100),
		this,
		id_ctrl_edit_filepath);

	ctrl_edit_filename.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100, 
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100, 
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2/ 100),
		this, 
		id_ctrl_edit_filename);

	ctrl_edit_filepath.SetCueBanner(_T("Enter your file path to search"), 1);

	ctrl_edit_filename.SetCueBanner(_T("Enter your file name to search"), 1);

	ctrl_button_search.Create(
		_T("Search"), 
		WS_VISIBLE, 
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100, 
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 , 
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100),
		this,
		id_ctrl_button_search);

	ctrl_list_foundfile.Create(
		LVS_REPORT | WS_BORDER,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
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

//	void CSimpleWindow::ListDirectory(CString path, std::vector<CString>& a)
//{
//		//recursive finding
//		CString tmpStr = path + _T("\\*");
//
//		auto hFind = FindFirstFile(tmpStr, &ffd);
//
//		std::vector<CString> directories;
//
//		if (hFind != INVALID_HANDLE_VALUE)
//		{
//			do
//			{
//				if (ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) //yes it's a directory
//				{
//					if ((!lstrcmp(ffd.cFileName, _T("."))) || (!lstrcmp(ffd.cFileName, _T("..")))) //skip . and ..
//						continue;
//				}
//
//			} while (FindNextFileW(hFind, &ffd));
//		}
//}

	void CSimpleWindow::OnButtonClick_button_search()
{
	CString searchPath = _T("");

	CString searchFileName = _T("");

	ctrl_edit_filepath.GetWindowText(searchPath);
	if (searchPath.IsEmpty()) {
		searchPath = _T("C:");
	}

	ctrl_edit_filename.GetWindowText(searchFileName);

	CString fullpath = searchPath + _T("\\") + searchFileName;

	//recursive finding

	std::vector<CString> directoriestosearch;
	directoriestosearch.push_back(searchPath);

	LVITEM lvi;
	int count = 0;

	ctrl_list_foundfile.SetRedraw(false);
	ctrl_list_foundfile.DeleteAllItems();

	while (!directoriestosearch.empty())
	{
		WIN32_FIND_DATA ffd;
		CString currentFolder = directoriestosearch.back();
		directoriestosearch.pop_back();
		auto hFind = FindFirstFile(currentFolder + _T("\\*"), &ffd);
		if (hFind != INVALID_HANDLE_VALUE)
		{
			do
			{
				if (ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) //yes it's a directory
				{
					if ( !lstrcmp(ffd.cFileName, _T(".")) || !lstrcmp(ffd.cFileName, _T("..")) ) //skip . and ..
						continue;
					else
					{
						CString dir = CString(ffd.cFileName);
						CString dirPath = currentFolder + _T("\\") + dir;
						directoriestosearch.push_back(dirPath);
					}
				}
				else //it's a file
				{
					//so we check it's name
					CString fileName = ffd.cFileName;
					CString fileNameLower = CString(fileName);
					fileNameLower.MakeLower();
					CString searchFileNameLower = CString(searchFileName);
					searchFileNameLower.MakeLower();
					if (fileNameLower.Find(searchFileNameLower) == -1) //not found
					{
						continue;
					}

					CString sizeString;

					QWORD size = ffd.nFileSizeHigh;

					size <<= 4;

					size += ffd.nFileSizeLow;

					sizeString.Format(_T("%llu bytes"), size);

					if (!StrCmp(currentFolder.Right(1), _T("\\")))
					{
						currentFolder.Truncate(currentFolder.GetLength() - 1);
					}

					CString fullPath = currentFolder + _T("\\") + fileName;

					CString dateModifiedString;

					auto dateModified = ffd.ftLastWriteTime;

					auto hHeap = GetProcessHeap();

					auto buffer = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 1024);

					assert(buffer != 0);
#ifdef UNICODE
					SHFormatDateTime(&dateModified, NULL, (LPWSTR)buffer, 512);
					dateModifiedString = CString((LPWSTR)buffer);
#else 
					SHFormatDateTime(&dateModified, NULL, (LPSTR)buffer, 1024);
					dateModifiedString = CString((LPSTR)buffer);
#endif

					memset(buffer, 0, 1024);

					CString dateCreatedString;
					auto dateCreated = ffd.ftCreationTime;
#ifdef UNICODE
					SHFormatDateTime(&dateCreated, NULL, (LPWSTR)buffer, 512);
					dateCreatedString = CString((LPWSTR)buffer);
#else 
					SHFormatDateTime(&dateCreated, NULL, (LPSTR)buffer, 1024);
					dateCreatedString = CString((LPSTR)buffer);
#endif

					CString insertStr;

					int subItemCount = 0;
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
			} while (FindNextFileW(hFind, &ffd));
		}
		else
		{
			//TODO: Create Msg box to notify about this error
			return;
		}
	} 
	
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
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_filename.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_edit_filepath.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_search.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
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
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_filename.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_edit_filepath.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_search.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);

	ctrl_list_foundfile.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CSimpleWindow::OnGetMinMaxInfo(MINMAXINFO* lpMMI)
{
	lpMMI->ptMinTrackSize.x = 636;
	lpMMI->ptMinTrackSize.y = 404;
}

void CSimpleWindow::SetupDynamicResize()
{
	this->EnableDynamicLayout(TRUE);
	CMFCDynamicLayout* dynamicLayout = this->GetDynamicLayout();

	auto moveSettings = CMFCDynamicLayout::MoveNone();
	auto sizeSettings = CMFCDynamicLayout::SizeHorizontal(100);

	dynamicLayout->AddItem(ctrl_edit_filepath.m_hWnd, moveSettings, sizeSettings);

	dynamicLayout->AddItem(ctrl_edit_filename, moveSettings, sizeSettings);

	dynamicLayout->AddItem(id_ctrl_button_search, moveSettings, sizeSettings);


	sizeSettings = CMFCDynamicLayout::SizeHorizontalAndVertical(100, 100);
	dynamicLayout->AddItem(id_ctrl_list_foundfile, moveSettings, sizeSettings);
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