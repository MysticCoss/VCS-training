nasm -f elf add.asm -g -o add.o 
ld -m elf_i386 add.o -o add