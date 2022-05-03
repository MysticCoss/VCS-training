
// MFCChatroomServer.h : main header file for the MFCChatroomServer application
//
#pragma once
#include "framework.h"

// CMFCChatroomServerApp:
// See MFCChatroomServer.cpp for the implementation of this class
//

class CMFCChatroomServerApp : public CWinAppEx
{
public:
	CMFCChatroomServerApp() noexcept;


// Overrides
public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();

// Implementation
	UINT  m_nAppLook;
	BOOL  m_bHiColorIcons;

	virtual void PreLoadState();
	virtual void LoadCustomState();
	virtual void SaveCustomState();

	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CMFCChatroomServerApp theApp;
