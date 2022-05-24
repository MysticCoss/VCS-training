#pragma once
#include "framework.h"

class CListCtrlEx : public CListCtrl
{
public:
	int FindItem(CString findStr1, CString findStr2);
protected:
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	DECLARE_MESSAGE_MAP()
};