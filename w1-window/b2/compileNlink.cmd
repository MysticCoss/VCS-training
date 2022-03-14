nasm -f win64 -g -o ech.obj ech.asm
GoLink /files /console ech.obj kernel32.dll user32.dll