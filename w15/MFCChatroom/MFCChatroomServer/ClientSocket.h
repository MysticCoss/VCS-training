#pragma once
#include "framework.h"
#include <chrono>
#include "IListener.h"

class ClientSocket : public CSocket
{
private:
	IListener* myMaster;
public:
	CString name;
	CString address;
	USHORT port;
	void setListener(IListener* listener);
	void OnReceive(int nErrorCode) override;
};
