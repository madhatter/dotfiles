#!/usr/bin/env python3
"""Convert a KLL JSON config to a QMK keymap.c for NightFox / WhiteFox.

The NightFox uses the QMK `input_club/whitefox` keyboard definition — see
qmk_whitefox_layout.md for details on the coordinate mapping and known quirks.

Usage:
    python3 convert_to_qmk.py true-pokr.json           # writes to stdout
    python3 convert_to_qmk.py true-pokr.json keymap.c  # writes to file
"""

import json
import sys
from pathlib import Path

# LAYOUT_all positions in macro argument order: (x, y) in QMK keycap-width units.
# Source: keyboards/input_club/whitefox/keyboard.json in qmk/qmk_firmware
# KLL JSON coordinates divide by 4 to get these values.
LAYOUT_ALL = [
    # y=0: number row (16 keys)
    ( 0,     0), ( 1,     0), ( 2,     0), ( 3,     0), ( 4,     0), ( 5,     0),
    ( 6,     0), ( 7,     0), ( 8,     0), ( 9,     0), (10,     0), (11,     0),
    (12,     0), (13,     0), (14,     0), (15,     0),
    # y=1: QWERTY row (15 keys)
    ( 0,     1), ( 1.5,   1), ( 2.5,   1), ( 3.5,   1), ( 4.5,   1), ( 5.5,   1),
    ( 6.5,   1), ( 7.5,   1), ( 8.5,   1), ( 9.5,   1), (10.5,   1), (11.5,   1),
    (12.5,   1), (13.5,   1), (15,     1),
    # y=2: home row (15 keys)
    ( 0,     2), ( 1.75,  2), ( 2.75,  2), ( 3.75,  2), ( 4.75,  2), ( 5.75,  2),
    ( 6.75,  2), ( 7.75,  2), ( 8.75,  2), ( 9.75,  2), (10.75,  2), (11.75,  2),
    (12.75,  2), (13.75,  2), (15,     2),
    # y=3: shift row (15 keys)
    ( 0,     3), ( 1.25,  3), ( 2.25,  3), ( 3.25,  3), ( 4.25,  3), ( 5.25,  3),
    ( 6.25,  3), ( 7.25,  3), ( 8.25,  3), ( 9.25,  3), (10.25,  3), (11.25,  3),
    (12.25,  3), (14,     3), (15,     3),
    # y=4: bottom row (10 keys)
    ( 0,     4), ( 1.25,  4), ( 2.5,   4), ( 3.75,  4), (10,     4), (11,     4),
    (12,     4), (13,     4), (14,     4), (15,     4),
]

ROW_NAMES = {0: 'number row', 1: 'QWERTY row', 2: 'home row', 3: 'shift row', 4: 'bottom row'}

