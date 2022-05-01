
// MFCFileScanner.h : main header file for the MFCFileScanner application
//
#pragma once
#include "framework.h"
#include <afxwin.h>
#include <Windows.h>
#include <string>
#include <tlhelp32.h>
#include "resource.h"       // main symbols

#ifndef _WIN32_DCOM
	#define _WIN32_DCOM
#endif

#include <wbemidl.h>
#pragma comment(lib, "wbemuuid.lib")


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
	CButton ctrl_button_refresh;
	UINT id_ctrl_button_search = 2;

	CFont font;

	CListCtrlEx ctrl_list_foundfile;
	UINT id_ctrl_list_foundfile = 3;

	//For WMI functionality
	IWbemLocator* pLoc = NULL;
	IWbemServices* pSvc = NULL;
public:
	void SetupWmiClient();
	CSimpleWindow();
	~CSimpleWindow() override;
	static bool IsProcessElevated();
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
