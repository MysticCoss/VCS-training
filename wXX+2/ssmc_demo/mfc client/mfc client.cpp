// mfc client.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "mfc client.h"
#include "mfc clientDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMfcclientApp

BEGIN_MESSAGE_MAP(CMfcclientApp, CWinApp)
	//{{AFX_MSG_MAP(CMfcclientApp)
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMfcclientApp construction

CMfcclientApp::CMfcclientApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CMfcclientApp object

CMfcclientApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CMfcclientApp initialization

BOOL CMfcclientApp::InitInstance()
{
#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	// INI file is in exe directory
	TCHAR szProfileFilePath[MAX_PATH*2] = { 0 };
	GetModuleFileName(NULL, szProfileFilePath, 
		sizeof(szProfileFilePath)/sizeof(TCHAR)-2);
	TCHAR *cp = _tcsrchr(szProfileFilePath, _T('\\'));
	if (cp)
		*(cp+1) = _T('\0');

	CString strProfileFilePath = szProfileFilePath;
	strProfileFilePath += _T("ssmc.ini");
	TRACE(_T("strProfileFilePath=<%s>\n"), strProfileFilePath);

	// save our ini file name --
	// first free the string allocated by MFC at CWinApp startup.
	// The string is allocated before InitInstance is called.
	free((void*)m_pszProfileName);
	// Change the name of the .INI file.
	// The CWinApp destructor will free the memory.
	// Note:  must be allocated on heap
	m_pszProfileName = _tcsdup(strProfileFilePath);

	CMfcclientDlg dlg;
	m_pMainWnd = &dlg;
	dlg.DoModal();
	return FALSE;
}
