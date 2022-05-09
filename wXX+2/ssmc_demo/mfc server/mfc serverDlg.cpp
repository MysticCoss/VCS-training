// mfc serverDlg.cpp : implementation file
//

#include "stdafx.h"
#include "mfc server.h"
#include "mfc serverDlg.h"
#include "about.h"
#include "ssmcSocket.h"
#include "ssmcException.h"
#include "ssmcHostInfo.h"
#include "ssmcThread.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

int g_nMessagesReceived = 0;

///////////////////////////////////////////////////////////////////////////////
// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

CXListBox * m_pLog = NULL;

///////////////////////////////////////////////////////////////////////////////
// log to listbox
#define LOG \
	if (m_pLog && ::IsWindow(m_pLog->m_hWnd)) \
		m_pLog->Printf

///////////////////////////////////////////////////////////////////////////////
// CMfcserverDlg dialog

BEGIN_MESSAGE_MAP(CMfcserverDlg, CDialog)
	//{{AFX_MSG_MAP(CMfcserverDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_TIMER()
	ON_WM_WINDOWPOSCHANGING()
	ON_BN_CLICKED(IDC_STARTCLIENT, OnStartclient)
	ON_WM_DESTROY()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

///////////////////////////////////////////////////////////////////////////////
// ctor
CMfcserverDlg::CMfcserverDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMfcserverDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMfcserverDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_pServerData = NULL;
	m_pServer = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// dtor
CMfcserverDlg::~CMfcserverDlg()
{
	if (m_pServerData)
		delete m_pServerData;
	m_pServerData = NULL;
	if (m_pServer)
		delete m_pServer;
	m_pServer = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// DoDataExchange
void CMfcserverDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMfcserverDlg)
	DDX_Control(pDX, IDC_NUMMESSAGES, m_NumMessagesReceived);
	DDX_Control(pDX, IDC_NUMCLIENTS, m_NumClients);
	DDX_Control(pDX, IDC_LOG, m_Log);
	//}}AFX_DATA_MAP
}

///////////////////////////////////////////////////////////////////////////////
// OnInitDialog
BOOL CMfcserverDlg::OnInitDialog()
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

#ifdef UNICODE
	SetWindowText(_T("Unicode Server"));
#else
	SetWindowText(_T("ANSI Server"));
#endif

	m_NumClients.SetWindowText(_T("0"));
	m_NumMessagesReceived.SetWindowText(_T("0"));

	m_pLog = &m_Log;

	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Starting server..."));

	Startup();

	return TRUE;  // return TRUE  unless you set the focus to a control
}

///////////////////////////////////////////////////////////////////////////////
// OnSysCommand
void CMfcserverDlg::OnSysCommand(UINT nID, LPARAM lParam)
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
void CMfcserverDlg::OnPaint()
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
HCURSOR CMfcserverDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

///////////////////////////////////////////////////////////////////////////////
// ClientThread
unsigned WINAPI ClientThread(LPVOID threadInfo)
{
	// this structure will contain all the data this callback will work on
    ssmcClientThreadData* clientData = (ssmcClientThreadData*)threadInfo;
	if (clientData == NULL)
	{
		TRACE(_T("ERROR - clientData is NULL\n"));
		ASSERT(FALSE);
		return 0;
	}

	// get the client connection: receiving messages from client and
	// sending messages to the client will all be done by using
	// this client connection
	ssmcTcpSocket* clientConnection = clientData->getClientConnect();
	if (clientConnection == NULL)
	{
		TRACE(_T("ERROR - clientConnection is NULL\n"));
		ASSERT(FALSE);
		return 0;
	}

	CString clientName = clientData->getHostName();
	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Starting ClientThread for %s"),
		clientName.Left(clientName.GetLength()-9));

	// the server is communicating with this client here
	while (1)
	{
		CString messageFromClient = _T("");

		// receive from the client

		BYTE buf[MAX_RECV_LEN*2];
		buf[0] = 0;
		buf[1] = 0;

        int numBytes = clientConnection->receiveMessage(buf, sizeof(buf));
		if (numBytes == -99)
		{
			TRACE(_T("receiveMessage returned -99\n"));

			LOG(CXListBox::Black, CXListBox::White, 0,
				_T("receiveMessage returned -99 for %s"), clientName);

			break;
		}

		int index = 0;
		BOOL bClientIsUnicode = FALSE;
		if (buf[0] == 0xFF && buf[1] == 0xFE)
		{
			// client is Unicode
			bClientIsUnicode = TRUE;
		}

		TCHAR buf2[MAX_RECV_LEN];

#ifdef UNICODE	///////////////////////////////////////////////////////////////

		// server is Unicode

		if (bClientIsUnicode)
		{
			// client is Unicode
			index = 2;
		}
		else
		{
			// client is ANSI - convert ANSI to Unicode

			MultiByteToWideChar(CP_ACP, 0, (LPCSTR)buf, -1, buf2,
				_countof(buf2));
			memcpy(buf, buf2, (_tcslen(buf2)+1)*sizeof(TCHAR));
		}

#else			///////////////////////////////////////////////////////////////

		// server is ANSI

		if (bClientIsUnicode)
		{
			// client is Unicode - convert Unicode to ANSI

			char * cp = (char *) &buf[2];	// skip BOM

			WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)cp, -1, buf2,
				sizeof(buf2), NULL, NULL);

			memcpy(buf, buf2, strlen(buf2)+1);
		}
		else
		{
			// client is ANSI
		}

