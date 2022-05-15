#pragma once
#include "framework.h"

class ClientSocket : public CSocket
{
public:
	void OnReceive(int nErrorCode) override;
};
