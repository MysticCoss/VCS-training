#include "CListCtrlEx.h"

BEGIN_MESSAGE_MAP(CListCtrlEx, CListCtrl)
	ON_WM_ERASEBKGND()
END_MESSAGE_MAP()

BOOL CListCtrlEx::OnEraseBkgnd(CDC* pDC)
{
    CPaintDC dc(this);
    CRect m_rectCtrl;
    this->GetWindowRect(&m_rectCtrl);
    //GetControlRect(&m_rectCtrl);
    CMemDC* pMemDC = new CMemDC(dc, &m_rectCtrl);
    pMemDC->GetDC().FillSolidRect(&m_rectCtrl, GetSysColor(COLOR_WINDOW));
    pMemDC->GetDC().BitBlt(0, 0, m_rectCtrl.Width(), m_rectCtrl.Height(), pDC, 0, 0, SRCCOPY);
	return true;
}
