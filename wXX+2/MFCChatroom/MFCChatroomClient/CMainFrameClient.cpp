#include "CMainFrameClient.h"

//BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
//{
//	return false;
//}

BEGIN_MESSAGE_MAP(CMainFrameClient, CFrameWnd)
	ON_WM_CREATE()
	ON_WM_GETMINMAXINFO()
	ON_BN_CLICKED(2, OnButtonClick_button_connect) //id_ctrl_button_connect
	ON_BN_CLICKED(6, OnButtonClick_button_disconnect) //id_ctrl_button_disconnect
	ON_BN_CLICKED(5, OnButtonClick_button_send)	//id_ctrl_button_send
	ON_WM_SIZING()
	ON_WM_SIZE()
END_MESSAGE_MAP()

CMainFrameClient::CMainFrameClient()
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
		_T("Chatbox client"),
		WS_OVERLAPPEDWINDOW,
		rectDefault,
		NULL,
		0,
		0,
		0);
}

void CMainFrameClient::AppendLine(CString newtext)
{
	ctrl_edit_chatbox.AppendLine(newtext);
}

int CMainFrameClient::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	CRect clientRect;
	GetClientRect(&clientRect);

	constexpr int percentPadHorizontal = 1;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	ctrl_edit_address.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100),
		this,
		id_ctrl_edit_address);

	ctrl_edit_port.Create(
		WS_VISIBLE | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100),
		this,
		id_ctrl_edit_port);

	ctrl_edit_address.SetCueBanner(_T("Enter server ip"), 1);

	ctrl_edit_port.SetCueBanner(_T("Enter port number"), 1);

	ctrl_button_connect.Create(
		_T("Connect"),
		WS_VISIBLE,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100),
		this,
		id_ctrl_button_connect);

	ctrl_button_disconnect.Create(
		_T("Disconnect"),
		0,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100),
		this,
		id_ctrl_button_disconnect);

	ctrl_edit_chatbox.Create(
		ES_LEFT | ES_AUTOHSCROLL | WS_VISIBLE | ES_READONLY | ES_WANTRETURN | ES_MULTILINE,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical * 2/ 100 - clientRect.Height() * percentButtonHeight / 100),
		this,
		id_ctrl_edit_chatbox);

	ctrl_edit_chatinput.Create(
		ES_LEFT | ES_AUTOHSCROLL | WS_BORDER | WS_VISIBLE | ES_WANTRETURN | ES_MULTILINE,
		CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 2 * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100),
		this,
		id_ctrl_edit_chatinput);

	ctrl_button_send.Create(
		_T("Send"),
		WS_VISIBLE,
		CRect(clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
			clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
			clientRect.bottom - clientRect.Height() * percentPadVertical / 100),
		this,
		id_ctrl_button_send);

	ctrl_edit_chatbox.SetFont(&font, 1);

	ctrl_edit_chatinput.SetFont(&font, 1);

	ctrl_button_send.SetFont(&font, 1);

	ctrl_edit_address.SetFont(&font, 1);

	ctrl_edit_port.SetFont(&font, 1);

	ctrl_button_connect.SetFont(&font, 1);

	ctrl_button_disconnect.SetFont(&font, 1);

	return 0;
}

void CMainFrameClient::OnButtonClick_button_connect()
{
	//Register for callback convenient or direct method call
	mySocket.setListener(this);

	//Get info from edit box
	CString host = _T(""), portStr = _T("");
	ctrl_edit_address.GetWindowText(host);
	ctrl_edit_port.GetWindowText(portStr);
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
	
	if (!mySocket.Create(0, SOCK_STREAM, 0))
	{
		CString info;
		info.Format(_T("Failed to create socket with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}

	if (!mySocket.Connect(host, port)) {
		CString info;
		info.Format(_T("Failed to connect to address %s:%s with error code: %d"), host, portStr, GetLastError());
		mySocket.Close();
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		return;
	}


	//Client hello
	CString _4n0ther_sup3rs3cre1 = _T("hello");
	auto a = _4n0ther_sup3rs3cre1.GetLength();
	mySocket.Send(_4n0ther_sup3rs3cre1,_4n0ther_sup3rs3cre1.GetLength()*2);

	//Swap button
	ctrl_button_connect.ShowWindow(SW_HIDE);
	ctrl_button_disconnect.ShowWindow(SW_SHOW);
}

void CMainFrameClient::OnButtonClick_button_disconnect()
{
	CString bye = _T("bye");
	mySocket.Send(bye, bye.GetLength() * 2);
	mySocket.Close();
	mySocket.m_hSocket = INVALID_SOCKET;
	mySocket.clientname.Empty();

	//Swap button
	ctrl_button_connect.ShowWindow(SW_SHOW);
	ctrl_button_disconnect.ShowWindow(SW_HIDE);
}

void CMainFrameClient::OnButtonClick_button_send()
{
	CString sendString;
	ctrl_edit_chatinput.GetWindowText(sendString);
	sendString = mySocket.clientname + _T(": ") + sendString;
	mySocket.Send(sendString,sendString.GetLength()*2);
	ctrl_edit_chatinput.SetWindowText(_T(""));
}

void CMainFrameClient::Cleanup()
{
	//Swap button
	ctrl_button_connect.ShowWindow(SW_SHOW);
	ctrl_button_disconnect.ShowWindow(SW_HIDE);
}

void CMainFrameClient::OnSizing(UINT nType, LPRECT newsize)
{
	constexpr int percentPadHorizontal = 1;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	CRect clientRect;
	GetClientRect(&clientRect);
	CRect r;
	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_port.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_edit_address.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_connect.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
	ctrl_button_disconnect.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical * 2 / 100 - clientRect.Height() * percentButtonHeight / 100),

	ctrl_edit_chatbox.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 2 * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);
	ctrl_edit_chatinput.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);
	ctrl_button_send.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CMainFrameClient::OnSize(UINT nType, int cx, int cy)
{
	constexpr int percentPadHorizontal = 1;
	constexpr int percentPadVertical = 3;
	constexpr int percentButtonHeight = 8;

	CRect clientRect;
	GetClientRect(&clientRect);
	CRect r;
	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 2 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100);

	ctrl_edit_port.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical / 100 + clientRect.Height() * percentButtonHeight / 100);

	ctrl_edit_address.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 3 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100);

	ctrl_button_connect.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
	ctrl_button_disconnect.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.top + clientRect.Height() * percentPadVertical * 4 / 100 + clientRect.Height() * percentButtonHeight * 2 / 100 + clientRect.Height() * 8 / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical * 2 / 100 - clientRect.Height() * percentButtonHeight / 100),

		ctrl_edit_chatbox.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.left + clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 2 * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);
	ctrl_edit_chatinput.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);

	r = CRect(clientRect.right - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * percentPadHorizontal / 100 - clientRect.Width() * 5 / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100 - clientRect.Height() * percentButtonHeight / 100,
		clientRect.right - clientRect.Width() * percentPadHorizontal / 100,
		clientRect.bottom - clientRect.Height() * percentPadVertical / 100);
	ctrl_button_send.SetWindowPos(0, r.left, r.top, r.Width(), r.Height(), 0);
}

void CMainFrameClient::OnGetMinMaxInfo(MINMAXINFO* lpMMI)
{
	lpMMI->ptMinTrackSize.x = 636;
	lpMMI->ptMinTrackSize.y = 404;
}


