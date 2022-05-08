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

	CButton ctrl_button_start;
	UINT id_ctrl_button_start = 2;

	CButton ctrl_button_stop;
	UINT id_ctrl_button_stop = 4;

	CFont font;

	CListCtrlEx ctrl_list_connectedclient;
	UINT id_ctrl_list_connectedclient = 3;

	ServerSocket mySock;
	
public:
	CMainFrameServer();
	//void OnClientChange();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_start();
	void OnButtonClick_button_stop();
	void OnAccept(CString ipAddress, USHORT port) override;
	void OnReceive() override;
	afx_msg void OnSizing(UINT nType, LPRECT newsize);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
	DECLARE_MESSAGE_MAP()
};

