nasm -f elf uppercase.asm -o uppercase.o
ld -m elf_i386 uppercase.o -o uppercase