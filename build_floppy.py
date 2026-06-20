import subprocess
import os
import sys

def run(cmd, **kwargs):
    print('Running:', ' '.join(cmd))
    subprocess.run(cmd, check=True, **kwargs)

# 1. Компиляция snake_game.s в snake.bin (если ещё не скомпилирован)
if not os.path.exists('snake.bin'):
    print('snake.bin not found, compiling from snake_game.s...')
    run(['clang', '-target', 'i386-pc-elf', '-c', 'snake_game.s', '-o', 'snake_game.o'])
    run(['ld.lld', '--oformat', 'binary', '--image-base=0', '-Ttext=0x8000', 'snake_game.o', '-o', 'snake_game_raw.bin'])
    with open('snake_game_raw.bin', 'rb') as f:
        data = f.read()
    if len(data) > 4096:
        sys.exit('snake_game.bin too big')
    data = data.ljust(4096, b'\x00')
    with open('snake.bin', 'wb') as f:
        f.write(data)
    print('✅ snake.bin created')
else:
    print('✅ snake.bin found')

# 2. Компиляция loader_floppy.s
run(['clang', '-target', 'i386-pc-elf', '-c', 'loader_floppy.s', '-o', 'loader_floppy.o'])
run(['ld.lld', '--oformat', 'binary', '--image-base=0', '-Ttext=0x7C00', 'loader_floppy.o', '-o', 'loader_floppy.bin'])
assert os.path.getsize('loader_floppy.bin') == 512, "Loader должен быть ровно 512 байт"

# 3. Читаем готовые бинари
with open('loader_floppy.bin', 'rb') as f:
    loader = f.read()
with open('snake.bin', 'rb') as f:
    snake = f.read()

# 4. Склеиваем и дополняем до стандартного размера 1.44МБ
floppy = loader + snake
floppy = floppy.ljust(1474560, b'\x00')  # 1.44 MB = 1474560 байт

# 5. Сохраняем
with open('floppy.img', 'wb') as f:
    f.write(floppy)

print(f"✅ floppy.img создан: {len(floppy)} байт")
print("📁 Скопируй его в /sdcard/Download/ и грузи в Limbo/v86 как Floppy")