#endif			///////////////////////////////////////////////////////////////

		messageFromClient = (TCHAR *) (&buf[index]);

		CString s = _T("");
		s.Format(_T("messageFromClient = <%s>"), messageFromClient);
		TRACE(_T("%s\n"), s);

		if (!messageFromClient.IsEmpty())
		{
			// insert thread id into client name if this is first message from client
			int index = clientName.Find(_T("~~~~~~~~"));
			if (index != -1)
			{
				clientName = clientName.Left(index);
				CString strTid = messageFromClient.Left(8);
				clientName += strTid;
				clientData->setHostName(clientName);
				s.Format(_T("Setting client hostname to <%s>"), clientName);
				LOG(CXListBox::Blue, CXListBox::White, 0, _T("%s"), s);
			}

			messageFromClient = messageFromClient.Right(messageFromClient.GetLength()-8);

			s.Format(_T("[RECV from %s] %s"), clientName, messageFromClient);
			LOG(CXListBox::Fuschia, CXListBox::White, 0, _T("%s"), s);
			TRACE(_T("%s\n"), s);
		}

		if (!messageFromClient.IsEmpty())
		{
			// check if the client wants to disconnect
			if (messageFromClient.GetLength() > 0)
			{
				if (messageFromClient.CompareNoCase(_T("quit")) == 0)
				{
					LOG(CXListBox::Blue, CXListBox::White, 0, _T("%s"),
						_T("Quit received"));
					break;
				}
				else // echo to the client
				{
					CString strMessageToClient = messageFromClient;
					s.Format(_T("[SEND echo to %s] %s"), clientName, strMessageToClient);
					LOG(CXListBox::Fuschia, CXListBox::White, 0, _T("%s"), s);
					int n = strMessageToClient.GetLength();
					TRACE(_T("strMessageToClient.GetLength()=%d -----\n"), n);

					int len = 0;

#ifdef UNICODE	///////////////////////////////////////////////////////////////

					// server is Unicode

					if (bClientIsUnicode)
					{
						// client is Unicode

						buf[0] = 0xFF;
						buf[1] = 0xFE;
						len = (strMessageToClient.GetLength()+1)*sizeof(TCHAR);
						memcpy(&buf[2], (LPBYTE)(LPCTSTR)strMessageToClient, len);
						len += 2;	// 2 for BOM
						TRACE(_T("client is unicode:  len=%d\n"), len);
					}
					else
					{
						// client is ANSI

						// len = no. of chars (includes nul)
						len = WideCharToMultiByte(CP_ACP, 0, (LPCTSTR)strMessageToClient, -1,
							(char *)buf, sizeof(buf), NULL, NULL);
						TRACE(_T("client is ansi:  len=%d\n"), len);
					}

#else			///////////////////////////////////////////////////////////////

					// server is ANSI

					if (bClientIsUnicode)
					{
						// client is Unicode

						buf[0] = 0xFF;
						buf[1] = 0xFE;
						// len = no. of wide chars (includes nul)
						len = MultiByteToWideChar(CP_ACP, 0, (LPCSTR)strMessageToClient, -1,
							(LPWSTR)(LPBYTE)&buf[2], _countof(buf)-2);
						TRACE(_T("MultiByteToWideChar returned len=%d\n"), len);
						len *= 2;	// no. of bytes
						len += 2;	// 2 for BOM
						TRACE(_T("client is unicode:  len=%d\n"), len);
					}
					else
					{
						// client is ANSI

						strcpy((char *) buf, strMessageToClient);
						len = strMessageToClient.GetLength() + 1;
						TRACE(_T("client is ansi:  len=%d\n"), len);
					}

#endif			///////////////////////////////////////////////////////////////

					// echo message back to client
					clientConnection->sendMessage(buf, len);

					g_nMessagesReceived++;
				}
			}
		}
    }

	// if we reach here, this session with the client is done,
	// so we set the flag on this thread to inform the main
	// control that this session is finished

	clientData->SetClientFinished(true);

	LOG(CXListBox::Blue, CXListBox::White, 0,
		_T("Exiting ClientThread for %s"), clientName);

	return 1;
}

