#ifndef SSMCTHREADARGUMENT_H
#define SSMCTHREADARGUMENT_H

#include "ssmcThread.h"

class ssmcTcpSocket;

const int MAX_NUM_CLIENTS = 100;

class ssmcThreadData
{
public:
	ssmcThreadData(ssmcTcpSocket* pSocket, LPCTSTR strName);
	~ssmcThreadData() ;

public:
	ssmcTcpSocket *	getClientConnect()		{ return socketConnection; }
	TCHAR *			getHostName()			{ return hostName; }
	void			setHostName(const TCHAR * lpszHostName)	{ _tcscpy(hostName, lpszHostName); }
	ssmcThread *	getThreadHandle()		{ return threadHandle; }
	void			setThreadHandle(ssmcThread * pThread)	{ threadHandle = pThread; }
	bool			getSignalToEnd()		{ return signalToEnd; }
	void			setSignalToEnd(bool f)	{ signalToEnd = f; }

protected:
	ssmcTcpSocket *	socketConnection;		// the connecting socket to the client
	TCHAR			hostName[MAX_PATH*4];	// the name of the client
	bool			bIsClient;
	ssmcThread *	threadHandle;
	bool			signalToEnd;
};

///////////////////////////////////////////////////////////////////////////////

class ssmcClientThreadData : public ssmcThreadData
{
public:
	ssmcClientThreadData(ssmcTcpSocket* pSocket, LPCTSTR cName);
	~ssmcClientThreadData() ;

	bool IsClientFinished() { return bClientIsFinished; }
	void SetClientFinished(bool bFinished) { bClientIsFinished = bFinished; }

protected:
	bool	bClientIsFinished;
};

///////////////////////////////////////////////////////////////////////////////

class ssmcServerThreadData : public ssmcThreadData
{
public:
	ssmcServerThreadData(ssmcTcpSocket* pSocket, LPCTSTR cName);
	~ssmcServerThreadData() ;

public:
	bool addClient(ssmcClientThreadData*);
	bool removeClient(ssmcClientThreadData*);
	int getNumClients() { return numOfConnectedClients; }

	ssmcClientThreadData* getClientData(int);

protected:
    int numOfConnectedClients;
	ssmcClientThreadData * clientData[MAX_NUM_CLIENTS];
};

#endif //SSMCTHREADARGUMENT_H
