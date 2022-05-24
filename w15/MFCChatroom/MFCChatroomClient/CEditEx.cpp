#include "CEditEx.h"

void CEditEx::AppendLine(CString newString)
{
	CString oldString;

	GetWindowText(oldString);

	newString = oldString + _T("\r\n") + newString;

	SetWindowText(newString);
}
