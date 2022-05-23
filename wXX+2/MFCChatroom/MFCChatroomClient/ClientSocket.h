#pragma once
#include "framework.h"
#include "IListener.h"

class ClientSocket : public CSocket
{
public:
	IListener* myMaster;
	CString clientname;
	void Cleanup();
	void OnReceive(int nErrorCode) override;
	void setListener(IListener* listener);
};

