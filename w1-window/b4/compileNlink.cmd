nasm -f win32 -g -o add.obj add.asm
GoLink /files /console add.obj kernel32.dll user32.dll msvcrt.dll