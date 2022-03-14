nasm -f win64 -g -o b2_w.obj b2_w.asm 
.\GoLink /files /console /debug coff b2_w.obj kernel32.dll user32.dll