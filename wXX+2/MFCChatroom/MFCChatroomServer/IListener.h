#pragma once

class IListener
{
public:
	virtual void OnAccept(CString ipAddress, USHORT port) = 0;
	virtual void OnReceive() = 0;
};