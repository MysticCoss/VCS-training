#pragma once
#include "framework.h"
class IListener
{
public:
	virtual void Append(CString newtext) = 0;
};

