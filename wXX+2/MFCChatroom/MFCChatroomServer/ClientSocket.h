#pragma once
#include "framework.h"
#include <nlohmann/json.hpp>

class ClientSocket : public CSocket
{
public:
	void OnReceive(int nErrorCode) override;
};
