#pragma once
#include "IMessage.h"
#include "framework.h"

enum encoding
{
	unicode,
	other
};

class MessageClientHello : public IMessage
{
public:
	CString clientname;
	bool unicode;
	MessageClientHello(CString clientname, encoding encoding);
};

