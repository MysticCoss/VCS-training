nasm -f win64 -g -o b2_w.obj b2_w.asm 
.\GoLink /files /debug coff b2_w.obj kernel32.dll shell32.dll User32.dll Gdi32.dll