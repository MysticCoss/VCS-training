#include "IMessage.h"

IMessage::IMessage(int op)
{
	this->op = op;
}

void IMessage::to_json(nlohmann::json& j, const IMessage& msg)
{
	j = json{{"op",msg.op}};
}

void IMessage::from_json(const nlohmann::json& j, IMessage& msg)
{
	j.at("op").get_to(msg.op);
}
