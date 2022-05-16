#include "ClientSocket.h"

void ClientSocket::OnReceive(int nErrorCode)
{
	CSocketFile cFile(this);
	CArchive cArchive(&cFile, CArchive::load);
	//CString recvString = _T("");
	auto a = cArchive.IsBufferEmpty();
	DWORD num=0;
	
	IOCtl(FIONREAD, &num);
	auto buffer = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, num);
	Receive(buffer, num, 0);
	CString recvString((LPSTR)buffer);
	auto jreceive = nlohmann::json::parse(recvString);

	while(!cArchive.IsBufferEmpty())
	{
		CString eyyy;
		cArchive >> eyyy;
		recvString.Append(eyyy);
	}
	::MessageBox(NULL, recvString, _T("Your message!"), MB_OK);
	CSocket::OnReceive(nErrorCode);
}
