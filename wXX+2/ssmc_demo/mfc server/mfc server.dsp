# Microsoft Developer Studio Project File - Name="mfc server" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=mfc server - Win32 Unicode Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mfc server.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mfc server.mak" CFG="mfc server - Win32 Unicode Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mfc server - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "mfc server - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "mfc server - Win32 Unicode Debug" (based on "Win32 (x86) Application")
!MESSAGE "mfc server - Win32 Unicode Release" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mfc server - Win32 Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W4 /GX /O2 /I "..\mfc common\\" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 ws2_32.lib /nologo /subsystem:windows /machine:I386 /libpath:"..\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=Copying exe...
PostBuild_Cmds=mkdir ..\bin 2> nul	copy ".\Release\mfc server.exe" ..\bin\serverA.exe
# End Special Build Tool

!ELSEIF  "$(CFG)" == "mfc server - Win32 Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W4 /Gm /GX /ZI /Od /I "..\mfc common\\" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ws2_32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept /libpath:"..\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=Copying exe...
PostBuild_Cmds=mkdir ..\bin 2> nul	copy ".\Debug\mfc server.exe" ..\bin\serverA.exe
# End Special Build Tool

!ELSEIF  "$(CFG)" == "mfc server - Win32 Unicode Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "mfc_server___Win32_Unicode_Debug"
# PROP BASE Intermediate_Dir "mfc_server___Win32_Unicode_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Unicode_Debug"
# PROP Intermediate_Dir "Unicode_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W4 /Gm /GX /ZI /Od /I "..\mfc common\\" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W4 /Gm /GX /ZI /Od /I "..\mfc common\\" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ws2_32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept /libpath:"..\lib"
# ADD LINK32 ws2_32.lib /nologo /entry:"wWinMainCRTStartup" /subsystem:windows /debug /machine:I386 /pdbtype:sept /libpath:"..\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=Copying exe...
PostBuild_Cmds=mkdir ..\bin 2> nul	copy ".\Unicode_Debug\mfc server.exe" ..\bin\serverU.exe
# End Special Build Tool

!ELSEIF  "$(CFG)" == "mfc server - Win32 Unicode Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "mfc_server___Win32_Unicode_Release"
# PROP BASE Intermediate_Dir "mfc_server___Win32_Unicode_Release"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Unicode_Release"
# PROP Intermediate_Dir "Unicode_Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W4 /GX /O2 /I "..\mfc common\\" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W4 /GX /O2 /I "..\mfc common\\" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_UNICODE" /D "UNICODE" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ws2_32.lib /nologo /subsystem:windows /machine:I386 /libpath:"..\lib"
# ADD LINK32 ws2_32.lib /nologo /entry:"wWinMainCRTStartup" /subsystem:windows /machine:I386 /libpath:"..\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=Copying exe...
PostBuild_Cmds=mkdir ..\bin 2> nul	copy ".\Unicode_Release\mfc server.exe" ..\bin\serverU.exe
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "mfc server - Win32 Release"
# Name "mfc server - Win32 Debug"
# Name "mfc server - Win32 Unicode Debug"
# Name "mfc server - Win32 Unicode Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\About.cpp
# End Source File
# Begin Source File

SOURCE="..\mfc common\Clipboard.cpp"
# End Source File
# Begin Source File

SOURCE=".\mfc server.cpp"
# End Source File
# Begin Source File

SOURCE=".\mfc server.rc"
# End Source File
# Begin Source File

SOURCE=".\mfc serverDlg.cpp"
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcException.cpp"
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcHostInfo.cpp"
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcSocket.cpp"
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE=.\ssmcThread.cpp
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE=.\ssmcThreadData.cpp
# ADD CPP /Yu
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE="..\mfc common\XHyperLink.cpp"
# End Source File
# Begin Source File

SOURCE="..\mfc common\XListBox.cpp"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\About.h
# End Source File
# Begin Source File

SOURCE="..\mfc common\Clipboard.h"
# End Source File
# Begin Source File

SOURCE=".\mfc server.h"
# End Source File
# Begin Source File

SOURCE=".\mfc serverDlg.h"
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcException.h"
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcHostInfo.h"
# End Source File
# Begin Source File

SOURCE="..\mfc common\ssmcSocket.h"
# End Source File
# Begin Source File

SOURCE=.\ssmcThread.h
# End Source File
# Begin Source File

SOURCE=.\ssmcThreadData.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# Begin Source File

SOURCE="..\mfc common\XHyperLink.h"
# End Source File
# Begin Source File

SOURCE="..\mfc common\XListBox.h"
# End Source File
# Begin Source File

SOURCE="..\mfc common\XTrace.h"
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE="..\mfc common\hans.ico"
# End Source File
# End Group
# Begin Source File

SOURCE="..\mfc common\app.manifest"
# End Source File
# End Target
# End Project
