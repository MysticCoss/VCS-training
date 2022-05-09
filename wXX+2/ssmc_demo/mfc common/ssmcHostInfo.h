//  Liyang Yu, Jan 9th, 2004, version 0.0
//
//  This is to implement the domain and IP address resolution. 
//
//  3 cases are considered:
//
//  1. a host name is given (a host name looks like "www.delta.com"), query
//     the IP address of the host.
//
//  2. an IP address is given (an IP address looks like 10.6.17.184), query
//     the host name.
//
//  In the above two cases, the IP address and the host name are the same thing: 
//  Since IP address is hard to remember, they are usually aliased by a name, 
//  and this name is known as the host name.
//
//  3. nothing is given. in other words, we don't know the host name or the IP 
//     address.  In this case, the standard host name for the current processor 
//     is used.
//     
///////////////////////////////////////////////////////////////////////////////

#ifndef SSMCHOSTINFO_H
#define SSMCHOSTINFO_H

#include <winsock2.h>
#include <stdio.h>
    
enum hostType {NAME, ADDRESS};
const int HOST_NAME_LENGTH = MAX_PATH*4;

class ssmcHostInfo
{
public:

    // Default constructor
    ssmcHostInfo();

    // Retrieves the host entry based on the host name or address
    ssmcHostInfo(LPCTSTR hostName, hostType type);
 
    // Destructor.  Closes the host entry database.
    ~ssmcHostInfo() {}

    // Retrieves the hosts IP address
    char * getHostIPAddressA();
    TCHAR * getHostIPAddress();
    
    // Retrieves the hosts name
    char * getHostNameA();
    TCHAR * getHostName();

protected:

	TCHAR * detectError(int* errCode, LPCTSTR errMsg);

private:

	struct hostent *hostPtr;    // Entry within the host address database
};

#endif //SSMCHOSTINFO_H
