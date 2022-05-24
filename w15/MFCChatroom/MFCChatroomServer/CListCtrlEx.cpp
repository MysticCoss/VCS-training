#include "CListCtrlEx.h"

BEGIN_MESSAGE_MAP(CListCtrlEx, CListCtrl)
	ON_WM_ERASEBKGND()
END_MESSAGE_MAP()

int CListCtrlEx::FindItem(CString findStr1, CString findStr2)
{
	for (int i = 0; i < GetItemCount(); i++)
	{
		for(int j = 0; j < GetHeaderCtrl()->GetItemCount(); j++)
		{
			if (GetItemText(i, j) == findStr1)
			{
				for(int k = 0; k < GetHeaderCtrl()->GetItemCount(); k++)
				{
					if(GetItemText(i, k) == findStr2)
					{
						return i;
					}
				}
				return -1;
			}

		}
	}
	return -1;
}

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
