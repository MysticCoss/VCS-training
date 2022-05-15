#include "CMainFrameServer.h"
#include <Windows.h>
//BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
//{
//	return false;
//}

BEGIN_MESSAGE_MAP(CMainFrameServer, CFrameWnd)
	ON_WM_CREATE()
	ON_WM_GETMINMAXINFO()
	ON_BN_CLICKED(2, OnButtonClick_button_start) //id_ctrl_button_start
	ON_BN_CLICKED(4, OnButtonClick_button_stop)  //id_ctrl_button_stop
	ON_WM_SIZING()
	ON_WM_SIZE()
END_MESSAGE_MAP()


CMainFrameServer::CMainFrameServer()
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

	CFrameWnd::Create(
		wndclass,
		_T("Chatbox server"),
		WS_OVERLAPPEDWINDOW,
		rectDefault,
		NULL,
		0,
		0,
		0);
	mySock.SetListener(this);
}

void CMainFrameServer::OnAccept(CString ipAddress, USHORT port)
{
	int subItemCount = 0;
	CString numStr, portStr;
	LVITEM lvi;
	lvi.mask = LVIF_TEXT;
	lvi.iItem = mySock.clientCount-1;
	lvi.iSubItem = subItemCount++;
	numStr.Format(_T("%d"), mySock.clientCount);
	lvi.pszText = (LPWSTR)(LPCTSTR)numStr;
	ctrl_list_connectedclient.InsertItem(&lvi);

	lvi.iSubItem = subItemCount++;
	lvi.pszText = (LPWSTR)(LPCTSTR)ipAddress;
	ctrl_list_connectedclient.SetItem(&lvi);

	portStr.Format(_T("%u"), port);
	lvi.iSubItem = subItemCount++;
	lvi.pszText = (LPWSTR)(LPCTSTR)portStr;
	ctrl_list_connectedclient.SetItem(&lvi);
}

void CMainFrameServer::OnReceive()
{
	return;
}

int CMainFrameServer::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	CRect ServerRect;
	GetClientRect(&ServerRect);

	int percentPadHorizontal = 2;
	int percentPadVertical = 3;
	int percentButtonHeight = 8;

	ctrl_edit_filepath.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical / 100,
			ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical / 100 + ServerRect.Height() * percentButtonHeight / 100),
		this,
		id_ctrl_edit_filepath);

	ctrl_edit_filename.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight / 100,
			ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100),
		this,
		id_ctrl_edit_filename);

	ctrl_edit_filepath.SetCueBanner(_T("Enter server ip"), 1);

	ctrl_edit_filename.SetCueBanner(_T("Enter port number"), 1);

	ctrl_button_start.Create(
		_T("Start"),
		WS_VISIBLE,
		CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100,
			ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100),
		this,
		id_ctrl_button_start);

	ctrl_button_stop.Create(
		_T("Stop"),
		0,
		CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100,
			ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100),
		this,
		id_ctrl_button_stop);

	ctrl_list_connectedclient.Create(
		LVS_REPORT | WS_BORDER | WS_VISIBLE,
		CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.top + ServerRect.Height() * percentPadVertical * 4 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100,
			ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
			ServerRect.bottom - ServerRect.Height() * percentPadVertical / 100),
		this,
		id_ctrl_list_connectedclient);

	ctrl_list_connectedclient.SetBkColor(0xd4d4d3);

	int nCol = 0;
	CRect rect;
	ctrl_list_connectedclient.GetClientRect(&rect);
	constexpr int baseColumnNumberOfUnit = 9;
	const int baseColumnWidth = rect.Width() / baseColumnNumberOfUnit;
	ctrl_list_connectedclient.SetRedraw(false);
	ctrl_list_connectedclient.InsertColumn(nCol++, _T("Client list"), LVCFMT_LEFT, baseColumnWidth * 3);
	ctrl_list_connectedclient.InsertColumn(nCol++, _T("Ip address"), LVCFMT_LEFT, baseColumnWidth * 3);
	ctrl_list_connectedclient.InsertColumn(nCol++, _T("Port"), LVCFMT_LEFT, baseColumnWidth * 3);
	ctrl_list_connectedclient.SetRedraw(true);
	//ctrl_list_connectedclient.InsertColumn(nCol++, _T("Date modified"), LVCFMT_LEFT, baseColumnWidth * 2);
	//ctrl_list_connectedclient.InsertColumn(nCol++, _T("Date created"), LVCFMT_LEFT, rect.Width() - baseColumnWidth * 8);

	ctrl_edit_filepath.SetFont(&font, 1);

	ctrl_edit_filename.SetFont(&font, 1);

	ctrl_button_start.SetFont(&font, 1);

	ctrl_button_stop.SetFont(&font, 1);

	return 0;
}

