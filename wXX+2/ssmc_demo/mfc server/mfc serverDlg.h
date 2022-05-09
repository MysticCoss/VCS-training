// mfc serverDlg.h : header file
//

#ifndef MFC_SERVERDLG_H
#define MFC_SERVERDLG_H

#include "ssmcThreadData.h"
#include "ssmcSocket.h"
#include "XListBox.h"

/////////////////////////////////////////////////////////////////////////////
// CMfcserverDlg dialog

class CMfcserverDlg : public CDialog
{
// Construction
public:
	CMfcserverDlg(CWnd* pParent = NULL);	// standard constructor
	~CMfcserverDlg();

// Dialog Data
	//{{AFX_DATA(CMfcserverDlg)
	enum { IDD = IDD_MFCSERVER_DIALOG };
	CStatic	m_NumMessagesReceived;
	CStatic	m_NumClients;
	CXListBox	m_Log;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMfcserverDlg)
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
	ssmcServerThreadData *	m_pServerData;
	ssmcTcpSocket *			m_pServer;

	void Dump();
	BOOL Startup();

	// Generated message map functions
	//{{AFX_MSG(CMfcserverDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnWindowPosChanging(WINDOWPOS FAR* lpwndpos);
	afx_msg void OnStartclient();
	afx_msg void OnDestroy();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif //MFC_SERVERDLG_H
