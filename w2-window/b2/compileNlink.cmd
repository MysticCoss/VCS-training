nasm -f win64 -o b2_w.obj b2_w.asm 
.\GoLink /files /console b2_w.obj kernel32.dll user32.dll
cmd /k