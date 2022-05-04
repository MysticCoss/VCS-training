#include "CListCtrlEx.h"

BEGIN_MESSAGE_MAP(CListCtrlEx, CListCtrl)
	ON_WM_ERASEBKGND()
END_MESSAGE_MAP()

BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
{
	return false;
}
