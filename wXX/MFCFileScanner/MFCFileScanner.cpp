#include "pch.h"
#include "MFCFileScanner.h"

	CSimpleFrame::CSimpleFrame()
	{
		// Create the window's frame
		CRect(10, 5, 665, 25);
		Create(NULL, TEXT("Windows Application"));
		//Create(TEXT("EDIT"), NULL, WS_VISIBLE | WS_CHILD | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,
		//	CRect(10, 5, 665, 25),
		//	GetOwner(),
		//	NULL, NULL, NULL);
	}
	afx_msg int CSimpleFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
	{
		m_edit.Create(WS_VISIBLE | WS_CHILD | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL, CRect(10, 5, 665, 25), this, NULL);
		return 0;
	}

	BOOL CSimpleApp::InitInstance()
	{
		// Use a pointer to the window's frame for the application
		// to use the window
		CSimpleFrame* Tester = new CSimpleFrame();
		m_pMainWnd = Tester;
		// Show the window
		m_pMainWnd->ShowWindow(SW_SHOW);
		m_pMainWnd->UpdateWindow();
		return TRUE;
	}


CSimpleApp theApp;