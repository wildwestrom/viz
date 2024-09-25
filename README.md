# Viz: A Completely Graphical Programming Environment

## Goals

- Show a visual, block-based representation of logic and data
- Output raw machine code to a file (possibly just ELF in the meantime)
- Compile it in itself (that means no text-based programming languages)

## Editor Design

- There will be a limited number of primitive blocks like input, output, etc.
- There will be an output block that will receive bytes and output them to a file.
- The interface will be keyboard-first, but with the option of using a mouse.
- You can never delete the output. This is the root of every program, it must output to a file so it can be executable.

## Stretch goals

- Standardized source format
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
  - Filesystem
  - Optimizing Compiler
  - Debugger
  - Linker
  - Virtual Machine / Emulator

Finally, I wanna be able to bootstrap this thing on a minimal environment. 

That means:
1. Plug in a USB stick
2. Boot into the USB
3. Run the editor
3. Edit the source of the editor
4. Compile it
5. Run the new editor
