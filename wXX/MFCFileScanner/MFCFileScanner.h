
// MFCFileScanner.h : main header file for the MFCFileScanner application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'pch.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols


// CSimpleFrame:
// See MFCFileScanner.cpp for the implementation of this class
//

class CSimpleFrame : public CFrameWnd
{
private:
	CEdit m_edit;
public:

	CSimpleFrame();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	DECLARE_MESSAGE_MAP()
};
BEGIN_MESSAGE_MAP(CSimpleFrame, CFrameWnd)
	ON_WM_CREATE()
END_MESSAGE_MAP()


struct CSimpleApp : public CWinApp
{
	BOOL InitInstance() override;
};

extern CSimpleApp theApp;
