#pragma once
#include "framework.h"
#include <chrono>

class ClientSocket : public CSocket
{
public:
	CString name;
	void OnReceive(int nErrorCode) override;
};
