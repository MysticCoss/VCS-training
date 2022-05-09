#pragma once
#include "CListCtrlEx.h"
#include "framework.h"
#include "ClientSocket.h"

class CMainFrameClient : public CFrameWnd, public CSocket
{
private:
	CEdit ctrl_edit_filepath;
	UINT id_ctrl_edit_filepath = 0;

	CEdit ctrl_edit_filename;
	UINT id_ctrl_edit_filename = 1;

	CButton ctrl_button_search;
	UINT id_ctrl_button_search = 2;

	CFont font;

	CEdit ctrl_edit_chatbox;
	UINT id_ctrl_edit_chatbox = 3;

	CEdit ctrl_edit_chatinput;
	UINT id_ctrl_edit_chatinput = 4;

	CButton ctrl_button_send;
	UINT id_ctrl_button_send = 5;

	ClientSocket mySocket;
public:
	CMainFrameClient();
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_connect();
	void OnButtonClick_button_send();
	afx_msg void OnSizing(UINT nType, LPRECT newsize);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
	DECLARE_MESSAGE_MAP()
};

