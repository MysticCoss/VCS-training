// ssmcSocket.cpp
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

#pragma warning(disable : 4702)		// unreachable code

#ifndef _MFC_VER

#ifndef _WINSOCKAPI_
#define _WINSOCKAPI_ 
#endif

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

#include "ssmcSocket.h"
#include "ssmcException.h"
#include "XWSAError.h"
#include <malloc.h>

// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

const int MSG_HEADER_LEN = 6;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// ssmcSocket
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcSocket::ssmcSocket(int pNumber)
{
	TRACE(_T("in ssmcSocket::ssmcSocket\n"));

	socketId = 0;
    portNumber = pNumber;
    blocking = 1;

    try
    {
		if ((socketId = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        {
			socketId = 0;
			int errorCode;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("")));
			throw excp;
        }
		else
		{
			TRACE(_T("socket() returned socketId=%d\n"), socketId);
		}
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}

	// set the initial address of client that shall be communicated with to 
	// any address as long as they are using the same port number. 
	// The clientAddr structure is used in the future for storing the actual
	// address of client applications with which communication is going
	// to start
    clientAddr.sin_family      = AF_INET;
    clientAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    clientAddr.sin_port        = htons((unsigned short) portNumber);
}

///////////////////////////////////////////////////////////////////////////////
// SetSockOpt
bool ssmcSocket::SetSockOpt(SOCKET socket, 
							int level, 
							int optname, 
							const char *optval, 
							int optlen,
							LPCTSTR desc)
{
	_ASSERTE(optval);
	_ASSERTE(socketId);

	bool ok = true;

	try 
	{
		if (setsockopt(socket, level, optname, optval, optlen) == -1)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, desc));
			ok = false;
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}
	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// GetSockOpt
bool ssmcSocket::GetSockOpt(SOCKET socket, 
							int level, 
							int optname, 
							char *optval,
							int *optlen, 
							LPCTSTR desc)
{
	_ASSERTE(optval);
	_ASSERTE(optlen);
	_ASSERTE(socketId);

	bool ok = true;

	try 
	{
		if (getsockopt(socket, level, optname, optval, optlen) == -1)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, desc));
			ok = false;
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}
    
    return ok;
}

///////////////////////////////////////////////////////////////////////////////
// setDebug
bool ssmcSocket::setDebug(int toggle)
{
	return SetSockOpt(socketId, SOL_SOCKET, SO_DEBUG, (char *)&toggle, 
		sizeof(toggle), _T("DEBUG option:"));
}

///////////////////////////////////////////////////////////////////////////////
// setReuseAddr
bool ssmcSocket::setReuseAddr(int toggle)
{
	return SetSockOpt(socketId, SOL_SOCKET, SO_REUSEADDR, (char *)&toggle, 
		sizeof(toggle), _T("REUSEADDR option:"));
} 

///////////////////////////////////////////////////////////////////////////////
// setKeepAlive
bool ssmcSocket::setKeepAlive(int toggle)
{
	return SetSockOpt(socketId, SOL_SOCKET, SO_KEEPALIVE, (char *)&toggle, 
		sizeof(toggle), _T("ALIVE option:"));
} 

///////////////////////////////////////////////////////////////////////////////
// setLingerSeconds
bool ssmcSocket::setLingerSeconds(int seconds)
{
	struct linger lingerOption;
	
	if (seconds > 0)
	{
		lingerOption.l_linger = (unsigned short) seconds;
		lingerOption.l_onoff = 1;
	}
	else 
	{
		lingerOption.l_onoff = 0;
	}

	return SetSockOpt(socketId, SOL_SOCKET, SO_LINGER, (char *)&lingerOption, 
		sizeof(struct linger), _T("LINGER option:"));
}

///////////////////////////////////////////////////////////////////////////////
// setLingerOnOff
bool ssmcSocket::setLingerOnOff(bool lingerOn)
{
	struct linger lingerOption;

	if (lingerOn) 
		lingerOption.l_onoff = 1;
	else 
		lingerOption.l_onoff = 0;

	return SetSockOpt(socketId, SOL_SOCKET, SO_LINGER, (char *)&lingerOption, 
		sizeof(struct linger), _T("LINGER option:"));
}

///////////////////////////////////////////////////////////////////////////////
// setSendBufSize
bool ssmcSocket::setSendBufSize(int sendBufSize)
{
	return SetSockOpt(socketId, SOL_SOCKET, SO_SNDBUF, (char *)&sendBufSize, 
		sizeof(sendBufSize), _T("SENDBUFSIZE option:"));
} 

///////////////////////////////////////////////////////////////////////////////
// setReceiveBufSize
bool ssmcSocket::setReceiveBufSize(int receiveBufSize)
{
	return SetSockOpt(socketId, SOL_SOCKET, SO_RCVBUF, (char *)&receiveBufSize, 
		sizeof(receiveBufSize), _T("RCVBUF option:"));
}

