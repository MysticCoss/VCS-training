
// MFCChatroomClient.h : main header file for the MFCChatroomClient application
//
#pragma once
#include "framework.h"


struct CWinAppClient : public CWinApp
{
	BOOL InitInstance() override;
	BOOL ExitInstance() override;
};

extern CWinAppClient theApp;