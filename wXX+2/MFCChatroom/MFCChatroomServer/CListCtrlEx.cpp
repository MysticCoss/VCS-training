#include "CListCtrlEx.h"

BEGIN_MESSAGE_MAP(CListCtrlEx, CListCtrl)
	ON_WM_ERASEBKGND()
END_MESSAGE_MAP()

BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
{
	CRect ctrlRect;
	this->GetWindowRect(&ctrlRect);
	ScreenToClient(&ctrlRect);
	CMemDC memDC(*pDC,ctrlRect);
	memDC.GetDC().FillSolidRect(ctrlRect, RGB(255, 255, 255));
	pDC->BitBlt(0, 0, ctrlRect.Width(), ctrlRect.Height(), &memDC.GetDC(), 0, 0, SRCCOPY);
	return false;
}
