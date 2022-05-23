#pragma once
#include <nlohmann/json.hpp>
#include "framework.h"
using json = nlohmann::json;

class IMessage
{
public:
	IMessage(int op);

	int op;			//message opcode

	void to_json(json& j, const IMessage& msg);
	void from_json(const json& j, IMessage& msg);
};

