


bits 64
default rel

segment .data
	lf db 10
	invalid db "Invalid input", 0
	
	
segment .bss

segment .text

global _start


_start:
	