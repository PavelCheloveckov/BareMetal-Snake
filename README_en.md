# Snake ISO (IMG) - Modular snake (forked from the [andrewrush](https://github.com/andrewrush) codebase)

## General information
- **Project:** Modular Game ISO with download via Ventoy (Legacy BIOS) and floppy image for emulators.
- **Date of build:** June 22, 2026
- **Platform:** x86 Legacy BIOS (tested on X79, Limbo, v86, RetroArch, iSH).
- **The Build environment:** Termux on Android (aarch64), iSH on iOS, clang/lld, Make, Python, PyCdlib.

## What works
- **Legacy BIOS (CD-ROM):** The ISO is loaded via Ventoy, loader_cd is started, the game is at 0x8000.
- **Floppy image:** Works in Limbo, v86, Bochs, RetroArch, iSH. Loader reads the next 8 sectors via INT 13h AH=02h (CHS).
- **Snake:**
- Arrow control (you cannot turn back).
  - Random appearance of a red apple (heart symbol).
  - When eating an apple, the snake increases by 1 segment.
  - Timer delay via BIOS-ticks (0x46C), 3 ticks (~165 ms) per step.
  - Wrap around the borders of the screen.
  - Improved control (keyboard polling cycle).

## Files in the backup
| File | Purpose |
|------|------------|
| `loader_cd.s` | Bootloader for CD-ROM (INT 13h AH=42h, LBA). |
| `loader_floppy.s` | Loader for floppy (INT 13h AH=02h, CHS). |
| `snake_game.s` | The source code of the game (16-bit real mode). |
| `build_modular.py` | The ISO build script via PyCdlib. |
| `build_floppy.py` | The script for building a 1.44MB floppy image. |
| `README.md` | This documentation file (distribution on [en](README_en.md) and [ru](README_ru.md) versions).|

## How to build an ISO (for Ventoy)
```bash
Make snake
```
Ready `snake.iso` will appear in the current folder and will be copied to `/sdcard/`.

## How to build floppy (for emulators)
```bash
Make floppy
```
The finished `floppy.img` (1.44MB) will appear in the current folder.

## How to build on Windows (or other non-Unix-like OS)

It is recommended to use MSYS2 or WSL (Ubuntu) to build via Make.

If you do not want to download a Linux environment, use these commands: 
```cmd
python3 build_modular.py
```
For build `snake.iso`.

```cmd
python3 build_floppy.py
```
For build `floppy.img`.

## Running in emulators

<details>
<summary><b>Limbo PC Emulator</b></summary>

1. Storage → Floppy A → specify `floppy.img`
2. Boot Settings → Boot order → Floppy first
3. RAM: 32 MB, Architecture: x86
4. Start

</details>

<details>
<summary><b>RetroArch</b></summary>

1. Upload content → Open... → specify `floppy.img`
2. Select `DOS (DOSBox-Pure)`
3. After launching DOSBox, press `B` → select `SVGA` → press `B`

</details>

<details>
<summary><b>iSH Shell</b></summary>

## TESTING IN PROGRESS
</details>

<details>
<summary><b>v86 (browser)</b></summary>
  
1. Open https://copy.sh/v86/
2. Floppy disk image → select `floppy.img`
3. Start
</details>

## Version history
- **v0.1-v0.5:** Basic snake, apples, timer, improved controls (CD-ROM only).
- **v0.6:** Added floppy loader for compatibility with emulators. Now you can test without an OTG cable.
- **v1.0:** The GAS syntax has been changed from AT&T to Intel, and build via `Make` has been added. The vga-test branch has also been added (it is not recommended to run).