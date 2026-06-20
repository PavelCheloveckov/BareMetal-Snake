import subprocess
import os
import sys

def run(cmd):
    subprocess.run(cmd, check=True)

run(['clang', '-target', 'i386-pc-elf', '-c', 'snake_game.s', '-o', 'snake_game.o'])
run(['ld', '-m', 'elf_i386', '--oformat', 'binary', '--image-base=0', '-Ttext=0x8000', 'snake_game.o', '-o', 'snake_game_raw.bin'])

with open('snake_game_raw.bin', 'rb') as f:
    data = f.read()

if len(data) > 4096:
    sys.exit('Error: snake_game_raw.bin too big')

snake_padded = data.ljust(4096, b'\x00')

run(['clang', '-target', 'i386-pc-elf', '-c', 'loader_floppy.s', '-o', 'loader_floppy.o'])
run(['ld', '-m', 'elf_i386', '--oformat', 'binary', '--image-base=0', '-Ttext=0x7C00', 'loader_floppy.o', '-o', 'loader_floppy.bin'])

assert os.path.getsize('loader_floppy.bin') == 512

with open('loader_floppy.bin', 'rb') as f:
    loader = f.read()

floppy = (loader + snake_padded).ljust(1474560, b'\x00')

with open('floppy.img', 'wb') as f:
    f.write(floppy)

print(f"floppy.img created: {len(floppy)} bytes")
print("Copy it to /sdcard/Download/ and upload it to Limbo/v86 as Floppy\n=========================================================================")
