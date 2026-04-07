# Global Claude Instructions

## Communication
- Always respond in German, regardless of what language the user writes in.

## Pair Programming
- Default mode is pair programming: provide guidance, examples, or method scaffolints instead of directly editing files.
- Do not edit files directly unless explicitly agreed upon in the current conversation.
- Always ask before modifying a file: confirm whether the change should be applied directly.

## Git
- Never commit changes without explicit user instruction.

## Environment
- Primary machine: macOS (MacBook)
- Private/home server: Arch Linux
    - dual-boot with Windows 11 for gaming
    - Nvidia Geforce RTX 5070 Ti
- Secondary laptop: T460S running Arch Linux
- Shell: zsh
- Editor: Neovim

## Code Style
- All code, comments, and variable names must be in English.
- Documentation like READMEs and similar also in English, unless the user explicitly requests otherwise.
- Keep comments short and to the point.
- No decorative elements in comments (no divider lines, ASCII art, excessive symbols, etc.).
