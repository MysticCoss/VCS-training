// mfc server.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "mfc server.h"
#include "mfc serverDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMfcserverApp

BEGIN_MESSAGE_MAP(CMfcserverApp, CWinApp)
	//{{AFX_MSG_MAP(CMfcserverApp)
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMfcserverApp construction

CMfcserverApp::CMfcserverApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CMfcserverApp object

CMfcserverApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CMfcserverApp initialization

BOOL CMfcserverApp::InitInstance()
{
#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	CMfcserverDlg dlg;
	m_pMainWnd = &dlg;
	dlg.DoModal();
	return FALSE;
}
