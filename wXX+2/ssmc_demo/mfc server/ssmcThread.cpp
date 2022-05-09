// ssmcThread.cpp
//
// This code is based on the article by Liyang Yu,
//     "Single Server With Multiple Clients : a Simple C++ Implementation"
//     http://www.codeproject.com/internet/singleServerMulClient.asp
//
// Modified by Hans Dietrich (hdietrich@gmail.com), 2005 January 26
//
///////////////////////////////////////////////////////////////////////////////


#define _WIN32_WINNT 0x0500

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

#include <process.h>
#include "ssmcThread.h"
#include "ssmcException.h"

///////////////////////////////////////////////////////////////////////////////
// ctor
ssmcThread::ssmcThread(SSMCTHREADFUNC pThreadFunc,
					   LPVOID pThreadFuncParameter,
					   DWORD dwExeFlags,
					   DWORD dwSize,
					   BOOL inheritable)
					   :
					   threadFunction(pThreadFunc),
					   threadArgument(pThreadFuncParameter),
					   executeFlag(dwExeFlags),
					   stackSize(dwSize),
					   exitCode(0xFFFFFFFF),
					   sa(NULL),
					   thread(NULL),
					   threadId(0)
{
	_ASSERTE(pThreadFunc);

	sa = (LPSECURITY_ATTRIBUTES) HeapAlloc(GetProcessHeap(), 0, 
		sizeof(SECURITY_ATTRIBUTES));
	sa->nLength = sizeof(SECURITY_ATTRIBUTES);
    sa->lpSecurityDescriptor = NULL;
	sa->bInheritHandle = inheritable;
}

///////////////////////////////////////////////////////////////////////////////
// dtor
ssmcThread::~ssmcThread()
{
	if (sa)
	{
		HeapFree(GetProcessHeap(), 0, sa);
		sa = NULL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// execute
void ssmcThread::execute()
{
	_ASSERTE(threadFunction);

	thread = NULL;
	threadId = 0;

	thread = (HANDLE) _beginthreadex(sa, stackSize, threadFunction, threadArgument,
		executeFlag, &threadId);

	if (thread == NULL)
    {
		int errCode = 0;
		getErrorDetail(errCode, _T("_beginthreadex() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// waitForThreadToFinish
void ssmcThread::waitForThreadToFinish()
{
	if (WaitForSingleObject(thread, INFINITE) == WAIT_FAILED)
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("WaitForSingleObject() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// getExitCode
DWORD ssmcThread::getExitCode()
{
	if (GetExitCodeThread(thread, &exitCode))
    {
		return exitCode;
    }
    else
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("GetExitCodeThread() failed"));
		return errCode;
    }
}

///////////////////////////////////////////////////////////////////////////////
// getThreadId
DWORD ssmcThread::getThreadId()
{
	return threadId;
}

///////////////////////////////////////////////////////////////////////////////
// resume
void ssmcThread::resume()
{
	if (ResumeThread(thread) == 0xFFFFFFFF)
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("ResumeThread() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// suspend
void ssmcThread::suspend()
{
	if (SuspendThread(thread) == 0xFFFFFFFF)
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("SuspendThread() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// getThreadPriority
int ssmcThread::getThreadPriority()
{
    int retVal = 0;
	if ((retVal = GetThreadPriority(thread)) == THREAD_PRIORITY_ERROR_RETURN)
	{
		int errCode;
		getErrorDetail(errCode, _T("GetThreadPriority() failed"));
        return 0;
    }
    return retVal;
}

///////////////////////////////////////////////////////////////////////////////
// setThreadPriority
void ssmcThread::setThreadPriority(int thePriority)
{
	if (!SetThreadPriority(thread, thePriority))
    {
		int errCode = 0;
		getErrorDetail(errCode, _T("SetThreadPriority() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// setProcessorMask
void ssmcThread::setProcessorMask(DWORD mask)
{
	if (!SetThreadAffinityMask(thread, mask))
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("SetThreadAffinityMask() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// getErrorDetail
void ssmcThread::getErrorDetail(int& errCode, LPCTSTR header)
{
	LPVOID lpDetailMsgBuf;
	errCode = GetLastError();

    DWORD dwSize = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER|FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		errCode,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpDetailMsgBuf,
		0,
		NULL);

	if (dwSize)
	{
		dwSize += _tcslen(header) + 10;
		TCHAR * buf = new TCHAR [dwSize];
		_tcscpy(buf, header);
		_stprintf(&buf[_tcslen(header)], _T(": %s"), (LPTSTR)lpDetailMsgBuf);
		LocalFree(lpDetailMsgBuf);
		TRACE(_T("ERROR - %s\n"), buf);
		_ASSERTE(FALSE);
		delete [] buf;
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//
// FOLLOWING FUNCTIONS ARE NT ONLY
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#ifdef SSMC_INCLUDE_NT

///////////////////////////////////////////////////////////////////////////////
// disablePriorityBoost - NT only
void ssmcThread::disablePriorityBoost(BOOL disable)
{
    if (!SetThreadPriorityBoost(thread, disable))
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("SetThreadPriorityBoost() failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// isPriorityBoostDisabled - NT only
BOOL ssmcThread::isPriorityBoostDisabled()
{
	BOOL boosted = FALSE;

	if (!GetThreadPriorityBoost(thread, &boosted))
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("GetThreadPriorityBoost() failed"));
    }

	return boosted;
}

///////////////////////////////////////////////////////////////////////////////
// setIdealProcessor - NT only
void ssmcThread::setIdealProcessor(DWORD proc)
{
	if (SetThreadIdealProcessor(thread, proc) == -1)
	{
		int errCode = 0;
		getErrorDetail(errCode, _T("SetThreadIdealProcessor failed"));
    }
}

///////////////////////////////////////////////////////////////////////////////
// getThreadStatistics - NT only
void ssmcThread::getThreadStatistics(LPFILETIME creationTime,
									 LPFILETIME exitTime,
									 LPFILETIME kernelTime,
									 LPFILETIME userTime)
{
	if (!GetThreadTimes(thread, creationTime, exitTime, kernelTime, userTime))
    {
		int errCode = 0;
		getErrorDetail(errCode, _T("GetThreadTimes() failed"));
    }
}

#endif	// SSMC_INCLUDE_NT
