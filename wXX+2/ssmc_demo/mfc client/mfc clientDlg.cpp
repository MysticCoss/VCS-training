// mfc clientDlg.cpp : implementation file
//

#include "stdafx.h"
#include <io.h>
#include "mfc client.h"
#include "mfc clientDlg.h"
#include "ssmcException.h"
#include "ssmcHostInfo.h"
#include "about.h"
#include <malloc.h>
#include <time.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

///////////////////////////////////////////////////////////////////////////////
// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

///////////////////////////////////////////////////////////////////////////////
// log to listbox
#define LOG \
	if (::IsWindow(m_Log.m_hWnd)) \
		m_Log.Printf

///////////////////////////////////////////////////////////////////////////////
// CMfcclientDlg dialog

BEGIN_MESSAGE_MAP(CMfcclientDlg, CDialog)
	//{{AFX_MSG_MAP(CMfcclientDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_SEND, OnSend)
	ON_WM_DESTROY()
	ON_WM_WINDOWPOSCHANGING()
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_CONNECT, OnConnect)
	ON_BN_CLICKED(IDC_DISCONNECT, OnDisconnect)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

///////////////////////////////////////////////////////////////////////////////
// ctor
CMfcclientDlg::CMfcclientDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMfcclientDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMfcclientDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_strServerName = _T("");
	m_pClient = NULL;
	m_dwServerIP = 0;
	m_hWriteMutex = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// dtor
CMfcclientDlg::~CMfcclientDlg()
{
	if (m_pClient)
		delete m_pClient;
	m_pClient = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// DoDataExchange
void CMfcclientDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMfcclientDlg)
	DDX_Control(pDX, IDC_PING, m_Ping);
	DDX_Control(pDX, IDC_SERVERIP, m_ServerIP);
	DDX_Control(pDX, IDC_MESSAGE, m_edtMessage);
	DDX_Control(pDX, IDC_LOG, m_Log);
	//}}AFX_DATA_MAP
	m_strThreadId = _T("");
}

///////////////////////////////////////////////////////////////////////////////
// OnInitDialog
BOOL CMfcclientDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// set right-click menu for listbox
	m_Log.SetContextMenuId(IDR_XLISTBOX);

	// set up spin control
	UDACCEL uda[3];
	uda[0].nInc = 1;
	uda[0].nSec = 0;
	uda[1].nInc = 10;
	uda[1].nSec = 3;
	uda[2].nInc = 100;
	uda[2].nSec = 5;

	CSpinButtonCtrl* pSpin = (CSpinButtonCtrl*) GetDlgItem(IDC_NO_MESSAGES_SPIN);
	ASSERT(pSpin);
	pSpin->SetRange32(1, 999);
	pSpin->SetAccel(3, uda);
	pSpin->SetPos(1);

	CEdit *pEdit = (CEdit *) GetDlgItem(IDC_NO_MESSAGES_EDIT);
	pEdit->LimitText(3);

	VERIFY(CreateSyncObject());

	DWORD dwTid = GetCurrentThreadId();
	m_strThreadId.Format(_T("%08X"), dwTid);

	CString strMessage = _T("");
	strMessage.Format(_T("Hello from client thread %X"), dwTid);
	m_edtMessage.SetWindowText(strMessage);

#ifdef UNICODE
	SetWindowText(_T("Unicode Client"));
#else
	SetWindowText(_T("ANSI Client"));
#endif

	CString s = _T("");
	GetWindowText(s);
	CString strTitle = _T("");
	strTitle.Format(_T("%s - thread = %X"), s, dwTid);
	SetWindowText(strTitle);
	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Starting client..."));

	m_ServerIP.ReadProfileAddress(_T("Server"), _T("IP"), _T("127.0.0.1"));

	return TRUE;  // return TRUE  unless you set the focus to a control
}

///////////////////////////////////////////////////////////////////////////////
// OnSysCommand
void CMfcclientDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

///////////////////////////////////////////////////////////////////////////////
// OnPaint
// If you add a minimize button to your dialog, you will need the code below
// to draw the icon.  For MFC applications using the document/view model,
// this is automatically done for you by the framework.
void CMfcclientDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