///////////////////////////////////////////////////////////////////////////////
// ServerThread
unsigned WINAPI ServerThread(LPVOID threadInfo)
{
	LOG(CXListBox::Blue, CXListBox::White, 0, _T("%s"),
		_T("Starting ServerThread"));

	// this structure will contain all the data this callback will work on
    ssmcServerThreadData * serverData = (ssmcServerThreadData*)threadInfo;

	if (serverData == NULL)
	{
		TRACE(_T("ERROR - serverData is NULL\n"));
		ASSERT(FALSE);
		return 0;
	}

	// get the server socket
	ssmcTcpSocket* pSocket = serverData->getClientConnect();
	if (pSocket == NULL)
	{
		TRACE(_T("ERROR - pSocket is NULL\n"));
		return 0;
	}

	CString serverName = serverData->getHostName();

	// bind the server to the socket
    pSocket->bindSocket();
	TRACE(_T("server finished binding process... \n"));

	// server starts to wait for client calls
	pSocket->listenToClient();
	TRACE(_T("server is waiting for clients ... \n"));

	// server starts to listen, and generates a thread to
	// handle each client

	ssmcClientThreadData * pClientData = NULL;
	ssmcThread * pClientThread = NULL;

	int currNumOfClients = 0;

	while (1)
	{
		if (!pSocket->IsSocketOpen())
		{
			TRACE(_T("server socket is closed\n"));
			break;
		}

		// wait to accept a client connection.
		// processing is suspended until the client connects
		ssmcTcpSocket* client = NULL;

		TCHAR wclientName[MAX_PATH*4] = { _T('\0') };
		client = pSocket->acceptClient(wclientName);
		if (client == NULL)
		{
			TRACE(_T("ERROR client == NULL\n"));
			continue;
		}

		CString s = _T("");
		s.Format(_T("==> A client from [%s] has connected!"), wclientName);
		LOG(CXListBox::Green, CXListBox::White, 0, _T("%s"), s);
        TRACE(_T("%s\n"), s);

		_tcscat(wclientName, _T(":~~~~~~~~"));	// thread id of client will be inserted when
												// first message is received from client

		int nClients = serverData->getNumClients();

		s.Format(_T("nClients=%d  currNumOfClients=%d"),
			nClients, currNumOfClients);
        TRACE(_T("%s\n"), s);

		// for this client, generate a thread to handle it
		if (nClients < MAX_NUM_CLIENTS-1)
		{
			pClientData = new ssmcClientThreadData(client, wclientName);
			ASSERT(pClientData);

			pClientThread = new ssmcThread(ClientThread, (void*)pClientData);
			ASSERT(pClientThread);

			if (pClientData && pClientThread)
			{
				serverData->addClient(pClientData);
				pClientData->setThreadHandle(pClientThread);
				pClientThread->execute();
				currNumOfClients++;
			}
		}
	}

	TRACE(_T("exiting ServerThread\n"));

    return 1;
}

///////////////////////////////////////////////////////////////////////////////
// Startup
BOOL CMfcserverDlg::Startup()
{
	// initialize the winsock library
	ssmcTcpSocket::initialize();

	// create the server: local host will be used as the server, let us
	// first use ssmcHostInfo class to show the name and IP address
	// of the local host
	TRACE(_T("Retrieve the local host name and address:\n"));

    ssmcHostInfo serverInfo;
	CString serverName = serverInfo.getHostName();
    CString serverIPAddress = serverInfo.getHostIPAddress();
	TRACE(_T("my localhost (server) information:\n"));
	TRACE(_T("	Name:    %s\n"), serverName);
    TRACE(_T("	Address: %s\n"), serverIPAddress);

	// open server socket on the local host
	ASSERT(m_pServer == NULL);
	m_pServer = new ssmcTcpSocket(PORTNUM);
	ASSERT(m_pServer);
	if (!m_pServer)
		return FALSE;
	m_pServer->setReuseAddr(1);

	BOOL bSuccess = FALSE;

	// create a thread to implement server process: listening to the socket,
	// accepting client calls and communicating with clients. This will free the
	// main control to do other process.
	m_pServerData = new ssmcServerThreadData(m_pServer, serverName);

	if (m_pServerData)
	{
		ssmcThread* pServerThread = new ssmcThread(ServerThread, (void*)m_pServerData);

		if (pServerThread)
		{
			m_pServerData->setThreadHandle(pServerThread);
			pServerThread->execute();
			SetTimer(1, 500, NULL);
			bSuccess = TRUE;
		}
		else
		{
			ASSERT(FALSE);
		}
	}
	else
	{
		ASSERT(FALSE);
	}

	Dump();

	return bSuccess;
}

