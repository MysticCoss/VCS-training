#pragma once
#include "framework.h"
#include "ClientSocket.h"
#include <Windows.h>
#include "CEditEx.h"
#include "IListener.h"

class CMainFrameClient : public CFrameWnd, public IListener
{
private:
	CEdit ctrl_edit_address;
	UINT id_ctrl_edit_address = 0;

	CEdit ctrl_edit_port;
	UINT id_ctrl_edit_port = 1;

	CButton ctrl_button_connect;
	UINT id_ctrl_button_connect = 2;

	CButton ctrl_button_disconnect;
	UINT id_ctrl_button_disconnect = 6;

	CFont font;

	CEditEx ctrl_edit_chatbox;
	UINT id_ctrl_edit_chatbox = 3;

	CEdit ctrl_edit_chatinput;
	UINT id_ctrl_edit_chatinput = 4;

	CButton ctrl_button_send;
	UINT id_ctrl_button_send = 5;

	ClientSocket mySocket;
public:
	CMainFrameClient();
	void AppendLine(CString newtext) override;
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	void OnButtonClick_button_connect();
	void OnButtonClick_button_disconnect();
	void OnButtonClick_button_send();
	void Cleanup() override;
	afx_msg void OnSizing(UINT nType, LPRECT newsize);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnGetMinMaxInfo(MINMAXINFO* lpMMI);
	DECLARE_MESSAGE_MAP()
};

