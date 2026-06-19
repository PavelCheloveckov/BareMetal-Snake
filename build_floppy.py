import subprocess
import os

subprocess.run(['clang', '-target', 'i386-pc-elf', '-c', 'loader_floppy.s', '-o', 'loader_floppy.o'], check=True)
subprocess.run(['ld', '-m', 'elf_i386', '--oformat', 'binary', '--image-base=0', '-Ttext=0x7C00', 'loader_floppy.o', '-o', 'loader_floppy.bin'], check=True)
assert os.path.getsize('loader_floppy.bin') == 512, "Loader должен быть ровно 512 байт"

with open('loader_floppy.bin', 'rb') as f:
    loader = f.read()
with open('snake.bin', 'rb') as f:
    snake = f.read()

floppy = loader + snake
floppy = floppy.ljust(1474560, b'\x00')  # 1.44 MB

with open('floppy.img', 'wb') as f:
    f.write(floppy)

print(f" floppy.img создан: {len(floppy)} байт")
print("Чтобы запустить в эмуляторе, нужно скопировать образ в /sdcard/Download/ и грузить в Limbo/v86 как Floppy")
