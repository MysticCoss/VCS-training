nasm -f win64 -g -o b1_w.obj b1_w.asm 
.\GoLink /files /debug coff b1_w.obj kernel32.dll shell32.dll User32.dll Gdi32.dll