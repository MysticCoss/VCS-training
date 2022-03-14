nasm -f win64 -o b4_w.obj b4_w.asm 
.\GoLink /files /console /debug coff b4_w.obj kernel32.dll user32.dll
cmd /k