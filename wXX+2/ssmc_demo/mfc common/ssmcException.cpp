// ssmcException.cpp
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


#include "ssmcException.h"

// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcException::ssmcException(LPCTSTR lpszModule, 
							 int lineno, 
							 int errCode, 
							 LPCTSTR errMsg)
							 :
							 lineNo(lineno),
							 errorCode(errCode)
{
	ZeroMemory(szModule, sizeof(szModule));
	if (lpszModule)
		_tcsncpy(szModule, lpszModule, _countof(szModule)-2);
	ZeroMemory(szErrorMsg, sizeof(szErrorMsg));
	if (errMsg)
		_tcsncpy(szErrorMsg, errMsg, _countof(szErrorMsg)-2);
}

///////////////////////////////////////////////////////////////////////////////
// report
void ssmcException::report()
{
	TRACE(_T("ssmcException at %s(%d) : errorCode=%u  szErrorMsg=<%s>\n"), 
		szModule, lineNo, errorCode, szErrorMsg);
}
