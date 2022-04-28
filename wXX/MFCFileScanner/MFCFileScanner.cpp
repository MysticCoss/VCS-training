#include "pch.h"
#include "MFCFileScanner.h"

	CSimpleWindow::CSimpleWindow()
	{
		AfxRegisterWndClas()
		auto v = Create(0, 0, (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX), CRect(10, 5, 665, 25), this, 124423);
		
	}
	afx_msg int CSimpleWindow::OnCreate(LPCREATESTRUCT lpCreateStruct)
	{	
		return 0;
	}

	BOOL CSimpleWindow::PreCreateWindow(CREATESTRUCT& cs)
	{
		CWnd::PreCreateWindow(cs);
		cs.cx = 700;
		cs.cy = 250;
		return true;
	}



	BOOL CSimpleApp::InitInstance()
	{
		// Use a pointer to the window's frame for the application
		// to use the window
		CSimpleWindow* Tester = new CSimpleWindow();
		m_pMainWnd = Tester;
		// Show the window
		m_pMainWnd->ShowWindow(SW_SHOW);
		m_pMainWnd->UpdateWindow();
		return TRUE;
	}


CSimpleApp theApp;