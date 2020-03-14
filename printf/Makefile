FILENAME = printf
ASM = $(FILENAME).asm
OBJ = $(FILENAME).obj
LST = $(FILENAME).lst
OUT = $(FILENAME)

all: build clean

build: elf

object:  $(ASM)
	@nasm -f elf64 -o $(OBJ) $(ASM)

elf:   object
	@ld -s -o $(OUT) $(OBJ) 
	@chmod +x $(OUT)

debug:
	@nasm -g -f elf -o debug.obj -l debug.list ASM
	@ld -m elf_i386 -o debug -p  debug.obj


clean:
	@rm -f $(OBJ)
	@rm -f $(LST)
	@rm -f $(debug.o)
	@rm -f $(debug.list)
	@rm -f $(debug)