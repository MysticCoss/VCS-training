// XWSAError.h  Version 1.0
//
// Author: Hans Dietrich
//         hdietrich@gmail.com
//
// This software is released into the public domain.  You are free to use it
// in any way you like, except that you may not sell this source code.
//
// This software is provided "as is" with no expressed or implied warranty.
// I accept no liability for any damage or loss of business that this software
// may cause.
//
///////////////////////////////////////////////////////////////////////////////

#ifndef XWSAERROR_H
#define XWSAERROR_H

// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the XWSAERROR_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// XWSAERROR_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.

#ifdef XWSAERROR_EXPORTS
#define XWSAERROR_API __declspec(dllexport)
#else
#pragma message("automatic link to XWSAError.lib")
#pragma comment(lib, "XWSAError.lib")
#define XWSAERROR_API __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {
#endif

XWSAERROR_API int __stdcall XWSA_GetErrorString(int nErrorCode, TCHAR * lpszBuf, int nBufSize);
XWSAERROR_API int __stdcall XWSA_GetErrorCode(const TCHAR * lpszErrorString);
XWSAERROR_API int __stdcall XWSA_GetErrorStringSize();
XWSAERROR_API int __stdcall XWSA_GetShortDescription(int nErrorCode, TCHAR * lpszBuf, int nBufSize);
XWSAERROR_API int __stdcall XWSA_GetShortDescriptionSize();
XWSAERROR_API int __stdcall XWSA_GetLongDescription(int nErrorCode, TCHAR * lpszBuf, int nBufSize);
XWSAERROR_API int __stdcall XWSA_GetLongDescriptionSize();

#ifdef __cplusplus
}
#endif

#endif //XWSAERROR_H
