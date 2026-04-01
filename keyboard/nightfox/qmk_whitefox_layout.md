# QMK WhiteFox LAYOUT_all Reference

## Purpose

This file documents the `LAYOUT_all` macro key order for the QMK WhiteFox keyboard
definition. It is used by `convert_to_qmk.py` to map KLL JSON positions to QMK
keymap positions.

The NightFox is hardware-identical to the WhiteFox (same MCU: `mk20dx256vlh7`,
same key matrix), differing only in per-key RGB LEDs which are not supported by
this QMK port. In the original kiibohd configurator, NightFox users also selected
"WhiteFox" — there was never a separate NightFox firmware definition.

## Source

Extracted from:
`keyboards/input_club/whitefox/keyboard.json` in `qmk/qmk_firmware` on GitHub.

## Coordinate System

QMK uses keycap-width units where 1u = one standard key width.
KLL JSON uses quarter-unit values — divide KLL `x`/`y` by 4 to get QMK coordinates.

Example: KLL `x=6, y=4` → QMK `x=1.5, y=1` (the Q key)

**Known discrepancy:** The right Fn key (bottom row) sits at KLL x=45 (→ 11.25u)
but at QMK x=11. This 0.25u difference is a layout definition inconsistency between
kiibohd and QMK. `convert_to_qmk.py` handles this with tolerance-based matching.

## LAYOUT_all Key Order

`LAYOUT_all` supports all WhiteFox layout variants (TrueFox, Aria, Vanilla, etc.).
It has 71 positions total. Positions with no key in the TrueFox variant become
`KC_TRNS` in the generated keymap.

Keys are listed in the order they appear as arguments to `LAYOUT_all(...)`.

### Row y=0 — Number row (16 keys)

| Index | x    | Physical key (TrueFox) |
|-------|------|------------------------|
| 0     | 0    | ESC                    |
| 1     | 1    | 1                      |
| 2     | 2    | 2                      |
| 3     | 3    | 3                      |
| 4     | 4    | 4                      |
| 5     | 5    | 5                      |
| 6     | 6    | 6                      |
| 7     | 7    | 7                      |
| 8     | 8    | 8                      |
| 9     | 9    | 9                      |
| 10    | 10   | 0                      |
| 11    | 11   | -                      |
| 12    | 12   | =                      |
| 13    | 13   | \                      |
| 14    | 14   | `                      |
| 15    | 15   | HOME                   |

### Row y=1 — QWERTY row (15 keys)

| Index | x     | w   | Physical key (TrueFox) |
|-------|-------|-----|------------------------|
| 16    | 0     | 1.5 | TAB                    |
| 17    | 1.5   | 1   | Q                      |
| 18    | 2.5   | 1   | W                      |
| 19    | 3.5   | 1   | E                      |
| 20    | 4.5   | 1   | R                      |
| 21    | 5.5   | 1   | T                      |
| 22    | 6.5   | 1   | Y                      |
| 23    | 7.5   | 1   | U                      |
| 24    | 8.5   | 1   | I                      |
| 25    | 9.5   | 1   | O                      |
| 26    | 10.5  | 1   | P                      |
| 27    | 11.5  | 1   | [                      |
| 28    | 12.5  | 1   | ]                      |
| 29    | 13.5  | 1.5 | BACKSPACE              |
| 30    | 15    | 1   | DELETE                 |

### Row y=2 — Home row (15 keys)

| Index | x     | w    | Physical key (TrueFox)        |
|-------|-------|------|-------------------------------|
| 31    | 0     | 1.75 | FN / CapsLock position        |
| 32    | 1.75  | 1    | A (disabled on base layer)    |
| 33    | 2.75  | 1    | S                             |
| 34    | 3.75  | 1    | D                             |
| 35    | 4.75  | 1    | F                             |
| 36    | 5.75  | 1    | G                             |
| 37    | 6.75  | 1    | H                             |
| 38    | 7.75  | 1    | J                             |
| 39    | 8.75  | 1    | K                             |
| 40    | 9.75  | 1    | L                             |
| 41    | 10.75 | 1    | ;                             |
| 42    | 11.75 | 1    | '                             |
| 43    | 12.75 | 1    | ENTER                         |
| 44    | 13.75 | 1.25 | (unused in TrueFox → KC_TRNS) |
| 45    | 15    | 1    | PAGE UP                       |

### Row y=3 — Shift row (15 keys)

| Index | x     | w    | Physical key (TrueFox)           |
|-------|-------|------|----------------------------------|
| 46    | 0     | 1.25 | LSHIFT (2.25u in TrueFox)        |
| 47    | 1.25  | 1    | (split shift pos → KC_TRNS)      |
| 48    | 2.25  | 1    | Z                                |
| 49    | 3.25  | 1    | X                                |
| 50    | 4.25  | 1    | C                                |
| 51    | 5.25  | 1    | V                                |
| 52    | 6.25  | 1    | B                                |
| 53    | 7.25  | 1    | N                                |
| 54    | 8.25  | 1    | M                                |
| 55    | 9.25  | 1    | ,                                |
| 56    | 10.25 | 1    | .                                |
| 57    | 11.25 | 1    | /                                |
| 58    | 12.25 | 1.75 | RSHIFT                           |
| 59    | 14    | 1    | UP                               |
| 60    | 15    | 1    | PAGE DOWN                        |

### Row y=4 — Bottom row (10 keys)

| Index | x     | w    | Physical key (TrueFox)                      |
|-------|-------|------|---------------------------------------------|
| 61    | 0     | 1.25 | LCTRL                                       |
| 62    | 1.25  | 1.25 | LALT (LGUI in Mac variant)                  |
| 63    | 2.5   | 1.25 | LGUI (LALT in Mac variant)                  |
| 64    | 3.75  | 6.25 | SPACE                                       |
| 65    | 10    | 1    | RALT                                        |
| 66    | 11    | 1    | FN (right) — KLL x=11.25, matched by ±0.26 |
| 67    | 12    | 1    | (unused in TrueFox → KC_TRNS)               |
| 68    | 13    | 1    | LEFT                                        |
| 69    | 14    | 1    | DOWN                                        |
| 70    | 15    | 1    | RIGHT                                       |
