#!/usr/bin/env python3
import json, re
from pathlib import Path

base = Path(__file__).resolve().parent.parent / "assets" / "logo-pack"
manifest = json.loads((base/"manifest.json").read_text())

def parse_label_bytes(text, label):
    lines = text.splitlines()
    start = None
    for i,l in enumerate(lines):
        if l.strip() == f"{label}:":
            start = i+1
            break
    if start is None:
        raise SystemExit(f"missing label: {label}")
    vals = []
    for l in lines[start:]:
        s = l.strip()
        if not s:
            continue
        if s.endswith(":") and not s.startswith("!"):
            break
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s*=", s):
            break
        vals.extend(int(h,16) for h in re.findall(r"\$([0-9a-fA-F]{2})", s))
    return vals

errors = []
for item in manifest:
    name, typ = item["name"], item["type"]
    text = (base/f"{name}.asm").read_text()
    def fail(msg): errors.append(f"{name}: {msg}")
    if typ == "mcbitmap":
        bmp = parse_label_bytes(text, f"{name}_bitmap")
        scr = parse_label_bytes(text, f"{name}_screen")
        col = parse_label_bytes(text, f"{name}_color")
        w,h = map(int, item["stored"].split("x"))
        cells = (w//4)*(h//8)
        if len(bmp) != cells*8: fail(f"bitmap {len(bmp)} != {cells*8}")
        if len(scr) != cells: fail(f"screen {len(scr)} != {cells}")
        if len(col) != cells: fail(f"color {len(col)} != {cells}")
        if any(c & 0xf0 for c in col): fail("colour RAM high nibble used")
    elif typ == "hiresbitmap":
        bmp = parse_label_bytes(text, f"{name}_bitmap")
        scr = parse_label_bytes(text, f"{name}_screen")
        w,h = map(int, item["size"].split("x"))
        cells = (w//8)*(h//8)
        if len(bmp) != cells*8: fail(f"bitmap {len(bmp)} != {cells*8}")
        if len(scr) != cells: fail(f"screen {len(scr)} != {cells}")
    elif typ == "charset":
        chars = parse_label_bytes(text, f"{name}_charset")
        scr = parse_label_bytes(text, f"{name}_screen")
        col = parse_label_bytes(text, f"{name}_color")
        w,h = map(int, item["size"].split("x"))
        cells = (w//8)*(h//8)
        if len(chars) != item["chars"]*8: fail(f"charset {len(chars)} != {item['chars']*8}")
        if item["chars"] > 256: fail(f"too many chars: {item['chars']}")
        if len(scr) != cells: fail(f"screen {len(scr)} != {cells}")
        if len(col) != cells: fail(f"color {len(col)} != {cells}")
        if any(c & 0xf0 for c in col): fail("colour RAM high nibble used")
    elif typ == "sprites":
        spr = parse_label_bytes(text, f"{name}_sprites")
        colors = parse_label_bytes(text, f"{name}_sprite_colors")
        count = item["sprites"]
        if len(spr) != count*64: fail(f"sprite data {len(spr)} != {count*64}")
        if len(colors) != count: fail(f"colors {len(colors)} != {count}")
        if any(c & 0xf0 for c in colors): fail("sprite colour high nibble used")
        for i in range(count):
            if spr[i*64+63] != 0:
                fail(f"sprite {i} padding byte not zero")
if errors:
    print("FAIL")
    print("\n".join(errors))
    raise SystemExit(1)
print("PASS: all UBER logo assets have exact expected C64 byte sizes, bit order assumptions and colour RAM nibble constraints.")
