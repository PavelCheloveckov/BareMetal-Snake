import pycdlib
import subprocess
import struct
import os
import sys

def run(cmd, **kwargs):
    print('Running:', ' '.join(cmd))
    subprocess.run(cmd, check=True, **kwargs)

run(['as', '--32', 'snake_game.s', '-o', 'snake_game.o'])
run(['ld', '-m', 'elf_i386', '--oformat', 'binary', '--image-base=0', '-Ttext=0x8000', 'snake_game.o', '-o', 'snake_game_raw.bin'])
with open('snake_game_raw.bin', 'rb') as f:
    data = f.read()
if len(data) > 4096:
    sys.exit('snake_game.bin too big')
data = data.ljust(4096, b'\x00')
with open('snake.bin', 'wb') as f:
    f.write(data)

run(['as', '--32', 'loader_cd.s', '-o', 'loader_cd.o'])
subprocess.run(['ld', '-m', 'elf_i386', '--oformat', 'binary', '--image-base=0', '-Ttext=0x7C00', 'loader_cd.o', '-o', 'loader_cd.bin'], check=True)
assert os.path.getsize('loader_cd.bin') == 512

with open('loader_cd.bin', 'rb') as f:
    loader = f.read()
with open('snake.bin', 'rb') as f:
    snake = f.read()
combined = loader + snake
with open('boot_and_game.bin', 'wb') as f:
    f.write(combined)

iso = pycdlib.PyCdlib()
iso.new(rock_ridge="1.09", joliet=3, interchange_level=4)
iso.add_directory('/BOOT', rr_name='boot')
iso.add_directory('/GAMES', rr_name='games')
iso.add_fp(open('boot_and_game.bin', 'rb'), len(combined), '/BOOT/BOOTIMG.BIN;1', rr_name='bootimg.bin')
iso.add_fp(open('snake.bin', 'rb'), len(snake), '/GAMES/SNAKE.BIN;1', rr_name='snake.bin')
iso.add_eltorito('/BOOT/BOOTIMG.BIN;1', '/BOOT/BOOT.CAT;1', media_name='noemul', platform_id=0, boot_load_size=9)

tmp_iso = 'temp.iso'
iso.write(tmp_iso)
iso.close()

with open(tmp_iso, 'rb') as f:
    f.seek(0x8800)
    cat = f.read(32)
boot_lba = struct.unpack('<I', cat[0x1C:0x20])[0]
game_lba = boot_lba + 1
print(f'Boot LBA: {boot_lba}, Game LBA: {game_lba}')
os.unlink(tmp_iso)

with open('loader_cd.bin', 'r+b') as f:
    f.seek(0x88)
    f.write(struct.pack('<I', game_lba))

with open('loader_cd.bin', 'rb') as f:
    loader = f.read()
combined = loader + snake
with open('boot_and_game.bin', 'wb') as f:
    f.write(combined)

iso = pycdlib.PyCdlib()
iso.new(rock_ridge="1.09", joliet=3, interchange_level=4)
iso.add_directory('/BOOT', rr_name='boot')
iso.add_directory('/GAMES', rr_name='games')
iso.add_fp(open('boot_and_game.bin', 'rb'), len(combined), '/BOOT/BOOTIMG.BIN;1', rr_name='bootimg.bin')
iso.add_fp(open('snake.bin', 'rb'), len(snake), '/GAMES/SNAKE.BIN;1', rr_name='snake.bin')
iso.add_eltorito('/BOOT/BOOTIMG.BIN;1', '/BOOT/BOOT.CAT;1', media_name='noemul', platform_id=0, boot_load_size=9)
iso.write('snake.iso')
iso.close()
print('snake.iso built successfully')

if os.path.exists('/sdcard/'):
    run(['cp', 'snake.iso', '/sdcard/'])
    print('Copied to /sdcard/')
else:
    print('Missing: the /sdcard/ directory was not found.')
