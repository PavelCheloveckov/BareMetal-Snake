# Snake ISO (IMG) - Модульная змейка (форкнута из кодовой базы [andrewrush](https://github.com/andrewrush))

## Общая информация
- **Проект:** Модульный Game ISO с загрузкой через Ventoy (Legacy BIOS) и floppy-образ для эмуляторов.
- **Дата сборки:** 22 июня 2026 г.
- **Платформа:** x86 Legacy BIOS (тестировалось на X79, Limbo, v86, RetroArch, iSH).
- **Окружение сборки:** Termux на Android (aarch64), iSH на iOS, clang/lld, Make,  Python, PyCdlib.

## Что работает
- **Legacy BIOS (CD-ROM):** ISO загружается через Ventoy, запускается loader_cd, игра в 0x8000.
- **Floppy-образ:** Работает в Limbo, v86, Bochs, RetroArch, iSH. Loader читает следующие 8 секторов через INT 13h AH=02h (CHS).
- **Змейка:**
  - Управление стрелками (нельзя повернуть назад).
  - Случайное появление красного яблока (символ сердца).
  - При поедании яблока змейка увеличивается на 1 сегмент.
  - Таймерная задержка через BIOS-тики (0x46C), 3 тика (~165 мс) на шаг.
  - Wrap по границам экрана.
  - Улучшенное управление (цикл опроса клавиатуры).

## Файлы в резервной копии
| Файл | Назначение |
|------|------------|
| `loader_cd.s` | Загрузчик для CD-ROM (INT 13h AH=42h, LBA). |
| `loader_floppy.s` | Загрузчик для floppy (INT 13h AH=02h, CHS). |
| `snake_game.s` | Исходный код игры (16-битный real mode). |
| `build_modular.py` | Скрипт сборки ISO через PyCdlib. |
| `build_floppy.py` | Скрипт сборки floppy-образа 1.44MB. |
| `README.md` | Этот файл документации (распределение на [en](README_en.md) и [ru](README_ru.md) версии).|



## Как собрать ISO (для Ventoy)
```bash
Make snake
```
Готовый `snake.iso` появится в текущей папке и скопируется в `/sdcard/`.

## Как собрать floppy (для эмуляторов)
```bash
Make floppy
```
Готовый `floppy.img` (1.44MB) появится в текущей папке.

## Как собрать на Windows (или на иных не Unix-подобных ОС)

Для сборки через Make рекомендуется использовать MSYS2 или WSL (Ubuntu).

Если же Вы не хотите скачивать окружение для работы с Linux, используйте эти команды: 
```cmd
python3 build_modular.py
```
Для сборки `snake.iso`.

```cmd
python3 build_floppy.py
```
Для  сборки `floppy.img`.

## Запуск в эмуляторах

<details>
<summary><b>Limbo PC Emulator</b></summary>

1. Storage → Floppy A → указать `floppy.img`
2. Boot Settings → Boot order → Floppy первым
3. RAM: 32 MB, Architecture: x86
4. Start

</details>

<details>
<summary><b>RetroArch</b></summary>

1. Загрузить контент → Открыть... → указать `floppy.img`
2. Выбрать `DOS (DOSBox-Pure)`
3. После запуска DOSBox нажать `B` → выбрать `SVGA` → нажать `B`

</details>

<details>
<summary><b>iSH Shell</b></summary>

## ТЕСТИРОВАНИЕ В ПРОЦЕССЕ
</details>

<details>
<summary><b>v86 (браузер)</b></summary>
  
1. Открыть https://copy.sh/v86/
2. Floppy disk image → выбрать `floppy.img`
3. Start
</details>

## История версий
- **v0.1-v0.5:** Базовая змейка, яблоки, таймер, улучшенное управление (CD-ROM only).
- **v0.6:** Добавлен floppy-loader для совместимости с эмуляторами. Теперь можно тестировать без OTG-кабеля.
- **v1.0:** Синтаксис GAS изменен с AT&T на Intel, добавлена сборка через `Make`. Также была добавлена ветка vga-test (не рекомендуется запускать).