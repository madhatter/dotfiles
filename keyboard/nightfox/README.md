# NightFox Keyboard Configuration

## Background

The Input Club NightFox ships with the [kiibohd firmware](https://github.com/kiibohd/controller)
and was originally configured via the web-based kiibohd configurator at
`configurator.input.club`. That service is no longer available — Input Club has
shut down and the domain has since been sold.

While the configurator's source code is [still on GitHub](https://github.com/kiibohd/configurator),
the last release dates from 2020 and there is no Apple Silicon support. Running it
locally requires either Rosetta 2 or a complex Docker-based setup to host the
kiibohd build server (`kiisrv`) that the configurator depends on.

The KLL JSON files in this directory (`true-pokr.json` etc.) are the original
configs from the kiibohd configurator and remain the source of truth for the
key layout. To make them usable going forward, `convert_to_qmk.py` converts
them to a QMK keymap — giving full control over the firmware without depending
on any external service.

## Why QMK

The NightFox is hardware-identical to the WhiteFox (same MCU: `mk20dx256vlh7`,
same key matrix). It was never a separate firmware target — even in the kiibohd
configurator, NightFox users selected "WhiteFox". QMK has a maintained WhiteFox
definition (`input_club/whitefox`) that works on the NightFox.

The tradeoff: per-key RGB is not supported by the QMK WhiteFox port. The LEDs
will be off. Basic keyboard functionality is fully supported.

See `qmk_whitefox_layout.md` for details on the coordinate mapping between the
KLL JSON format and QMK's `LAYOUT_all` macro.

## Files

| File | Purpose |
|------|---------|
| `true-pokr.json` | KLL config — source of truth for the key layout |
| `true-pokr-alt.json` | Variant with Alt and GUI swapped (Mac modifier order) |
| `true-pokr-bs.json` | Variant with Backspace moved to top-right area |
| `convert_to_qmk.py` | Converts a KLL JSON to a QMK `keymap.c` |
| `qmk_whitefox_layout.md` | Documents the QMK `LAYOUT_all` key order and coordinate mapping |

## Workflow

### 1. Edit the layout

Make changes to `true-pokr.json` directly, or re-run the converter after
editing and regenerate the keymap.

### 2. Convert to QMK keymap

```bash
python3 convert_to_qmk.py true-pokr.json keymap.c
```

### 3. Set up QMK (first time only)

```bash
brew install qmk/qmk/qmk
qmk setup
```

`qmk setup` clones the QMK firmware repository to `~/qmk_firmware` by default.

### 4. Install the keymap

Create a directory for your keymap inside the QMK WhiteFox keyboard definition
and copy the generated file there:

```bash
mkdir -p ~/qmk_firmware/keyboards/input_club/whitefox/keymaps/nightfox
cp keymap.c ~/qmk_firmware/keyboards/input_club/whitefox/keymaps/nightfox/
```

### 5. Compile and flash

Connect the keyboard **directly** to your Mac (not through a monitor or USB hub —
the keyboard briefly changes USB mode during flashing and hubs can cause the
connection to drop).

Then run:

```bash
make -C ~/qmk_firmware input_club/whitefox:nightfox:flash
```

When prompted, put the keyboard into flash mode by pressing **Fn+ESC**
(mapped to `QK_BOOT` in the keymap). QMK will detect the keyboard in DFU
mode and flash it automatically.

## Layer overview

| Layer | How to activate | Purpose |
|-------|----------------|---------|
| 0 | always | Base QWERTY |
| 1 | hold CapsLock position or right Fn key | Fn layer: F-keys, navigation, media |
| 2 | Fn+`.` (toggles) | Mac mode: Alt and GUI swapped |
| 3 | hold Fn while Mac mode is active | Fn layer in Mac mode |

### Fn layer (layer 1) navigation

```
Y=BS   U=Home  I=PgUp  O=PgDn  P=End
       H=Left  J=Down  K=Up    L=Right
```
