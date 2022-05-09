#pragma once
#include <afxsock.h>
class ClientSocket : public CSocket
{
public:
	void Send(CString sendString);
};

