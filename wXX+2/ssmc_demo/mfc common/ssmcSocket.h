#ifndef SSMCSOCKET_H
#define SSMCSOCKET_H

#include "ssmcHostInfo.h"

#ifndef _WINSOCKAPI_
#define _WINSOCKAPI_ 
#endif
#include <winsock2.h>

const int MAX_RECV_LEN	= (16 * 1024);
const int MAX_MSG_LEN	= (8 * 1024);
const int PORTNUM		= 1200;

class ssmcSocket
{
public:
	ssmcSocket(int);                       // given a port number, create a socket
	
	virtual ~ssmcSocket()
	{
		TRACE(_T("in ssmcSocket::~ssmcSocket\n"));
		closeSocket();
	}
	
	void closeSocket()
	{
		if (socketId)
			closesocket(socketId);
	    portNumber = 0;
		socketId = 0;
	}

	bool IsSocketOpen() { return (socketId != 0); }

protected:
	
	// only used when the socket is used for client communication
	// once this is done, the next necessary call is setSocketId(int)
	ssmcSocket() {}
	void setSocketId(int socketFd) { socketId = socketFd; }
	bool GetSockOpt(SOCKET socket, int level, int optname, char *optval, 
		int *optlen, LPCTSTR desc);
	bool SetSockOpt(SOCKET socket, int level, int optname, const char *optval, 
		int optlen, LPCTSTR desc);

protected:
	
    int portNumber;        // Socket port number    
    int socketId;          // Socket file descriptor
	
    int blocking;          // Blocking flag
    int bindFlag;          // Binding flag
	
    struct sockaddr_in clientAddr;    // Address of the client that sent data

public:

	// socket options : ON/OFF

	bool setDebug(int);
	bool setReuseAddr(int);
	bool setKeepAlive(int);
	bool setLingerOnOff(bool);
	bool setLingerSeconds(int);
	bool setSocketBlocking(int);

	// size of the send and receive buffer

	bool setSendBufSize(int);
	bool setReceiveBufSize(int);

	// retrieve socket option settings

	int  getDebug();
	int  getReuseAddr();
	int  getKeepAlive();
	int  getSendBufSize();
	int  getReceiveBufSize();
	int  getSocketBlocking() { return blocking; }
	int  getLingerSeconds();
	bool getLingerOnOff();
	
	// returns the socket file descriptor
	int getSocketId() { return socketId; }
	
	// returns the port number
	int getPortNumber() { return portNumber; }
	
	// Gets the system error
	TCHAR * detectError(int*, LPCTSTR);
};

class ssmcTcpSocket : public ssmcSocket
{
public:
	// Constructor. used for creating instances dedicated to client 
	// communication:
	// when accept() is successful, a socketId is generated and returned
	// this socket id is then used to build a new socket using the following
	// constructor, therefore, the next necessary call should be setSocketId()
	// using this newly generated socket fd
	ssmcTcpSocket() {};

	// Constructor.  Used to create a new TCP socket given a port
	ssmcTcpSocket(int portId) : ssmcSocket(portId) { };

	~ssmcTcpSocket();

public:

	// initialization work, the clean up is in the destructor
	static bool initialize();

public:

	// Sends a message to a connected host. The number of bytes sent is returned
	// can be either server call or client call
	int sendMessage(LPBYTE lpBuffer, int dwBufSize);
	int sendMessage(LPCTSTR lpszBuffer);

	// receive messages and stores the message in a buffer
	int receiveMessage(LPBYTE lpBuffer,	int dwBufSize);

	// Binds the socket to an address and port number
	// a server call
	bool bindSocket();

	// accepts a connecting client.  The address of the connected client 
	// is stored in the parameter
	// a server call
	ssmcTcpSocket * acceptClientA(char *);
	ssmcTcpSocket * acceptClient(TCHAR *);

	// Listens to connecting clients, a server call
	void listenToClient(int numPorts = SOMAXCONN);

	// connect to the server, a client call
	virtual bool connectToServer(LPCTSTR, hostType);
};

#endif //SSMCSOCKET_H