///////////////////////////////////////////////////////////////////////////////
// setSocketBlocking
bool ssmcSocket::setSocketBlocking(int blockingToggle)
{
	_ASSERTE(socketId);

	bool ok = true;

    if (blockingToggle)
    {
        if (getSocketBlocking()) 
			return ok;
        else 
			blocking = 1;
	}
	else
	{
		if (!getSocketBlocking()) 
			return ok;
		else 
			blocking = 0;
	}

	try 
	{
		if (ioctlsocket(socketId, FIONBIO, (unsigned long *)&blocking) == -1)
		{
			ok = false;
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("Blocking option: ")));
			throw excp;
		}
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}
	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// getDebug
int ssmcSocket::getDebug()
{
    int option = 0;
    int optionlen = sizeof(option);

	GetSockOpt(socketId, SOL_SOCKET, SO_DEBUG, (char *)&option, 
		&optionlen, _T("get DEBUG option:"));

    return option;
}

///////////////////////////////////////////////////////////////////////////////
// getReuseAddr
int ssmcSocket::getReuseAddr()
{
    int option = 0;
    int optionlen = sizeof(option);

	GetSockOpt(socketId, SOL_SOCKET, SO_REUSEADDR, (char *)&option, 
		&optionlen, _T("get REUSEADDR option:"));

    return option;
}

///////////////////////////////////////////////////////////////////////////////
// getKeepAlive
int ssmcSocket::getKeepAlive()
{
    int option = 0;
    int optionlen = sizeof(option);

	GetSockOpt(socketId, SOL_SOCKET, SO_KEEPALIVE, (char *)&option, 
		&optionlen, _T("get KEEPALIVE option:"));

    return option;
}

///////////////////////////////////////////////////////////////////////////////
// getLingerSeconds
int ssmcSocket::getLingerSeconds()
{
	struct linger option;
	int optionlen = sizeof(struct linger);

	GetSockOpt(socketId, SOL_SOCKET, SO_LINGER, (char *)&option, 
		&optionlen, _T("get LINGER option:"));

	return option.l_linger;
}

