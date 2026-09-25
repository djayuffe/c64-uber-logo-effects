#!/usr/bin/env python3
from pathlib import Path
import re
import sys
root=Path(__file__).resolve().parent.parent
asm=(root/"c64_uber_logo_effects.asm").read_text()
errors=[]
def req(c,m):
    if not c: errors.append(m)
req("!byte $0d,$08,$0a,$00,$9e,$20,$31,$36,$33,$38,$34,$00,$00,$00" in asm, "BASIC SYS 16384 stub missing/wrong")
req("* = $4000" in asm, "runtime must start at $4000")
for s in ["ShowFullLogo:","TunnelEffect:","CubeEffect:","RenderTunnelFrame:","RenderCubeFrame:","LogoAssetDataBegin:","LogoAssetDataEnd:","!source \"assets/logo-pack/uber_mc_full_320x200.asm\""]:
    req(s in asm, f"missing {s}")
req(re.search(r"^\s*cli\b", asm, re.M) is None, "CLI must not appear in integrated runtime")
req("lda #$35" in asm and "sta CPU_PORT" in asm, "CPU port must be $35 because logo assets cross $A000-$BFFF")
req("lda #$37" not in asm, "CPU port $37 must not be used for asset reads through BASIC ROM")
req("* = $7000" in asm and "* = $9800" in asm, "logo/cube data origins missing")
asset_path=root / "assets/logo-pack/uber_mc_full_320x200.asm"
req(asset_path.is_file(), "full-logo asset source missing")
asset_bytes=sum(
    int(m.group(1), 0)
    for m in re.finditer(r"_size\s*=\s*(\d+|\$[0-9a-fA-F]+)", asset_path.read_text())
)
req(asset_bytes == 10000, f"full-logo payload must be 10,000 bytes, got {asset_bytes}")
asset_end=0x7000+asset_bytes-1
req(asset_end < 0x9800, f"full-logo data overlaps cube area: ends at ${asset_end:04x}")
req("!if * > $7000" in asm, "code/logo-data guard missing")
req("!if * > $d000" in asm, "cube/I/O guard missing")
req("!if LogoAssetDataEnd > $9800" in asm, "logo/cube overlap guard missing")
for zone in ["WaitFrame", "CopyCount", "ClearScreenColor", "ClearBitmap", "LogoPulseWait", "FlashOut", "BuildEffectCharset", "TunnelEffect", "CubeEffect", "RenderCubeFrame"]:
    req(f"!zone {zone}" in asm, f"missing ACME zone for {zone}")
# V14-specific cube index preservation guard.
req("sty TUNCOL          ; preserve cube frame-data index" in asm, "cube frame-data index preserve missing")
req("ldy TUNCOL          ; restore cube frame-data index" in asm, "cube frame-data index restore missing")
# Ensure every cube frame count is under 128 words so Y-index never wraps 256 bytes.
m=re.search(r"CubeFrameCount:\s*\n!byte ([^\n]+)", asm)
if not m:
    errors.append("CubeFrameCount table missing")
else:
    counts=[int(x.strip()) for x in m.group(1).split(",") if x.strip()]
    req(len(counts)==32, "CubeFrameCount must have 32 frames")
    req(max(counts)*2 < 256, f"cube frame too large for indexed indirect Y: max_count={max(counts)}")
if errors:
    print("FAIL")
    print("\n".join("- "+e for e in errors))
    sys.exit(1)
print("PASS: C64 UBER Logo Effects v1.0.0 source validates.")
print(f"runtime=$4000 logo_data=$7000-${asset_end:04x} bytes={asset_bytes} cube_data=$9800-$cfff")
print("cpu_port=$35 irq=disabled cli=absent cube_index=preserved parts=logo,pulse,tunnel,cube")
