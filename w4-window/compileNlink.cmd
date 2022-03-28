nasm -f win64 -g -o b1_w.obj b1_w.asm 
.\GoLink /files /console /debug dbg b1_w.obj kernel32.dll shell32.dll Crypt32.dll