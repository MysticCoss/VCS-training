nasm -f elf -g echo.asm -o echo.o
ld -m elf_i386 echo.o -o echo