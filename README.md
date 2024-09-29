# Viz: A Completely Graphical Programming Environment

## Goals

- Show a visual, block-based representation of logic and data
- Output raw machine code to a file (possibly just ELF in the meantime)
- Compile it in itself (that means no text-based programming languages)

## Inspirations

- [Subtext](https://www.subtext-lang.org/)
- [Kronark](https://www.youtube.com/@Kronark)
- [Visual Language Proposal](https://coda.io/@xananax/visual-language-proposal)
- ["Zoom Out": The missing feature of IDEs](https://medium.com/source-and-buggy/zoom-out-the-missing-feature-of-ides-f32d0f36f392)

## Editor Design

- There will be a limited number of primitive blocks like input, output, etc.
- There will be an output block that will receive bytes and output them to a file.
- The interface will be keyboard-first, but with the option of using a mouse.
- You can never delete the output. This is the root of every program, it must output to a file so it can be executable.

## Stretch goals

- Standardized source format
  - It will be a binary format (as it will be decoded by visual tools rather than plaintext as an intermediate step)
- Many targets
  - Archtectures
  - Platforms
  - Executable formats
  - Dynamic Libraries
  - Static Libraries
- Use it to write advanced projects
  - Bootloader
  - OS kernel
  - Drivers
    - USB
    - PCIe
    - Keyboard
    - Mouse
    - Display
  - Filesystems
    - FAT32
    - NTFS
    - EXT4
    - APFS
    - Others
  - Optimizing Compiler
  - Debugger
  - Linker
  - Virtual Machine / Emulator
  - Version Control

Finally, I wanna be able to bootstrap this thing on a minimal environment. 

That means:
1. Plug in a USB stick
2. Boot into the USB
3. Run the editor
3. Edit the source of the editor
4. Compile it
5. Run the new editor
