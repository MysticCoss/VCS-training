
// MFCFileScanner.h : main header file for the MFCFileScanner application
//
#pragma once
#include "framework.h"
#include <afxwin.h>
#include <Windows.h>
#include <string>


#include "resource.h"       // main symbols


// CSimpleFrame:
// See MFCFileScanner.cpp for the implementation of this class
//

class CListCtrlEx : public CListCtrl
{
protected:
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	DECLARE_MESSAGE_MAP()
};
BEGIN_MESSAGE_MAP(CListCtrlEx, CListCtrl)
	ON_WM_ERASEBKGND()
END_MESSAGE_MAP()

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

	CListCtrlEx ctrl_list_foundfile;
	UINT id_ctrl_list_foundfile = 3;
public:
	CSimpleWindow();
	void SetupDynamicResize();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_search();
	afx_msg void OnSizing(UINT nType, LPRECT newsize);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
	DECLARE_MESSAGE_MAP()
};
BEGIN_MESSAGE_MAP(CSimpleWindow, CFrameWnd)
	ON_WM_CREATE()
	ON_WM_GETMINMAXINFO()
	ON_BN_CLICKED(2, OnButtonClick_button_search) //id_ctrl_list_foundfile
	ON_WM_SIZING()
	ON_WM_SIZE()
END_MESSAGE_MAP()


struct CSimpleApp : public CWinApp
{
	BOOL InitInstance() override;
};

extern CSimpleApp theApp;
