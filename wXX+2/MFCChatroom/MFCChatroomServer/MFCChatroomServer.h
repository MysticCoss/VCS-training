#pragma once
#include "framework.h"


struct CWinAppServer : public CWinApp
{
	BOOL InitInstance() override;
	BOOL ExitInstance() override;
};

extern CWinAppServer theApp;