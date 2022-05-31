#include <signal.h>
#include <iostream>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string>
#include <vector>
#include <pthread.h>
using namespace std;

vector<int> clients;
int ListenSocket;
void terminate(int s);
void* clientHandler(void* sock);

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: %s IP PORT\n", argv[0]);
        return 1;
    }

    // add ctrl-c event handler
    struct sigaction sigIntHandler;
    sigIntHandler.sa_handler = terminate;
    sigemptyset(&sigIntHandler.sa_mask);
    sigIntHandler.sa_flags = 0;
    sigaction(SIGINT, &sigIntHandler, NULL);


    struct sockaddr_in server, client;
    // Create socket
    int ClientSocket = -1;
    ListenSocket = socket(AF_INET, SOCK_STREAM, 0),

        server.sin_addr.s_addr = inet_addr(argv[1]);
    server.sin_family = AF_INET;
    server.sin_port = htons(atoi(argv[2]));

    if (bind(ListenSocket, (struct sockaddr*)&server, sizeof(server)) == -1) {
        perror("Bind failed");
        return 1;
    }

    if (listen(ListenSocket, SOMAXCONN) == -1) {
        perror("Listen failed");
        return 1;
    }

    cout << "Server started listening!\nCtrl-C to terminate\n";

    int c = sizeof(struct sockaddr_in);
    while (1) {
        ClientSocket = accept(ListenSocket, (struct sockaddr*)&client, (socklen_t*)&c);
        if (ClientSocket == -1) {
            //perror("Failed to accept");
            return 1;
        }
        clients.push_back(ClientSocket);
        cout << "Client #" << ClientSocket << " connected!\n";
        pthread_t threadId;
        if (pthread_create(&threadId, NULL, clientHandler, (void*)&ClientSocket)) {
            perror("Failed to create thread");
            return 1;
        }
    }
    pthread_exit(NULL);
}


void terminate(int s) {
    // close all Client sockets then server
    while (!clients.empty()) {
        int sock = clients.back(); clients.pop_back();
        shutdown(sock, 0);
    }
    shutdown(ListenSocket, 0);
    cout << "\nServer disconnected\n";
}

void* clientHandler(void* sock) {
    int ClientSocket = *(int*)sock;
    const int BUF_LEN = 512;
    char buf[BUF_LEN];
    int n_recv;
    do {
        n_recv = recv(ClientSocket, buf, BUF_LEN, 0);
        if (n_recv == 0) {
            printf("Client #%d disconnected\n", ClientSocket);
        }
        else if (n_recv == -1) {
            perror("Recv failed");
        }
        else {
            buf[n_recv] = 0;
            printf("Client #%d: %s\n", ClientSocket, buf);
            send(ClientSocket, buf, n_recv, 0);
        }
    } while (n_recv > 0);
    shutdown(ClientSocket, 0);
    pthread_exit(NULL);
}

