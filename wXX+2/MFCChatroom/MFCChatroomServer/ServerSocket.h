#pragma once
#include "framework.h"
#include "IListener.h"

class ServerSocket : public CSocket
{
private:
	IListener* myMaster;
public:
	static SOCKET clientList[100];
	static int clientCount;
	void SetListener(IListener* master);
	void OnAccept(int nErrorCode) override;
	void OnReceive(int nErrorCode) override;
	void Close() override;
};