///////////////////////////////////////////////////////////////////////////////
// OnQueryDragIcon
// The system calls this to obtain the cursor to display while the user drags
// the minimized window.
HCURSOR CMfcclientDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

///////////////////////////////////////////////////////////////////////////////
// StartClient
BOOL CMfcclientDlg::StartClient()
{
	// Initialize the winsock library
	ssmcTcpSocket::initialize();

	// get client's information (assume neither the name nor the address is given)
	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Retrieve the localHost [CLIENT] name and address:"));

    ssmcHostInfo clientInfo;
	CString clientName = clientInfo.getHostName();
    CString clientIPAddress = clientInfo.getHostIPAddress();

	CString s = _T("");

	LOG(CXListBox::Black, CXListBox::White, 0,
		_T("    Client Name: %s"), clientName);
	LOG(CXListBox::Black, CXListBox::White, 0,
		_T("    Client Address: %s"), clientIPAddress);

	// get server's IP address and name
	CString serverIPAddress = ReadServerConfig();
	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Retrieve the remoteHost [SERVER] name and address:"));

    ssmcHostInfo serverInfo(serverIPAddress, ADDRESS);
	m_strServerName = serverInfo.getHostName();
	LOG(CXListBox::Black, CXListBox::White, 0,
		_T("    Server Name: %s"), m_strServerName);
	LOG(CXListBox::Black, CXListBox::White, 0,
		_T("    Server Address: %s"), serverIPAddress);

    // create the socket for client
	if (m_pClient)
		delete m_pClient;
    m_pClient = new ssmcTcpSocket(PORTNUM);
	ASSERT(m_pClient);
	if (!m_pClient)
	{
		TRACE(_T("ERROR - can't create client socket\n"));
		ASSERT(FALSE);
		return FALSE;
	}

	Dump();

    // connect to the server.
	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Connecting to server [%s] ..."), m_strServerName);

	BOOL bSuccess = FALSE;

	for (int n = 0; n < 3; n++)
	{
		if (m_pClient->connectToServer(serverIPAddress, ADDRESS))
		{
			bSuccess = TRUE;
			break;
		}

		LOG(CXListBox::Red, CXListBox::White, 0,
			_T("connectToServer failed, waiting..."));

		Sleep(500);
	}

	if (bSuccess)
	{
		LOG(CXListBox::Green, CXListBox::White, 0,
			_T("==> Connected to server [%s] ..."), m_strServerName);
	}
	else
	{
		LOG(CXListBox::Red, CXListBox::White, 0,
			_T("==> Failed to connect to server [%s]"), m_strServerName);
	}

	return bSuccess;
}

