#include "CEditEx.h"

void CEditEx::Append(CString newString)
{
	auto newlength = this->GetWindowTextLength() + newString.GetLength() + 1;
	auto buffer = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, newlength*2);
	
	this->GetWindowText((LPTSTR)buffer, newlength);
	_tcscat_s((LPTSTR)buffer, newlength, newString);
	this->SetWindowText((LPCTSTR)buffer);
	HeapFree(GetProcessHeap(), 0, buffer);
}
