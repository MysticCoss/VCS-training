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
		clientList[clientCount++] = m_Client->m_hSocket;
		if (thisSockAddr.sa_family == AF_INET) {
			//this is ipv4 address
			struct SOOCKADDR_IN* thisSockAddr_in = (struct SOOCKADDR_IN*)thisSockAddr;
		}
		myMaster->OnAccept();
	}
	CSocket::OnAccept(nErrorCode);
}

void ServerSocket::OnReceive(int nErrorCode)
{
	CSocket::OnReceive(nErrorCode);
	CSocketFile cFile(this);
	CArchive cArchive(&cFile, CArchive::store);
	CString recvString;
	cArchive >> recvString;
	::MessageBox(NULL, recvString, _T("Your message!"), MB_OK);
}
