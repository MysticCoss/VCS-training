#include "MessageClientHello.h"



MessageClientHello::MessageClientHello(CString clientname, encoding encoding): IMessage(10)
{
	this->clientname = clientname;
	if (encoding == encoding::unicode)
	{
		this->unicode = true;
	}
	else
	{
		this->unicode = false;
	}
}