///////////////////////////////////////////////////////////////////////////////
// OnConnect
void CMfcclientDlg::OnConnect()
{
	if (StartClient())
	{
		GetDlgItem(IDC_SEND)->EnableWindow(TRUE);
		GetDlgItem(IDC_DISCONNECT)->EnableWindow(TRUE);
		GetDlgItem(IDC_CONNECT)->EnableWindow(FALSE);
		SetTimer(1, 5000, NULL);	// start ping timer
	}
	else
	{
		if (m_pClient)
			delete m_pClient;
		m_pClient = NULL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// OnDisconnect
void CMfcclientDlg::OnDisconnect()
{
	TRACE(_T("in CMfcclientDlg::OnDisconnect\n"));

	KillTimer(1);

	GetDlgItem(IDC_SEND)->EnableWindow(FALSE);
	GetDlgItem(IDC_DISCONNECT)->EnableWindow(FALSE);
	GetDlgItem(IDC_CONNECT)->EnableWindow(TRUE);

	if (m_pClient)
	{
		CString strMessage = m_strThreadId;
		strMessage += _T("quit");

		SendMessageToServer(strMessage);
	}

	Sleep(1000);

	if (m_pClient)
		delete m_pClient;
	m_pClient = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// ReadServerConfig
CString CMfcclientDlg::ReadServerConfig()
{
	BYTE fields[4] = { 0 };
	m_ServerIP.GetAddress(fields[0], fields[1], fields[2], fields[3]);
	CString strServerIP = _T("");
	strServerIP.Format(_T("%u.%u.%u.%u"),
		fields[0], fields[1], fields[2], fields[3]);
	return strServerIP;
}

///////////////////////////////////////////////////////////////////////////////
// SendMessages
int CMfcclientDlg::SendMessages(LPCTSTR lpszMessage, int nRepeat)
{
	ASSERT((nRepeat > 0) && (nRepeat < 1000));
	ASSERT(lpszMessage);

	CString strText(lpszMessage);

	if (nRepeat == 1)
	{
		LOG(CXListBox::Fuschia, CXListBox::White, 0, _T("[SEND to %s] %s"),
			m_strServerName, lpszMessage);
	}

	int nSuccessful = 0;

	CString strMessageBody = _T("");
	CString strSentMessage = _T("");

	for (int i = 0; i < nRepeat; i++)
	{
		Lock(INFINITE);		// lock access to client socket

		if (nRepeat == 1)
			strMessageBody = strText;
		else
			strMessageBody.Format(_T("%s %06d"), strText, i+1);

		strSentMessage = m_strThreadId;
		strSentMessage += strMessageBody;

		SendMessageToServer(strSentMessage);

		// receive echo from server

		CString strMessageFromServer = _T("");
		int recvBytes = ReceiveMessageFromServer(strMessageFromServer);

		Unlock();

		TRACE(_T("recvBytes=%d\n"), recvBytes);

		if (recvBytes <= 0)
		{
			LOG(CXListBox::Red, CXListBox::White, 0,
				_T("==> Server [%s] has exited"), m_strServerName);

			OnDisconnect();
			break;
		}
		else
		{
			if (nRepeat == 1)
			{
				LOG(CXListBox::Fuschia, CXListBox::White, 0,
					_T("[RECV from %s]  %s"), m_strServerName, strMessageFromServer);
				TRACE(_T("send=<%s>  recv=<%s> -----\n"), strMessageBody, strMessageFromServer);
			}

			// check that echoed message is same as sent message
			if (strMessageBody == strMessageFromServer)
			{
				if (nRepeat == 1)
				{
					LOG(CXListBox::Green, CXListBox::White, 0,
						_T("==> Echoed message same as sent"));
				}
				nSuccessful++;
			}
			else
			{
				if (nRepeat == 1)
				{
					LOG(CXListBox::Red, CXListBox::White, 0,
						_T("==> Echoed message NOT same as sent"));
				}
			}
		}
	}

	return nSuccessful;
}

///////////////////////////////////////////////////////////////////////////////
// OnSend
void CMfcclientDlg::OnSend()
{
	ASSERT(m_pClient);
	if (!m_pClient)
		return;

	CString strText = _T("");

	m_edtMessage.GetWindowText(strText);
	if (strText.IsEmpty())
		return;

	CString s = _T("");
	CEdit *pEdit = (CEdit *) GetDlgItem(IDC_NO_MESSAGES_EDIT);
	pEdit->GetWindowText(s);
	int nMessages = _ttoi(s);
	if (nMessages == 0)
		nMessages = 1;

	clock_t start = clock();

	int rc = SendMessages(strText, nMessages);

	clock_t stop = clock();

	TRACE(_T("SendMessages returned %d\n"), rc);

	double runtime = (double) (stop - start) / (double) CLOCKS_PER_SEC;
	double msgspersec = (double) nMessages;
	msgspersec /= runtime;
	unsigned int nMsgsPerSec = (unsigned int)msgspersec;

	// check that number of successfully echoed messages
	// is same as number of sent messages
	if (nMessages > 1)
	{
		if (rc == nMessages)
		{
			if (nMsgsPerSec == 0)
			{
				LOG(CXListBox::Green, CXListBox::White, 0,
					_T("==> %d messages successfully sent in < 0.0001 seconds"),
					nMessages);
			}
			else
			{
				LOG(CXListBox::Green, CXListBox::White, 0,
					_T("==> %d messages successfully sent in %.3f seconds (%d messages/sec)"),
					nMessages, runtime, nMsgsPerSec);
			}
		}
		else
		{
			LOG(CXListBox::Red, CXListBox::White, 0,
				_T("==> Not all messages successfully sent"));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dump
void CMfcclientDlg::Dump()
{
	CString str = _T("");

	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Summary of socket settings:"));

	str.Format(_T("    Socket Id: %u     "), m_pClient->getSocketId());
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    port #: %u        "), m_pClient->getPortNumber());
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    debug: %s         "), (m_pClient->getDebug()? _T("true"):_T("false") ));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    reuse addr: %s    "), (m_pClient->getReuseAddr()? _T("true"):_T("false") ));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    keep alive: %s    "), (m_pClient->getKeepAlive()? _T("true"):_T("false") ));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    send buf size: %u "), m_pClient->getSendBufSize());
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    recv buf size: %u "), m_pClient->getReceiveBufSize());
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    blocking: %s      "), (m_pClient->getSocketBlocking()? _T("true"):_T("false") ));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    linger on: %s     "), (m_pClient->getLingerOnOff()? _T("true"):_T("false") ));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T("    linger seconds: %u"), m_pClient->getLingerSeconds());
	LOG(CXListBox::Black, CXListBox::White, 0, str);
	str.Format(_T(" "));
	LOG(CXListBox::Black, CXListBox::White, 0, str);
}

