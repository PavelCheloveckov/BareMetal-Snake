# Snake ISO (IMG) - Модульная змейка

## Общая информация
- **Проект:** Модульный Game ISO с загрузкой через Ventoy (Legacy BIOS) и floppy-образ для эмуляторов.
- **Дата сборки:** 18 июня 2026 г.
- **Платформа:** x86 Legacy BIOS (тестировалось на X79, Limbo, v86, RetroArch, iSH).
- **Окружение сборки:** Termux на Android (aarch64), iSH на iOS, clang/lld, Python, PyCdlib.

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
| `README.md` | Этот файл документации. |

## Как собрать ISO (для Ventoy)
```bash
python3 build_modular.py
```
Готовый `snake.iso` появится в текущей папке и скопируется в `/sdcard/`.

## Как собрать floppy (для эмуляторов)
```bash
python3 build_floppy.py
```
Готовый `floppy.img` (1.44MB) появится в текущей папке.

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
- **v1-v5:** Базовая змейка, яблоки, таймер, улучшенное управление (CD-ROM only).
- **v6 (текущая):** Добавлен floppy-loader для совместимости с эмуляторами. Теперь можно тестировать без OTG-кабеля.
