#include "ClientSocket.h"

void ClientSocket::Send(CString sendString)
{
	CSocketFile cFile(this);
	CArchive cArchive(&cFile, CArchive::store);
	cArchive << sendString;
	::MessageBox(NULL, sendString, _T("Your message!"), MB_OK);
}
