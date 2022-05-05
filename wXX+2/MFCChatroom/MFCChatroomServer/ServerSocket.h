#pragma once
#include <vector>

#include "framework.h"
class ServerSocket : public CSocket
{
public:
	ServerSocket();
	virtual ~ServerSocket();
	std::vector<CSocket> clientList;
	void OnAccept(int nErrorCode) override;
	void OnReceive(int nErrorCode) override;
};