nasm -f win64 -o b3_w.obj b3_w.asm 
.\GoLink /files /console /debug coff b3_w.obj kernel32.dll user32.dll
cmd /k