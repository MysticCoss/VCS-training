#pragma once
#include "CListCtrlEx.h"
#include "framework.h"
#include "IListener.h"
#include "ServerSocket.h"


class CMainFrameServer : public CFrameWnd, public IListener
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

	ServerSocket mySock;
public:
	CMainFrameServer();
	//void OnClientChange();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_start();
	void OnButtonClick_button_stop();
	void OnAccept() override;
	void OnReceive() override;
	afx_msg void OnSizing(UINT nType, LPRECT newsize);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
	DECLARE_MESSAGE_MAP()
};