///////////////////////////////////////////////////////////////////////////////
// OnTimer
void CMfcserverDlg::OnTimer(UINT nIDEvent)
{
	// display messages received
	CString s = _T("");
	s.Format(_T("%d"), g_nMessagesReceived);
	m_NumMessagesReceived.SetWindowText(s);
	
	// check how many clients are active

	if ((nIDEvent == 1) && m_pServer && m_pServer->IsSocketOpen())
	{
		//
		// === do whatever you need to do here ===
		//

		ssmcHostInfo serverInfo;
		CString serverName = serverInfo.getHostName();
		CString serverIPAddress = serverInfo.getHostIPAddress();

		int i = 0;
		int currNumOfClients = 0;

		for (i = 0; i < MAX_NUM_CLIENTS; i++)
		{
			ssmcClientThreadData* clientData = m_pServerData->getClientData(i);
			if (clientData)
			{
				currNumOfClients++;
			}
		}

		for (i = 0; i < MAX_NUM_CLIENTS; i++)
		{
			ssmcClientThreadData* clientData = m_pServerData->getClientData(i);
			if (clientData && clientData->IsClientFinished())
			{
				clientData->setSignalToEnd(true);

				CString strHostName = clientData->getHostName();
				TRACE(_T("         %s has disconnected =====\n"), strHostName);
				LOG(CXListBox::Red, CXListBox::White, 0,
					_T("==> Client %s has disconnected\n"), strHostName);

				m_pServerData->removeClient(clientData);

				currNumOfClients--;
				if (currNumOfClients < 0)
					currNumOfClients = 0;
			}
		}

		CString s = _T("");
		s.Format(_T("%d"), currNumOfClients);
		m_NumClients.SetWindowText(s);

		int n = m_pServerData->getNumClients();
		ASSERT(n == currNumOfClients);
	}

	CDialog::OnTimer(nIDEvent);
}

///////////////////////////////////////////////////////////////////////////////
// Dump
void CMfcserverDlg::Dump()
{
	CString str = _T("");

	LOG(CXListBox::Blue, CXListBox::White, 0, _T("%s"),
		_T("Summary of socket settings:"));

	str.Format(_T("    Socket Id: %u     "), m_pServer->getSocketId());
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    port #: %u        "), m_pServer->getPortNumber());
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    debug: %s         "), (m_pServer->getDebug()? _T("true"):_T("false")));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    reuse addr: %s    "), (m_pServer->getReuseAddr()? _T("true"):_T("false")));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    keep alive: %s    "), (m_pServer->getKeepAlive()? _T("true"):_T("false")));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    send buf size: %u "), m_pServer->getSendBufSize());
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    recv buf size: %u "), m_pServer->getReceiveBufSize());
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    blocking: %s      "), (m_pServer->getSocketBlocking()? _T("true"):_T("false")));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    linger on: %s     "), (m_pServer->getLingerOnOff()? _T("true"):_T("false")));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T("    linger seconds: %u"), m_pServer->getLingerSeconds());
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
	str.Format(_T(" "));
	LOG(CXListBox::Black, CXListBox::White, 0, _T("%s"), str);
}

///////////////////////////////////////////////////////////////////////////////
// OnWindowPosChanging
void CMfcserverDlg::OnWindowPosChanging(WINDOWPOS FAR* lpwndpos)
{
	static BOOL bFirstTime = TRUE;

	if (bFirstTime)
	{
		bFirstTime = FALSE;

		// offset initial client position from server window
		lpwndpos->x = 50;
		lpwndpos->y = 100;
	}

	CDialog::OnWindowPosChanging(lpwndpos);
}

///////////////////////////////////////////////////////////////////////////////
// OnStartclient
void CMfcserverDlg::OnStartclient()
{
	TCHAR szPath[MAX_PATH * 2] = { _T('\0') };
	GetModuleFileName(NULL, szPath, _countof(szPath) - 2);
	TCHAR * cp = _tcsrchr(szPath, _T('\\'));
	if (cp)
		*(cp+1) = _T('\0');

	CString strPath = _T('\"');
	strPath += szPath;
#ifdef UNICODE
	strPath += _T("clientU.exe");
#else
	strPath += _T("clientA.exe");
#endif
	strPath += _T('\"');
	TRACE(_T("strPath=<%s>\n"), strPath);

	STARTUPINFO si;
	PROCESS_INFORMATION pi;

	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));

	CreateProcess(NULL, (LPTSTR)(LPCTSTR)strPath, NULL, NULL, TRUE,
		NORMAL_PRIORITY_CLASS, NULL, NULL, &si, &pi);
}

///////////////////////////////////////////////////////////////////////////////
// OnDestroy
void CMfcserverDlg::OnDestroy()
{
	KillTimer(1);

	m_pLog = NULL;

	if (m_pServer)
		 m_pServer->closeSocket();

	Sleep(1000);

	CDialog::OnDestroy();
}
