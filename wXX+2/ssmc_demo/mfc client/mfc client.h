// mfc client.h : main header file for the MFC CLIENT application
//

#ifndef MFC_CLIENT_H
#define MFC_CLIENT_H

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMfcclientApp:
// See mfc client.cpp for the implementation of this class
//

class CMfcclientApp : public CWinApp
{
public:
	CMfcclientApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMfcclientApp)
public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMfcclientApp)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

extern CMfcclientApp theApp;

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif //MFC_CLIENT_H
