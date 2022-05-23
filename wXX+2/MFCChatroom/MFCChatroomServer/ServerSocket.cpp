#include "ServerSocket.h"

ClientSocket* ServerSocket::clientList[100];
int ServerSocket::clientCount = 0;
bool ServerSocket::available[100];


ServerSocket::ServerSocket() : CSocket()
{
	for(int i=0;i<100;i++)
	{
		clientList[i] = new ClientSocket();
		clientList[i]->m_hSocket = INVALID_SOCKET;
		available[i] = true;
	}
	
}

void ServerSocket::SetListener(IListener* master)
{
	myMaster = master;
}

void ServerSocket::OnAccept(int nErrorCode)
{
	//find a free socket
	int i = 0;
	for (;i<100;i++)
	{
		if (clientList[i]->m_hSocket == INVALID_SOCKET)
		{
			break;
		}
	}

	SOCKADDR thisSockAddr;
	int thisSockAddrLen = sizeof(SOCKADDR);
	if(!Accept(*clientList[i],&thisSockAddr,&thisSockAddrLen))
	{
		CString info = _T("");
		info.Format(_T("Error accepting client connection with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_ICONERROR | MB_OK);
	}
	else
	{
		struct sockaddr_in* inaddr_ptr = NULL;
		//clientList[clientCount++] = m_Client->m_hSocket;
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
		auto port = inaddr_ptr->sin_port;
		clientList[i]->address = ipAddress;
		clientList[i]->port = port;
		clientList[i]->setListener(myMaster);

		clientCount++;
		clientCount = clientCount % 100;

		myMaster->OnAccept(ipAddress, port);
	}
	CSocket::OnAccept(nErrorCode);
}

void ServerSocket::OnReceive(int nErrorCode)
{
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
		if (clientList[i]->m_hSocket == INVALID_SOCKET)
		{
			continue;
		}
		//auto clientSock = FromHandle(clientList[i]);

		clientList[i]->Close();
		delete clientList[i];
	}
	clientCount = 0;
	CAsyncSocket::Close();
}
