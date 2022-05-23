#pragma once
#include "MessageClientHello.h"
inline void to_json(nlohmann::json& j, const MessageClientHello& msg)
{
	j = json{ {"op",msg.op},{"clientname", std::wstring(msg.clientname)},{"unicode", msg.unicode}};
}

inline void from_json(const nlohmann::json& j, MessageClientHello& msg)
{
	j.at("op").get_to(msg.op);
	std::wstring ws;
	j.at("clientname").get_to(ws);
	msg.clientname = CString(ws);
	j.at("op").get_to(msg.op);
}