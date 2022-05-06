#pragma once

class IListener
{
public:
	virtual void OnAccept() = 0;
	virtual void OnReceive() = 0;
};