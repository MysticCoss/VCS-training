#ifndef SSMCEXCEPTION_H
#define SSMCEXCEPTION_H

class ssmcException
{
public:
    // int: error code, string is the concrete error message
	ssmcException(LPCTSTR lpszModule, int lineno, int errCode, LPCTSTR errMsg);   
	~ssmcException() {};

	virtual void report();  
	int getErrCode()    { return errorCode; }
	TCHAR * getErrMsg() { return szErrorMsg; }

protected:
	int errorCode;
	int lineNo;
	TCHAR szErrorMsg[4000];
	TCHAR szModule[MAX_PATH*2];
};

#endif //SSMCEXCEPTION_H
