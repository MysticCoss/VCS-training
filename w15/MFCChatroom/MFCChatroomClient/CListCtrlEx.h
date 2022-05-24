#pragma once
#include "framework.h"

class CListCtrlEx : public CListCtrl
{
protected:
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	DECLARE_MESSAGE_MAP()
};