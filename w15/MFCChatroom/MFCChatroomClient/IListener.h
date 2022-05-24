#pragma once
#include "framework.h"
class IListener
{
public:
	virtual void AppendLine(CString newtext) = 0;
	virtual void Cleanup() = 0;
};

