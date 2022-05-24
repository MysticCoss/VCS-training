#pragma once

class IListener
{
public:
	virtual void OnAccept(CString ipAddress, USHORT port) = 0;
	virtual void OnReceive(CString echoString) = 0;
	virtual void OnClientDisconnect(CString address, USHORT port) = 0;
};