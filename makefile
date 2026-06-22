PYTHON = python3
AS = as
ASFLAGS = --32
OBJCOPY = objcopy
OBJCOPY_FLAGS = -O binary

all: floppy iso

setup:
	$(PYTHON) -m pip install pycdlib --break-system-packages

floppy: loader_floppy.bin snake.bin
	$(PYTHON) build_floppy.py

iso: loader_cd.bin snake.bin
	$(PYTHON) build_modular.py

loader_floppy.bin: loader_floppy.s
	$(AS) $(ASFLAGS) loader_floppy.s -o loader_floppy.o
	$(OBJCOPY) $(OBJCOPY_FLAGS) loader_floppy.o loader_floppy.bin

loader_cd.bin: loader_cd.s
	$(AS) $(ASFLAGS) loader_cd.s -o loader_cd.o
	$(OBJCOPY) $(OBJCOPY_FLAGS) loader_cd.o loader_cd.bin

snake.bin: snake_game.s
	$(AS) $(ASFLAGS) snake_game.s -o snake_game.o
	$(OBJCOPY) $(OBJCOPY_FLAGS) snake_game.o snake.bin

clean:
	rm -f *.o *.bin *.img *.iso

.PHONY: all floppy iso clean setup
