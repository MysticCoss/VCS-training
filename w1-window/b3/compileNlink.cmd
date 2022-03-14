nasm -f win64 -g -o uppercase.obj uppercase.asm
GoLink /files /console uppercase.obj kernel32.dll