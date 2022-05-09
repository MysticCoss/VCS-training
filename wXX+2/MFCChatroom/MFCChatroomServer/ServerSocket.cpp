#include "ServerSocket.h"

SOCKET ServerSocket::clientList[100];
int ServerSocket::clientCount = 0;

//void ServerSocket::Initt(CMainFrameServer* master)
//{
//	myMaster = master;
//}

void ServerSocket::SetListener(IListener* master)
{
	myMaster = master;
}

void ServerSocket::OnAccept(int nErrorCode)
{
	CSocket* m_Client = new CSocket;
	m_Client->m_hSocket = INVALID_SOCKET;
	SOCKADDR thisSockAddr;
	int thisSockAddrLen = sizeof(SOCKADDR);
	if(!Accept(*m_Client,&thisSockAddr,&thisSockAddrLen))
	{
		CString info = _T("");
		info.Format(_T("Error accepting client connection with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_ICONERROR | MB_OK);
	}
	else
	{
		struct sockaddr_in* inaddr_ptr = NULL;
		clientList[clientCount++] = m_Client->m_hSocket;
		if (thisSockAddr.sa_family == AF_INET)
		{
			inaddr_ptr = (struct sockaddr_in*)&thisSockAddr;
		}
		else
		{
			/* not an IPv4 address */
			::MessageBox(NULL, _T("Only Ipv4 supported"), _T("Error"), MB_ICONERROR | MB_OK);
			return;
		}
		auto ipStr = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, 32);
		inet_ntop(AF_INET, (void*)&(inaddr_ptr->sin_addr), (PSTR)ipStr, 32);
		CString ipAddress((LPCSTR)ipStr);
		myMaster->OnAccept(ipAddress, inaddr_ptr->sin_port);
	}
	CSocket::OnAccept(nErrorCode);
}

void ServerSocket::OnReceive(int nErrorCode)
{
	//CSocket::OnReceive(nErrorCode);
	CSocketFile cFile(this);
	CArchive cArchive(&cFile, CArchive::load);
	CString recvString;
	cArchive >> recvString;
	::MessageBox(NULL, recvString, _T("Your message!"), MB_OK);
}

void ServerSocket::Close()
{
	for(int i = 0; i < clientCount; i++)
	{
		if (clientList[i] == INVALID_SOCKET)
		{
			continue;
		}
		auto clientSock = FromHandle(clientList[i]);
		clientSock->Close();
		clientList[i] = INVALID_SOCKET;
	}
	clientCount = 0;
	CSocket::Close();
}