///////////////////////////////////////////////////////////////////////////////
// getLingerOnOff
bool ssmcSocket::getLingerOnOff()
{
	struct linger option;
	int optionlen = sizeof(struct linger);

	GetSockOpt(socketId, SOL_SOCKET, SO_LINGER, (char *)&option, 
		&optionlen, _T("get LINGER option:"));

	if (option.l_onoff == 1) 
		return true;
	else 
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// getSendBufSize
int ssmcSocket::getSendBufSize()
{
    int option = 0;
    int optionlen = sizeof(option);

	GetSockOpt(socketId, SOL_SOCKET, SO_SNDBUF, (char *)&option, 
		&optionlen, _T("get SNDBUF option:"));

    return option;
}    

///////////////////////////////////////////////////////////////////////////////
// getReceiveBufSize
int ssmcSocket::getReceiveBufSize()
{
    int option = 0;
    int optionlen = sizeof(option);

	GetSockOpt(socketId, SOL_SOCKET, SO_RCVBUF, (char *)&option, 
		&optionlen, _T("get RCVBUF option:"));

    return option;
}

///////////////////////////////////////////////////////////////////////////////
// detectError
TCHAR * ssmcSocket::detectError(int* errCode, LPCTSTR errMsg)
{
	*errCode = WSAGetLastError();

	static TCHAR szBuf[4000];
	TCHAR tmp[2000];

	ZeroMemory(szBuf, sizeof(szBuf));
	ZeroMemory(tmp, sizeof(tmp));

	if (errMsg)
		_tcsncpy(szBuf, errMsg, _countof(szBuf)-2);	

	XWSA_GetErrorString(*errCode, tmp, _countof(tmp)-2);
	if ((_tcslen(szBuf) + _tcslen(tmp)) < (_countof(szBuf)-4))
		_tcscat(&szBuf[_tcslen(szBuf)], tmp);

	_tcscat(szBuf, _T(": "));

	XWSA_GetShortDescription(*errCode, tmp, _countof(tmp)-2);
	if ((_tcslen(szBuf) + _tcslen(tmp)) < (_countof(szBuf)-2))
		_tcscat(&szBuf[_tcslen(szBuf)], tmp);

	return szBuf;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// ssmcTcpSocket
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// dtor
ssmcTcpSocket::~ssmcTcpSocket()
{
	TRACE(_T("in ssmcTcpSocket::~ssmcTcpSocket\n"));

    // close the winsock library
	TRACE(_T("system shut down ...\n"));		

	try 
	{
		closeSocket();
		if (WSACleanup())
		{
			ssmcException excp(_T(__FILE__), __LINE__, 0, 
				_T("Error: calling WSACleanup()"));
			throw excp;
        }
	}
	catch (ssmcException& excp)
	{
		excp.report();
	}
}

///////////////////////////////////////////////////////////////////////////////
// initialize
bool ssmcTcpSocket::initialize()
{
	TRACE(_T("in ssmcTcpSocket::initialize\n"));

	TRACE(_T("Initializing the winsock library ...\n"));

	WSADATA wsaData;

	bool ok = true;

	try 
	{
		if (WSAStartup(0x101, &wsaData))
		{
			ok = false;
			ssmcException excp(_T(__FILE__), __LINE__, 0, 
				_T("Error: calling WSAStartup()"));
			throw excp;
        }
		else
		{ 
			TRACE(_T("wVersion=0x%X  wHighVersion=0x%X  szDescription=<%s>\n"),
				wsaData.wVersion, wsaData.wHighVersion, wsaData.szDescription);
		}
	}
	catch (ssmcException& excp)
	{
		excp.report();
	}

	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// bindSocket
bool ssmcTcpSocket::bindSocket()
{
	TRACE(_T("in ssmcTcpSocket::bindSocket on socketId=%d\n"), socketId);

	_ASSERTE(socketId);
	if (!socketId)
		return false;

	bool ok = true;

	try
	{
		if (bind(socketId, (struct sockaddr *)&clientAddr, 
			sizeof(struct sockaddr_in)) == -1)
		{
			ok = false;
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("error calling bind(): \n")));
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}
	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// connectToServer
bool ssmcTcpSocket::connectToServer(LPCTSTR serverNameOrAddr, hostType hType)
{ 
	TRACE(_T("in ssmcTcpSocket::connectToServer on socketId=%d\n"), socketId);

	_ASSERTE(serverNameOrAddr);
	_ASSERTE(socketId);
	if (!socketId)
		return false;

	// when this method is called, a client socket has been built already,
	// so we have the socketId and portNumber ready.
	//
    // a ssmcHostInfo instance is created, no matter how the server's name is 
	// given (such as www.codeproject.com) or the server's address is given (such
	// as 209.171.52.99), we can use this ssmcHostInfo instance to get the 
	// IP address of the server

	ssmcHostInfo serverInfo(serverNameOrAddr, hType);
	
    // Store the IP address and socket port number	
	struct sockaddr_in serverAddress;
    serverAddress.sin_family      = AF_INET;
    serverAddress.sin_addr.s_addr = inet_addr(serverInfo.getHostIPAddressA());
    serverAddress.sin_port        = htons((unsigned short) portNumber);

	bool ok = true;

    // Connect to the given address
	try 
	{
		if (connect(socketId, (struct sockaddr *)&serverAddress, 
			sizeof(serverAddress)) == -1)
		{
			ok = false;
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("error calling connect():\n")));
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}

	return ok;
}

///////////////////////////////////////////////////////////////////////////////
// acceptClient
ssmcTcpSocket * ssmcTcpSocket::acceptClient(TCHAR * clientHost)
{
	_ASSERTE(clientHost);

	clientHost[0] = _T('\0');

	ssmcTcpSocket* retSocket = NULL;

	char szClientHost[MAX_PATH*4] = { 0 };

	retSocket = acceptClientA(szClientHost);

	if (retSocket)
	{
#ifdef UNICODE
		MultiByteToWideChar(CP_ACP, 0, szClientHost, -1, clientHost,
			_countof(szClientHost));
#else
		strcpy(clientHost, szClientHost);
#endif
	}

	return retSocket;
}

///////////////////////////////////////////////////////////////////////////////
// acceptClientA
ssmcTcpSocket * ssmcTcpSocket::acceptClientA(char * clientHost)
{
	TRACE(_T("in ssmcTcpSocket::acceptClientA on socketId=%d\n"), socketId);

	_ASSERTE(clientHost);
	_ASSERTE(socketId);
	if (!socketId)
		return NULL;

	int newSocket = 0;					// the new socket file descriptor 
										// returned by the accept system call
    int clientAddressLen = sizeof(struct sockaddr_in);
    struct sockaddr_in clientAddress;	// address of the client that sent data

    // accept a new client connection and store its socket file descriptor
	try 
	{
		if ((newSocket = accept(socketId, (struct sockaddr *)&clientAddress,
			&clientAddressLen)) == -1)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("error calling accept(): \n")));
			throw excp;
        }
		else
		{
			TRACE(_T("accept() returned newSocket=%d\n"), newSocket);
		}
	}
    catch (ssmcException& excp)
	{
		excp.report();
		return NULL;
	}
    
	// get the host name given the address
    char *sAddress = inet_ntoa((struct in_addr)clientAddress.sin_addr);

	TCHAR wAddress[MAX_PATH*4] = { _T('\0') };

