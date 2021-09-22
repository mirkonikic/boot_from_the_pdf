NPROGS = $(wildcard src/prog/*.asm)		#NASM asm syntax
GPROGS = $(wildcard src/prog/*.S)		#GNU asm syntax

nasm:
	nasm -f bin src/boot.asm -o bin/boot.bin
	qemu-system-i386 bin/boot.bin	

gas:	
	gcc -c src/boot.s
	ld boot.o -o bin/boot.bin
	rm boot.o

nprogs:
	nasm -f bin $(NPROGS)

gprogs:
	gcc -c $(GPROGS)
