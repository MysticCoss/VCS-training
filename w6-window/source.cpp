#include <Windows.h>
#include <cstdio>
#include <Psapi.h>
#include <Shlwapi.h>
HANDLE hHeap;
HANDLE hStdin;
HANDLE hStdout;
int count = 0;
int closed = 0;
BOOL CALLBACK EnumWindowsProc(HWND hWnd, LPARAM lParam) {
    LPVOID buff = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, 2000);
    DWORD pid;
    GetWindowThreadProcessId(hWnd, &pid);
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE, FALSE, pid);
    
    if (GetModuleFileNameEx(hProc,NULL, (LPWSTR)buff, 1000) > 0)
    {
        if (StrStr((PCWSTR)buff,L"chrome.exe")!=NULL)
        {
            TerminateProcess(hProc, -1);
            closed++;
        }
        if (StrStr((PCWSTR)buff, L"msedge.exe") != NULL)
        {
            TerminateProcess(hProc, -1);
            closed++;
        }
        if (StrStr((PCWSTR)buff, L"firefox.exe") != NULL)
        {
            TerminateProcess(hProc, -1);
            closed++;
        }
    }
    
    return TRUE;
}

int main() {
    
    hHeap = GetProcessHeap();
    hStdin = GetStdHandle(STD_INPUT_HANDLE);
    hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
    while(1)
    {
        EnumWindows(EnumWindowsProc,0);
        wprintf_s(L"Round %d: %d process closed\n", ++count, closed);
        closed = 0;
        Sleep(5000);
    }
}