///////////////////////////////////////////////////////////////////////////////
// OnDestroy
void CMfcclientDlg::OnDestroy()
{
	KillTimer(1);

	m_ServerIP.WriteProfileAddress(_T("Server"), _T("IP"));

	OnDisconnect();

	CDialog::OnDestroy();
}

///////////////////////////////////////////////////////////////////////////////
// OnWindowPosChanging
void CMfcclientDlg::OnWindowPosChanging(WINDOWPOS FAR* lpwndpos)
{
	static BOOL bFirstTime = TRUE;

	if (bFirstTime)
	{
		bFirstTime = FALSE;

		if (IsWindow(m_hWnd))
		{
			CRect rect;
			GetWindowRect(&rect);

			// offset initial client position from server window

			int w = GetSystemMetrics(SM_CXSCREEN);

			if (((2*rect.Width()) + 50) < w)
				lpwndpos->x = 50 + rect.Width();
			else
				lpwndpos->x = 200;
			lpwndpos->y = 100;
		}
	}

	CDialog::OnWindowPosChanging(lpwndpos);
}

///////////////////////////////////////////////////////////////////////////////
// OnTimer
void CMfcclientDlg::OnTimer(UINT nIDEvent)
{
	if (m_pClient && m_Ping.GetCheck())
	{
		// send ping message to server

		Lock(INFINITE);		// lock access to client socket

		CString strMessage = m_strThreadId;
		strMessage += _T("ping");

		SendMessageToServer(strMessage);

		CString strMessageFromServer = _T("");
		int recvBytes = ReceiveMessageFromServer(strMessageFromServer);

		if (recvBytes <= 0)
		{
			TRACE(_T("ERROR - server has exited\n"));

			LOG(CXListBox::Red, CXListBox::White, 0,
				_T("==> Server [%s] has exited"), m_strServerName);

			OnDisconnect();
		}

		Unlock();
	}

	CDialog::OnTimer(nIDEvent);
}

