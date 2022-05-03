
// MFCChatroomClient.cpp : Defines the class behaviors for the application.
//
#include "MFCChatroomClient.h"
#include "CMainFrameClient.h"



BOOL CWinAppClient::InitInstance()
{
	const auto mainFrame = new CMainFrameClient();

	// Set member m_pMainWnd to our 
	m_pMainWnd = mainFrame;
	// Show the window
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();
	return TRUE;
}

CWinAppClient theApp;