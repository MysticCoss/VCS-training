// ssmcHostInfo.cpp
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

// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

#include "ssmcHostInfo.h"
#include "ssmcException.h"
#include "XWSAError.h"

///////////////////////////////////////////////////////////////////////////////
// ctor 1
ssmcHostInfo::ssmcHostInfo()
{
	hostPtr = NULL;
	char szHostName[HOST_NAME_LENGTH+1] = { 0 };

	gethostname(szHostName, HOST_NAME_LENGTH);

	try 
	{
		hostPtr = gethostbyname(szHostName);
		if (hostPtr == NULL)
		{
			int errorCode = 0;
			ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
				detectError(&errorCode, _T("")));
			throw excp;
		}
	}
	catch (ssmcException& excp)
	{
		excp.report();
	}
}

///////////////////////////////////////////////////////////////////////////////
// ctor 2
ssmcHostInfo::ssmcHostInfo(LPCTSTR hostName, hostType type)
{
	_ASSERTE(hostName);

	hostPtr = NULL;
	char szHostName[HOST_NAME_LENGTH+1] = { 0 };	// ANSI

#ifdef UNICODE
	WideCharToMultiByte(CP_ACP, 0, hostName, -1, szHostName, sizeof(szHostName),
		NULL, NULL);
#else
	strcpy(szHostName, hostName);
#endif

	try 
	{
		if (type == NAME)
		{
			// retrieve host by name
			hostPtr = gethostbyname(szHostName);

			if (hostPtr == NULL)
			{
				TRACE(_T("hostPtr is NULL\n"));
				int errorCode;
				ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
					detectError(&errorCode, _T("")));
				throw excp;
			}
        }
		else if (type == ADDRESS)
		{
			// retrieve host by address
		    unsigned long netAddr = inet_addr(szHostName);
			if (netAddr == -1)
			{
				TRACE(_T("netAddr = -1\n"));
				ssmcException excp(_T(__FILE__), __LINE__, 0, _T("Error calling inet_addr()"));
				throw excp;
			}

	        hostPtr = gethostbyaddr((char *)&netAddr, sizeof(netAddr), AF_INET);
			if (hostPtr == NULL)
			{
				TRACE(_T("hostPtr is NULL\n"));
				int errorCode;
				ssmcException excp(_T(__FILE__), __LINE__, errorCode, 
					detectError(&errorCode, _T("")));
				throw excp;
			}
        }
		else
		{
			TRACE(_T("unknown host type: host name/address has to be given \n"));
			ssmcException excp(_T(__FILE__), __LINE__, 0, 
				_T("unknown host type: host name/address has to be given "));
			throw excp;
		}
    }
	catch(ssmcException& excp)
	{
		excp.report();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Retrieves the hosts IP address
char * ssmcHostInfo::getHostIPAddressA() 
{
	if (hostPtr == NULL)
		return NULL;

    struct in_addr *addr_ptr;

	// the first address in the list of host addresses
    addr_ptr = (struct in_addr *)*hostPtr->h_addr_list;

	// change the address format to Internet address in standard dot notation
    return inet_ntoa(*addr_ptr);
}    

///////////////////////////////////////////////////////////////////////////////
// Retrieves the hosts IP address
TCHAR * ssmcHostInfo::getHostIPAddress() 
{
	if (hostPtr == NULL)
		return NULL;

    struct in_addr *addr_ptr;

	// the first address in the list of host addresses
    addr_ptr = (struct in_addr *)*hostPtr->h_addr_list;

	char *cp = inet_ntoa(*addr_ptr);
	if (cp == NULL)
		return NULL;

	static TCHAR szHostIpAddress[MAX_PATH*4] = { 0 };

#ifdef UNICODE
	MultiByteToWideChar(CP_ACP, 0, cp, -1, szHostIpAddress,
		_countof(szHostIpAddress));
#else
	strcpy(szHostIpAddress, cp);
#endif

	// changed the address format to the Internet address in standard dot notation
    return szHostIpAddress;
}    

///////////////////////////////////////////////////////////////////////////////
// Retrieves the hosts name
char * ssmcHostInfo::getHostNameA()
{
	if (hostPtr == NULL)
		return NULL;

	char *cp = hostPtr->h_name;

	//cp = "localhost";

    return cp;
}

///////////////////////////////////////////////////////////////////////////////
// Retrieves the hosts name
TCHAR * ssmcHostInfo::getHostName()
{
	if (hostPtr == NULL)
		return NULL;

	char *cp = hostPtr->h_name;
	if (cp == NULL)
		return NULL;

	//cp = "localhost";

	static TCHAR szHostName[MAX_PATH*4] = { 0 };

#ifdef UNICODE
	MultiByteToWideChar(CP_ACP, 0, cp, -1, szHostName,
		_countof(szHostName));
#else
	strcpy(szHostName, cp);
#endif

    return szHostName;
}

///////////////////////////////////////////////////////////////////////////////
// detectError
TCHAR * ssmcHostInfo::detectError(int* errCode, LPCTSTR errMsg)
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