///////////////////////////////////////////////////////////////////////////////
// ReceiveMessageFromServer
int CMfcclientDlg::ReceiveMessageFromServer(CString& strMessage)
{
	TRACE(_T("in CMfcclientDlg::ReceiveMessageFromServer\n"));

	ASSERT(m_pClient);

	strMessage = _T("");

	BYTE buf[MAX_RECV_LEN];
	buf[0] = 0;
	buf[1] = 0;

    int recvBytes = m_pClient->receiveMessage(buf, sizeof(buf)-10);

	TRACE(_T("recvBytes=%d\n"), recvBytes);

	BOOL bServerIsUnicode = FALSE;

	if (buf[0] == 0xFF && buf[1] == 0xFE)
		bServerIsUnicode = TRUE;

#ifdef UNICODE	///////////////////////////////////////////////////////////////

	// client is Unicode

	if (bServerIsUnicode)
	{
		// server is Unicode

		TRACE(_T("server is unicode\n"));
		strMessage = (TCHAR *) (LPBYTE) (&buf[2]);
	}
	else
	{
		// server is ANSI

		TRACE(_T("server is ansi\n"));
		TCHAR buf2[MAX_RECV_LEN];
		MultiByteToWideChar(CP_ACP, 0, (LPCSTR)buf, -1, buf2,
			_countof(buf2));
		memcpy(buf, buf2, (_tcslen(buf2)+1)*sizeof(TCHAR));
		strMessage = (TCHAR *) buf;
	}

#else			///////////////////////////////////////////////////////////////

	// client is ANSI

	if (bServerIsUnicode)
	{
		// server is Unicode

		TRACE(_T("server is unicode\n"));
		WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)(LPBYTE)(&buf[2]), -1,
			(char *)buf, sizeof(buf), NULL, NULL);
		strMessage = (char *) buf;
	}
	else
	{
		// server is ANSI

		TRACE(_T("server is ansi\n"));
		strMessage = (char *) buf;
	}

#endif			///////////////////////////////////////////////////////////////

	return recvBytes;
}

///////////////////////////////////////////////////////////////////////////////
// SendMessageToServer
int CMfcclientDlg::SendMessageToServer(LPCTSTR lpszMessage)
{
	TRACE(_T("in CMfcclientDlg::SendMessageToServer\n"));

	ASSERT(lpszMessage && (lpszMessage[0] != _T('\0')));
	ASSERT(m_pClient);

	int len = (_tcslen(lpszMessage)+1)*sizeof(TCHAR) + 2;	// 1 for nul, 2 for BOM
	TRACE(_T("len=%d =====\n"), len);

	BYTE * buf = (BYTE *) _alloca(len+10);

	LPBYTE pMsg = (LPBYTE) lpszMessage;

	// assume Unicode
	buf[0] = 0xFF;
	buf[1] = 0xFE;

	memcpy(&buf[2], pMsg, len-2);	// copy message after BOM
	int i = 0;

#ifndef UNICODE
	i = 2;		// don't transmit BOM if not Unicode
	len -= 2;
#endif

	int rc = m_pClient->sendMessage((LPBYTE)&buf[i], len);

	return rc;
}

///////////////////////////////////////////////////////////////////////////////
// Lock
BOOL CMfcclientDlg::Lock(DWORD dwTimeOut)
{
	ASSERT(m_hWriteMutex);
	if (!m_hWriteMutex)
		return FALSE;

	DWORD dwWaitResult = WaitForSingleObject(m_hWriteMutex, dwTimeOut);
	if (dwWaitResult == WAIT_OBJECT_0)
	{
		return TRUE;
	}
	else
	{
		TRACE(_T("TIMEOUT for thread %X -----\n"), GetCurrentThreadId());
		ASSERT(FALSE);
		return FALSE;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Unlock
BOOL CMfcclientDlg::Unlock()
{
	if (m_hWriteMutex)
		ReleaseMutex(m_hWriteMutex);

	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// CreateSyncObject
BOOL CMfcclientDlg::CreateSyncObject()
{
	// first close any open handles

	if (m_hWriteMutex)
		::CloseHandle(m_hWriteMutex);
	m_hWriteMutex = NULL;

	///////////////////////////////////////////////////////////////////////////
	// Create a mutex object for the socket.
	TCHAR *name = _T("SSMC_CLIENT_MUTEX");

	m_hWriteMutex = CreateMutex(NULL,				// no security attributes
								FALSE,				// initially not owned
								name);				// mutex name

	ASSERT(m_hWriteMutex);
	if (!m_hWriteMutex)
	{
		TRACE(_T("ERROR:  CreateMutex failed\n"));
		return FALSE;
	}

	return TRUE;
}
