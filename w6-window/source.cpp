#include <Windows.h>
#include <stdio.h>
#include <Psapi.h>
#include <Shlwapi.h>
HANDLE hHeap;
HANDLE hStdin;
HANDLE hStdout;

BOOL CALLBACK EnumWindowsProc(HWND hWnd, LPARAM lParam) {
    wchar_t buff[255];
    DWORD pid;
    GetWindowThreadProcessId(hWnd, &pid);
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE, FALSE, pid);
    int count = 0;
    if (GetModuleFileNameEx(hProc,NULL, buff, 254) > 0)
    {
        if (StrStr(buff,L"chrome.exe")!=NULL)
        {
            TerminateProcess(hProc, -1);
            count++;
        }
        if (StrStr(buff, L"msedge.exe") != NULL)
        {
            TerminateProcess(hProc, -1);
            count++;
        }
        if (StrStr(buff, L"firefox.exe") != NULL)
        {
            TerminateProcess(hProc, -1);
            count++;
        }
    }
    wprintf(L"Round %lld: %d application closed\n", lParam, count);
    return TRUE;
}

int main() {
    int count = 0;
    hHeap = GetProcessHeap();
    hStdin = GetStdHandle(STD_INPUT_HANDLE);
    hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    while(1)
    {
        EnumWindows(EnumWindowsProc, ++count);
        Sleep(5000);
    }
}