#ifdef UNICODE
	MultiByteToWideChar(CP_ACP, 0, sAddress, -1, wAddress,
		_countof(wAddress));
#else
	strcpy(wAddress, sAddress);
#endif

	ssmcHostInfo clientInfo(wAddress, ADDRESS);
	char * hostName = clientInfo.getHostNameA();
	strcpy(clientHost, hostName);
	
    // create and return the new ssmcTcpSocket object
    ssmcTcpSocket* retSocket = new ssmcTcpSocket();
	if (retSocket)
		retSocket->setSocketId(newSocket);

    return retSocket;
}

///////////////////////////////////////////////////////////////////////////////
// listenToClient
void ssmcTcpSocket::listenToClient(int totalNumPorts)
{
	TRACE(_T("in ssmcTcpSocket::listenToClient on socketId=%d\n"), socketId);

	_ASSERTE(socketId);
	if (!socketId)
		return;

	try 
	{
		if (listen(socketId, totalNumPorts) == -1)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("error calling listen():\n")));
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}
}       

///////////////////////////////////////////////////////////////////////////////
// sendMessage
int ssmcTcpSocket::sendMessage(LPBYTE lpBuffer, int nBufSize)
{
	TRACE(_T("in ssmcTcpSocket::sendMessage on socketId=%d; nBufSize=%d\n"), 
		socketId, nBufSize);

	_ASSERTE(lpBuffer);
	_ASSERTE(socketId);
	if (!socketId)
		return SOCKET_ERROR;

	// for each message to be sent, add a header which shows how long this message
	// is. This header, regardless how long the real message is, will always be
	// of the length MSG_HEADER_LEN.

	int len = nBufSize + 6;
	char *sendbuf = (char *) _alloca(len+100);
	sprintf(sendbuf, "%06d", nBufSize);
	memcpy(&sendbuf[6], lpBuffer, nBufSize);

	lpBuffer[len] = 0;
	lpBuffer[len+1] = 0;

	int numBytes = 0;  // the number of bytes sent

	// Sends the message to the connected host
	try 
	{
		if ((numBytes = send(socketId, sendbuf, len, 0)) == SOCKET_ERROR)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("error calling send():\n")));
			throw excp;
        }
	}
    catch (ssmcException& excp)
	{
		excp.report();
	}

	return numBytes;
}

///////////////////////////////////////////////////////////////////////////////
// sendMessage
int ssmcTcpSocket::sendMessage(LPCTSTR lpszBuffer)
{
	_ASSERTE(lpszBuffer);
	int len = (_tcslen(lpszBuffer)+1) * sizeof(TCHAR);
	return sendMessage((LPBYTE)lpszBuffer, len);
}

///////////////////////////////////////////////////////////////////////////////
// receiveMessage
int ssmcTcpSocket::receiveMessage(LPBYTE lpBuffer,	// data buffer
								  int nBufSize)		// size of buffer in bytes

{
	TRACE(_T("in ssmcTcpSocket::receiveMessage on socketId=%d; nBufSize=%d\n"), 
		socketId, nBufSize);

	_ASSERTE(lpBuffer);
	_ASSERTE(socketId);
	if (!socketId)
		return SOCKET_ERROR;

	ZeroMemory(lpBuffer, nBufSize);
	
	int received = 0;				// number of bytes received
    int msgSize = nBufSize;			// max number of bytes to receive
    int numBytes = 0;				// number of bytes currently received
	bool headerFinished = false;

	char charMsg[MAX_RECV_LEN+1];
	char msgLength[MSG_HEADER_LEN+1];
	memset(charMsg, 0, sizeof(charMsg));
	memset(msgLength, 0, sizeof(msgLength));

	try
	{
		while ((received < msgSize) && (received < nBufSize))
		{
			numBytes = recv(socketId, charMsg+received, 1, 0);
			//TRACE(_T("recv returned=%d =====================\n"), numBytes);

			if (numBytes == SOCKET_ERROR)
			{
				int errorCode = 0;
				ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
					detectError(&errorCode, _T("error calling recv():\n")));
				throw excp;
			}

			if (!headerFinished)
			{
				msgLength[received] = *(charMsg+received);
				received++;

				if (received == MSG_HEADER_LEN)
				{
					headerFinished = true;
					received = 0;
					memset(charMsg, 0, sizeof(charMsg));
					msgSize = atoi(msgLength);
					TRACE(_T("header received:  msgSize=%d\n"), msgSize);
				}
			}
			else
			{
				received++;
			}
		}
	}
	catch (ssmcException& excp)
	{
		if (excp.getErrCode() == WSAECONNRESET)
		{
			TRACE(_T("WSAECONNRESET\n"));
			return -99;
		}
		excp.report();
	}

	TRACE(_T("received=%d\n"), received);

	memcpy(lpBuffer, charMsg, received);

    return received;
}
