FILENAME = hack
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

debug: clean
	@nasm -g -f elf64 -o debug.obj -l debug.list $(ASM)
	@ld -o debug  debug.obj


clean:
	@rm -f $(OBJ)
	@rm -f $(LST)
	@rm -f debug.o
	@rm -f debug.list
	@rm -f debug
	@rm -f debug.obj