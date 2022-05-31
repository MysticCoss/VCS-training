#include <iostream>
#include <cstdio>
#include <string>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <pthread.h>
using namespace std;

const int BUF_LEN = 512;
void* serverRecv(void* arg);

int main(int argc, char** argv) {

    if (argc != 3) {
        printf("Usage: %s IP, PORT\n", argv[0]);
        return 1;
    }

    struct sockaddr_in server;

    // Create socket
    int ConnectSocket = socket(AF_INET, SOCK_STREAM, 0);

    server.sin_addr.s_addr = inet_addr(argv[1]);
    server.sin_family = AF_INET;
    server.sin_port = htons(atoi(argv[2]));

    // Connect to server
    if (connect(ConnectSocket, (struct sockaddr*)&server, sizeof(server)) == -1) {
        perror("Connect to server failed!");
        return 1;
    }

    while (true) {
        cout << "Enter message (\\quit to quit): ";
        string buf;
        cin >> buf;
        if (buf == "\\quit") break;
        // send buf to server
        send(ConnectSocket, buf.c_str(), buf.size(), 0);
        // recieve from server
        int n_recv;
        char recv_buf[BUF_LEN];
        n_recv = recv(ConnectSocket, recv_buf, BUF_LEN, 0);
        if (n_recv == 0) {
            cout << "\nConnection closed\n";
        }
        else if (n_recv == -1) {
            perror("recv failed");
        }
        else if (n_recv > 0) {
            recv_buf[n_recv] = 0;
            printf("Server: %s\n", recv_buf);
        }
    }
    // close connection
    shutdown(ConnectSocket, 0);
}

void* serverRecv(void* arg) {
    // Recieve msg from server
    int ConnectSocket = *(int*)arg;
    int n_recv;
    do {
        char buf[BUF_LEN];
        n_recv = recv(ConnectSocket, buf, BUF_LEN, 0);
        if (n_recv == 0) {
            cout << "\nConnection closed\n";
        }
        else if (n_recv == -1) {
            perror("recv failed");
        }
        else if (n_recv > 0) {
            buf[n_recv] = 0;
            printf("Server: %s\n", buf);

        }
    } while (n_recv > 0);
    shutdown(ConnectSocket, 0);
    exit(0);
    pthread_exit(NULL);
}