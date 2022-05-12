//Compiler option: -std=c++17

#include <iostream>
#include <cstdio>
#include <filesystem>
#include <string>
#include <fstream>
#include <algorithm>

using namespace std;
namespace fs = std::filesystem;

// check if string contains only digit characters
bool isNum(string dir);

// print process command line from cmdline file
void parseCmd(string filePath);

// print field from process status file
void parseStatus(string filePath, string field);

// compare two string case insensitive, if equal return false
bool cmpNoCase(string a, string b);

int main() {
    string delimit = "=================";
    for (auto& entry: fs::directory_iterator("/proc")) {
        if (entry.is_directory() && isNum(entry.path().filename().string())) { 
            cout << "\n" << delimit << "\n\n";
            string cmdPath = entry.path().string() + "/cmdline";
            string statusPath = entry.path().string() + "/status";
            parseStatus(statusPath, "pid");
            parseStatus(statusPath, "ppid");
            parseCmd(cmdPath);
        }
    }
}


bool isNum(string dir) {
    for (auto& c: dir) if (!isdigit(c)) return false;
    return true;
}


void parseCmd(string filePath) {
    ifstream fi(filePath);
    if (!fi) {
        cerr << "Could not open " << filePath << "\n";
        return;
    }
    string line;
    getline(fi, line);
    if (line.empty()) {
        cout << "[S] Command-line:\n\tNone\n";
    }
    else {
        // join line (originally args are split by '\0')
        replace(line.begin(), line.end(), '\0', ' ');
        line[line.length() - 1] = '\0';
        cout << "[S] Full Command-line:\n\t" << line << "\n";
    }
    fi.close();
}

void parseStatus(string filePath, string field) {
    ifstream fi(filePath);
    if (!fi) {
        cerr << "Could not open " << filePath << "\n";
        return;
    }
    string line;
    bool found = false;
    while (getline(fi, line)) {
        string token;
        stringstream ss(line);
        ss>>token;
        if (cmpNoCase(field+":", token) == 0) {
            found = true;
            ss >> token;
            if (field == "pid") {
                cout << "[S] Process ID:\n\t" << token << "\n";
            }
            else if (field == "ppid") {
                cout << "[O] Parent PID:\n\t" << token << "\n";
            }
            else {
                cout << "[S] " << field << ":\n\t" << token << "\n";
            }

        }
    }
    if (!found) {
        cout << "[S] " << field << " not found\n";
    }
    fi.close();
}

bool cmpNoCase(string a, string b) {
    if (a.length() != b.length()) return true;
    for (int i = 1; i <= (int)a.length(); i++) {
        if (tolower(a[i-1]) != tolower(b[i-1])) return true;
    }
    return false;
}
