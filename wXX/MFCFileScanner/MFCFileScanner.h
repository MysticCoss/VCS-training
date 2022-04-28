
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

class CSimpleWindow : public CFrameWnd
{
private:
	CEdit ctrl_edit_filepath;
	UINT id_ctrl_edit_filepath = 0;

	CEdit ctrl_edit_filename;
	UINT id_ctrl_edit_filename = 1;

	CButton ctrl_button_search;
	UINT id_ctrl_button_search = 2;

	CFont font;

	CListCtrl ctrl_list_foundfile;
	UINT id_ctrl_list_foundfile = 3;
public:
	CSimpleWindow();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_search();
	DECLARE_MESSAGE_MAP()
};
BEGIN_MESSAGE_MAP(CSimpleWindow, CFrameWnd)
	ON_WM_CREATE()
	ON_BN_CLICKED(2, OnButtonClick_button_search) //id_ctrl_list_foundfile
END_MESSAGE_MAP()


struct CSimpleApp : public CWinApp
{
	BOOL InitInstance() override;
};

extern CSimpleApp theApp;
