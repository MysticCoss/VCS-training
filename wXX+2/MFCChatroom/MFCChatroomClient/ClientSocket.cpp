#include "ClientSocket.h"

void ClientSocket::setListener(IListener* listener)
{
	myMaster = listener;
}

void ClientSocket::OnReceive(int nErrorCode)
{
	DWORD num = 0;
	IOCtl(FIONREAD, &num);
	auto buff3r = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, num);
	Receive(buff3r, num);
	CString receivStr((LPWSTR)buff3r);

	if (receivStr.Find(_T("hello ")) == 0 && clientname.IsEmpty())
	{
		//client hello packet
		clientname = receivStr.Right(receivStr.GetLength() - 6);
		//Print notification
		CString ps = _T("Client ") + clientname + _T(" connected to server\n");
		myMaster->Append(ps);
	}
}
