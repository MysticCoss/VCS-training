// mfc clientDlg.h : header file
//

#ifndef MFC_CLIENTDLG_H
#define MFC_CLIENTDLG_H

#include "ssmcSocket.h"
#include "XListBox.h"
#include "XIPAddressCtrl.h"

/////////////////////////////////////////////////////////////////////////////
// CMfcclientDlg dialog

class CMfcclientDlg : public CDialog
{
// Construction
public:
	CMfcclientDlg(CWnd* pParent = NULL);	// standard constructor
	~CMfcclientDlg();

// Dialog Data
	//{{AFX_DATA(CMfcclientDlg)
	enum { IDD = IDD_MFCCLIENT_DIALOG };
	CButton	m_Ping;
	CXIPAddressCtrl	m_ServerIP;
	CEdit			m_edtMessage;
	CXListBox		m_Log;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMfcclientDlg)
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON			m_hIcon;
    ssmcTcpSocket *	m_pClient;
	CString			m_strServerName;
	DWORD			m_dwServerIP;
	CString			m_strThreadId;
	HANDLE			m_hWriteMutex;

	BOOL			CreateSyncObject();
	void			Dump();
	BOOL			Lock(DWORD dwTimeOut);
	int				ReceiveMessageFromServer(CString& strMessage);
	CString			ReadServerConfig();
	int				SendMessages(LPCTSTR lpszMessage, int nRepeat);
	int				SendMessageToServer(LPCTSTR lpszMessage);
	BOOL			StartClient();
	BOOL			Unlock();

	// Generated message map functions
	//{{AFX_MSG(CMfcclientDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnSend();
	afx_msg void OnDestroy();
	afx_msg void OnWindowPosChanging(WINDOWPOS FAR* lpwndpos);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnConnect();
	afx_msg void OnDisconnect();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif //MFC_CLIENTDLG_H
