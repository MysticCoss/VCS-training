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
	CString recvString((LPWSTR)buffer);
	if (recvString == _T("hello") && name.IsEmpty())
	{
		//assign client name
		auto a = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::system_clock::now().time_since_epoch()).count();
		name.Format(_T("hello client_%ld"), a);
		this->Send(name, name.GetLength()*2);
	}
	::MessageBox(NULL, recvString, _T("Your message from client"), MB_OK);
	CSocket::OnReceive(nErrorCode);
}