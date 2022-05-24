//Compiler option: -std=c++17
#include <iostream>
#include <cstdio>
#include <filesystem>
using namespace std;
namespace fs = std::filesystem;

// check if contains substring case insensitive
bool isSub(string a, string b) {
	for (auto& i : a) if (isupper(i)) i = tolower(i);
	for (auto& i : b) if (isupper(i)) i = tolower(i);
	return a.find(b) != string::npos;
}

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: %s file_name search_path\n", argv[0]);
        return 1;
    }
    char *fileName = argv[1], *searchPath = argv[2];

    // find file with partial matched file_name substring
    for (auto& entry: fs::recursive_directory_iterator(searchPath)) {
        if (entry.is_regular_file() && isSub(entry.path().filename().string(), fileName)) {
            printf("%s\n", entry.path().c_str());
        }
    }
        
}

