nasm -f win64 -o helloworld.obj helloworld.asm
GoLink /files /console helloworld.obj kernel32.dll user32.dll