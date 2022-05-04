
// MFCChatroomClient.cpp : Defines the class behaviors for the application.
//
#include "MFCChatroomClient.h"
#include "CMainFrameClient.h"



BOOL CWinAppClient::InitInstance()
{
	//Init WSA
	WSADATA wsaData;
	int iResult;

	// Initialize Winsock
	iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0) {
		CString info;
		info.Format(_T("WSAStartup failed: %d\n"), iResult);
		::MessageBox(NULL, info, _T("Error"), MB_OK | MB_ICONERROR);
		return false;
	}

	const auto mainFrame = new CMainFrameClient();

	// Set member m_pMainWnd to our 
	m_pMainWnd = mainFrame;
	// Show the window
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();
	return TRUE;
}

BOOL CWinAppClient::ExitInstance()
{
	WSACleanup();
	return CWinApp::ExitInstance();
}

CWinAppClient theApp;