KLL_TO_QMK = {
    # Letters
    **{c: f'KC_{c}' for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'},
    # Numbers
    **{str(n): f'KC_{n}' for n in range(1, 10)},
    '0': 'KC_0',
    # Punctuation
    '-':    'KC_MINS',
    '=':    'KC_EQL',
    '[':    'KC_LBRC',
    ']':    'KC_RBRC',
    '\\':   'KC_BSLS',
    '`':    'KC_GRV',
    ';':    'KC_SCLN',
    "'":    'KC_QUOT',
    ',':    'KC_COMM',
    '.':    'KC_DOT',
    '/':    'KC_SLSH',
    # Navigation
    'ESC':        'KC_ESC',
    'TAB':        'KC_TAB',
    'ENTER':      'KC_ENT',
    'SPACE':      'KC_SPC',
    'BACKSPACE':  'KC_BSPC',
    'DELETE':     'KC_DEL',
    'INSERT':     'KC_INS',
    'HOME':       'KC_HOME',
    'END':        'KC_END',
    'PAGEUP':     'KC_PGUP',
    'PAGEDOWN':   'KC_PGDN',
    'UP':         'KC_UP',
    'DOWN':       'KC_DOWN',
    'LEFT':       'KC_LEFT',
    'RIGHT':      'KC_RGHT',
    # Modifiers
    'LSHIFT':  'KC_LSFT',
    'RSHIFT':  'KC_RSFT',
    'LCTRL':   'KC_LCTL',
    'RCTRL':   'KC_RCTL',
    'LALT':    'KC_LALT',
    'RALT':    'KC_RALT',
    'LGUI':    'KC_LGUI',
    'RGUI':    'KC_RGUI',
    # Lock keys
    'CAPSLOCK':   'KC_CAPS',
    'NUMLOCK':    'KC_NUM',
    'SCROLLLOCK': 'KC_SCRL',
    'PRINTSCREEN':'KC_PSCR',
    'PAUSE':      'KC_PAUS',
    # F-keys
    **{f'F{n}': f'KC_F{n}' for n in range(1, 15)},
    # Consumer keys
    'CONS:VOLUMEDOWN': 'KC_VOLD',
    'CONS:VOLUMEUP':   'KC_VOLU',
    'CONS:MUTE':       'KC_MUTE',
    # Layer functions
    'FUNCTION1': 'MO(1)',
    'FUNCTION2': 'MO(2)',
    'FUNCTION3': 'MO(3)',
    'LOCK1':     'TO(1)',
    'LOCK2':     'TO(2)',
    # Special functions
    '#:flashMode()':        'QK_BOOT',
    '#:ledControl( 5, 255 )': 'RGB_TOG',
    '#:ledControl( 1, 15 )':  'RGB_VAI',
    '#:ledControl( 0, 15 )':  'RGB_VAD',
}

LAYER_NAMES = {
    0: 'Base QWERTY',
    1: 'Fn — hold CapsLock position or right Fn key',
    2: 'Mac mode — Alt and GUI swapped, toggle with Fn+.',
    3: 'Fn in Mac mode',
}


def translate(kll_key):
    if kll_key is None:
        return 'KC_TRNS'
    result = KLL_TO_QMK.get(kll_key)
    if result is None:
        print(f'Warning: unknown KLL keycode "{kll_key}", left as comment', file=sys.stderr)
        return f'/*{kll_key}*/'
    return result


def snap(v):
    """Round to nearest 0.25 to avoid float precision issues."""
    return round(v * 4) / 4


def build_coord_map(kll_data):
    """Build a dict mapping (x, y) in QMK units to the KLL layers dict.

    KLL JSON stores all coordinates in quarter-unit values so that positions
    like 1.5u (TAB width) can be represented as integers (x=6). QMK uses
    real keycap-width units directly (x=1.5). Dividing by 4 converts KLL
    coordinates to QMK coordinates, making the two systems comparable.

    Example:
        KLL  x=6,  y=4  →  QMK  x=1.5, y=1  (the Q key)
        KLL  x=0,  y=8  →  QMK  x=0,   y=2  (CapsLock / Fn position)

    Result: {(qmk_x, qmk_y): {"0": {"key": ..., "label": ...}, "1": ...}, ...}
    """
    coord_map = {}
    for entry in kll_data['matrix']:
        x = snap(entry['x'] / 4)
        y = snap(entry['y'] / 4)
        coord_map[(x, y)] = entry.get('layers', {})
    return coord_map


def find_kll_entry(coord_map, qmk_x, qmk_y, tolerance=0.26):
    """Look up a KLL entry by QMK coordinates, with tolerance for layout quirks."""
    exact = coord_map.get((qmk_x, qmk_y))
    if exact is not None:
        return exact
    # Tolerance pass — handles the right Fn key 0.25u discrepancy (see layout.md)
    for (kx, ky), layers in coord_map.items():
        if ky == qmk_y and abs(kx - qmk_x) <= tolerance:
            return layers
    return {}


def build_layer(coord_map, layer_idx):
    """Return a list of QMK keycodes in LAYOUT_all order for one layer."""
    keys = []
    for (x, y) in LAYOUT_ALL:
        layers_data = find_kll_entry(coord_map, x, y)
        entry = layers_data.get(str(layer_idx))
        keys.append(translate(entry['key'] if entry else None))
    return keys


def format_layer(layer_keys, layer_idx, base_keys):
    """Format one layer as a visual grid with row comments.

    Args:
        layer_keys: list of QMK keycodes in LAYOUT_all order (71 entries)
        layer_idx:  layer number, used for the opening comment and bracket
        base_keys:  layer 0 keycodes in the same order, used as a physical
                    key reference in the comment above each row
    """
    # Pad all keycodes to the same width so columns line up vertically.
    # +1 reserves space for the trailing comma that follows each keycode.
    col_w = max(len(k) for k in layer_keys) + 1

    # Build a dict of {y: [index, ...]} to group LAYOUT_ALL positions into
    # keyboard rows. The y value is the row coordinate (0=number row, etc.).
    rows = {}
    for i, (_, y) in enumerate(LAYOUT_ALL):
        rows.setdefault(y, []).append(i)

    # The very last key in LAYOUT_all(...) must not have a trailing comma.
    last_i = len(LAYOUT_ALL) - 1

    lines = [f'    // {LAYER_NAMES.get(layer_idx, f"Layer {layer_idx}")}']
    lines.append(f'    [{layer_idx}] = LAYOUT_all(')

    for row_y in sorted(rows.keys()):
        indices = rows[row_y]
        row_label = ROW_NAMES.get(int(row_y), f'y={row_y}')

        # Comment line: show the base layer (layer 0) keycode for each position
        # in this row. This acts as a physical key reference when reading or
        # editing fn layers — e.g. you can see "KC_H" and know it means the H key.
        base_names = '  '.join(base_keys[i].ljust(col_w) for i in indices).rstrip()
        lines.append(f'        // {row_label}: {base_names}')

        # Actual keycodes for this layer, comma-separated and column-aligned.
        parts = []
        for i in indices:
            code = layer_keys[i] + ('' if i == last_i else ',')
            parts.append(code.ljust(col_w + 1))  # +1 accounts for the comma
        lines.append('        ' + '  '.join(parts).rstrip())

    lines.append('    ),\n')
    return '\n'.join(lines)


def convert(input_path, output_path=None):
    with open(input_path) as f:
        kll = json.load(f)

    coord_map = build_coord_map(kll)
    layers = [build_layer(coord_map, i) for i in range(4)]
    base_keys = layers[0]

    source_name = Path(input_path).name
    header = f"""\
// Generated by convert_to_qmk.py from {source_name}
// Target: QMK input_club/whitefox — see qmk_whitefox_layout.md for details
//
// Layer overview:
//   0  Base QWERTY
//   1  Fn layer (hold CapsLock position or right Fn key)
//   2  Mac mode: Alt and GUI swapped (toggle Fn+.)
//   3  Fn layer while Mac mode is active

#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {{

"""
    footer = '};\n'
    body = '\n'.join(format_layer(layers[i], i, base_keys) for i in range(4))
    output = header + body + footer

    if output_path:
        with open(output_path, 'w') as f:
            f.write(output)
        print(f'Written to {output_path}', file=sys.stderr)
    else:
        print(output)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <input.json> [output.c]', file=sys.stderr)
        sys.exit(1)
    convert(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
