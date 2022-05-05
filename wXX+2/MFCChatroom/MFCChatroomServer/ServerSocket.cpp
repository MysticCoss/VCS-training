#include "ServerSocket.h"

ServerSocket::ServerSocket()
= default;

ServerSocket::~ServerSocket()
= default;

void ServerSocket::OnAccept(int nErrorCode)
{
	CSocket m_Client;
	m_Client.m_hSocket = INVALID_SOCKET;
	if(!Accept(m_Client))
	{
		CString info = _T("");
		info.Format(_T("Error accepting client connection with error code: %d"), GetLastError());
		::MessageBox(NULL, info, _T("Error"), MB_ICONERROR | MB_OK);
	}
	else
	{
		//TODO: Initialize a list of client (dont know how)
		/*clientList.push_back(m_Client);*/
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
