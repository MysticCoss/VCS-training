nasm -f elf -g helloworld.asm -o helloworld.o
ld -m elf_i386 helloworld.o -o helloworld