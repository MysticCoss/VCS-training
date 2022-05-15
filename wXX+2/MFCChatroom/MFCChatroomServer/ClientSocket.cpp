#include "ClientSocket.h"

void ClientSocket::OnReceive(int nErrorCode)
{
	CSocketFile cFile(this);
	CArchive cArchive(&cFile, CArchive::load);
	CString recvString = _T("");
	auto a = cArchive.IsBufferEmpty();
	DWORD num;
	IOCtl(FIONREAD, &num);
	while(!cArchive.IsBufferEmpty())
	{
		CString eyyy;
		cArchive >> eyyy;
		recvString.Append(eyyy);
	}
	::MessageBox(NULL, recvString, _T("Your message!"), MB_OK);
	CSocket::OnReceive(nErrorCode);
}