void CMainFrameServer::OnButtonClick_button_start()
{
	//Get info from edit box
	CString host = _T(""), portStr = _T("");
	ctrl_edit_filepath.GetWindowText(host);
	ctrl_edit_filename.GetWindowText(portStr);
	if (host.IsEmpty()) {
		//CString info;
		//info.Format(_T("Empty host name"));
		::MessageBox(NULL, _T("Empty host name"), _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}
	if (portStr.IsEmpty()) {
		//CString info;
		//info.Format(_T("Empty host name"));
		::MessageBox(NULL, _T("Empty port"), _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}

	auto port = StrToInt(portStr);
	
	if (!mySock.Create(port,SOCK_STREAM,host))
	{
		::MessageBox(NULL, _T("Failed to create socket"), _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}
	if (!mySock.Listen())
	{
		::MessageBox(NULL, _T("Failed to bind socket"), _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}
	if (!ctrl_button_stop.IsWindowVisible())
	{
		ctrl_button_stop.ShowWindow(SW_SHOW);
	}
	if (ctrl_button_start.IsWindowVisible())
	{
		ctrl_button_start.ShowWindow(SW_HIDE);
	}
}

void CMainFrameServer::OnButtonClick_button_stop()
{
	mySock.Close();
	ctrl_list_connectedclient.DeleteAllItems();
	if (ctrl_button_stop.IsWindowVisible())
	{
		ctrl_button_stop.ShowWindow(SW_HIDE);
	}
	if (!ctrl_button_start.IsWindowVisible())
	{
		ctrl_button_start.ShowWindow(SW_SHOW);
	}
}

void CMainFrameServer::OnSizing(UINT nType, LPRECT newsize)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	CRect ServerRect;
	GetClientRect(&ServerRect);
	CRect r;
	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_filename.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical / 100 + ServerRect.Height() * percentButtonHeight / 100);

	ctrl_edit_filepath.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100);

	ctrl_button_start.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 4 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.bottom - ServerRect.Height() * percentPadVertical / 100);

	ctrl_list_connectedclient.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CMainFrameServer::OnSize(UINT nType, int cx, int cy)
{
	constexpr int percentPadHorizontal = 2;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	CRect ServerRect;
	GetClientRect(&ServerRect);
	CRect r;
	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 2 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_filename.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical / 100 + ServerRect.Height() * percentButtonHeight / 100);

	ctrl_edit_filepath.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 3 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100);

	ctrl_button_start.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(ServerRect.left + ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.top + ServerRect.Height() * percentPadVertical * 4 / 100 + ServerRect.Height() * percentButtonHeight * 2 / 100 + ServerRect.Height() * 8 / 100,
		ServerRect.right - ServerRect.Width() * percentPadHorizontal / 100,
		ServerRect.bottom - ServerRect.Height() * percentPadVertical / 100);

	ctrl_list_connectedclient.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CMainFrameServer::OnGetMinMaxInfo(MINMAXINFO* lpMMI)
{
	lpMMI->ptMinTrackSize.x = 636;
	lpMMI->ptMinTrackSize.y = 404;
}

