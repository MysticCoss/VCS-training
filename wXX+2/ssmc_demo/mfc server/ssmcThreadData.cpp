// ssmcThreadData.cpp
//
// This code is based on the article by Liyang Yu,
//     "Single Server With Multiple Clients : a Simple C++ Implementation"
//     http://www.codeproject.com/internet/singleServerMulClient.asp
//
// Modified by Hans Dietrich (hdietrich@gmail.com), 2005 January 26 
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// include the following line if compiling an MFC app
#include "stdafx.h"
///////////////////////////////////////////////////////////////////////////////

#ifndef _MFC_VER

#include <windows.h>
#include <stdio.h>
#include <crtdbg.h>
#include <tchar.h>
#include <stddef.h>
#define TRACE ((void) 0)
#pragma warning(disable : 4127)		// conditional expression is constant
									// (needed for _ASSERTE)
#pragma message("    compiling for Win32")
#else
#pragma message("    compiling for MFC")
#endif

#include "ssmcThreadData.h"

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// ssmcThreadData
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcThreadData::ssmcThreadData(ssmcTcpSocket* pSocket, 
							   LPCTSTR strName)
	:
	socketConnection(pSocket),
	signalToEnd(false),
	bIsClient(false),
	threadHandle(0)
{
	TRACE(_T("in ssmcThreadData::ssmcThreadData\n"));

	_ASSERTE(pSocket);
	_ASSERTE(strName);

	hostName[0] = _T('\0');
	if (strName)
		_tcscpy(hostName, strName);
}

///////////////////////////////////////////////////////////////////////////////
// dtor
ssmcThreadData::~ssmcThreadData()
{
	if (threadHandle)
		delete threadHandle;
	threadHandle = 0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// ssmcClientThreadData
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcClientThreadData::ssmcClientThreadData(ssmcTcpSocket* pSocket, 
										   LPCTSTR strName)
	:
	ssmcThreadData(pSocket, strName),
	bClientIsFinished(false)
{
	TRACE(_T("in ssmcClientThreadData::ssmcClientThreadData\n"));

	bIsClient = true;
}

///////////////////////////////////////////////////////////////////////////////
// dtor
ssmcClientThreadData::~ssmcClientThreadData()
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// ssmcServerThreadData
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcServerThreadData::ssmcServerThreadData(ssmcTcpSocket* pSocket, 
										   LPCTSTR strName)
	: 
	ssmcThreadData(pSocket, strName),
	numOfConnectedClients(0)
{
	TRACE(_T("in ssmcServerThreadData::ssmcServerThreadData\n"));

	for (int i = 0; i < MAX_NUM_CLIENTS; i++)
		clientData[i] = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// dtor
ssmcServerThreadData::~ssmcServerThreadData()
{
	for (int i = 0; i < MAX_NUM_CLIENTS; i++)
	{
		ssmcThreadData *pArgument = clientData[i];
		if (pArgument)
		{
			delete pArgument;
			clientData[i] = NULL;
			numOfConnectedClients--;
		}
	}

	if (numOfConnectedClients < 0)
		numOfConnectedClients = 0;
}

///////////////////////////////////////////////////////////////////////////////
// addClient
bool ssmcServerThreadData::addClient(ssmcClientThreadData* argument)
{
	TRACE(_T("in ssmcServerThreadData::addClient\n"));

	bool ok = false;

	if (argument)
	{
		for (int i = 0; i < MAX_NUM_CLIENTS; i++)
		{
			if (clientData[i] == NULL)
			{
				clientData[i] = argument;
				numOfConnectedClients++;
				ok = true;
				break;
			}
		}
	}
	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// removeClient
bool ssmcServerThreadData::removeClient(ssmcClientThreadData* argument)
{
	TRACE(_T("in ssmcServerThreadData::removeClient\n"));

	bool ok = false;

	if (argument)
	{
		for (int i = 0; i < MAX_NUM_CLIENTS; i++)
		{
			if (clientData[i] == argument)
			{
				ok = true;
				ssmcClientThreadData *pArgument = clientData[i];
				delete pArgument;
				clientData[i] = NULL;
				numOfConnectedClients--;
				if (numOfConnectedClients < 0)
					numOfConnectedClients = 0;
				break;
			}
		}
	}
	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// getClientData
ssmcClientThreadData* ssmcServerThreadData::getClientData(int index)
{
	_ASSERTE(index < MAX_NUM_CLIENTS);

	if (index < MAX_NUM_CLIENTS)
		return clientData[index];
	return NULL;
}




