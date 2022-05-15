#pragma once
#include "ClientSocket.h"
#include "framework.h"
#include "IListener.h"

class ServerSocket : public CSocket
{
private:
	IListener* myMaster;
public:
	ServerSocket();
	static ClientSocket* clientList[100];
	static int clientCount;
	void SetListener(IListener* master);
	void Close() override;
protected:
	void OnAccept(int nErrorCode) override;
	void OnReceive(int nErrorCode) override;
};
