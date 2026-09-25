# UBER C64 Logo Pack — Exact 1:1 Format Properties

This file documents the real C64 properties used by every generated asset:
bit depth, byte order, bit order, colour interpretation, cell ordering, and exact data sizes.

## Global colour palette

The PNG previews use a Pepto-style C64 palette for display only. The actual ACME data stores C64 colour indices `0..15`.

| Index | C64 colour |
|---:|---|
| `$0` | black |
| `$1` | white |
| `$2` | red |
| `$3` | cyan |
| `$4` | purple |
| `$5` | green |
| `$6` | blue |
| `$7` | yellow |
| `$8` | orange |
| `$9` | brown |
| `$a` | light red |
| `$b` | dark gray |
| `$c` | gray |
| `$d` | light green |
| `$e` | light blue |
| `$f` | light gray |

## Format rules

### `mcbitmap` — C64 VIC-II multicolor bitmap

- **bpp_effective**: 2 bits per multicolor pixel; each multicolor pixel is 2 hardware pixels wide
- **byte_order**: character-cell order: screen cell 0..N, 8 bitmap bytes per cell, row 0..7 within each cell
- **bit_order**: MSB first, left to right: bits 7-6, 5-4, 3-2, 1-0
- **bitpair_mapping**:
  - `00` = $D021 background colour
  - `01` = screen RAM high nibble
  - `10` = screen RAM low nibble
  - `11` = colour RAM low nibble
- **screen_byte**: high nibble = colour for bitpair 01; low nibble = colour for bitpair 10
- **color_ram_byte**: low nibble = colour for bitpair 11; high nibble ignored on real C64
- **bytes_per_cell**: 8
- **cell_pixels_stored**: 4x8 multicolor pixels
- **cell_pixels_displayed**: 8x8 hardware pixels

### `hiresbitmap` — C64 VIC-II hires bitmap

- **bpp_effective**: 1 bit per hardware pixel
- **byte_order**: character-cell order: screen cell 0..N, 8 bitmap bytes per cell, row 0..7 within each cell
- **bit_order**: MSB first, left to right: bit 7 is leftmost pixel, bit 0 is rightmost pixel
- **bit_mapping**:
  - `0` = screen RAM low nibble/background colour for this cell
  - `1` = screen RAM high nibble/foreground colour for this cell
- **screen_byte**: high nibble = foreground; low nibble = background
- **bytes_per_cell**: 8
- **cell_pixels_displayed**: 8x8 hardware pixels

### `charset` — C64 custom charset + screen + colour RAM

- **bpp_effective**: 1 bit per hardware pixel in this pack
- **byte_order**: 8 bytes per unique character, row 0..7
- **bit_order**: MSB first, left to right: bit 7 is leftmost pixel, bit 0 is rightmost pixel
- **screen_byte**: screen code/index into generated charset, 0..255
- **color_ram_byte**: low nibble = per-character foreground colour; high nibble ignored
- **bytes_per_char**: 8
- **cell_pixels_displayed**: 8x8 hardware pixels

### `sprites` — C64 standard monochrome sprite strip

- **bpp_effective**: 1 bit per hardware pixel
- **byte_order**: 64 bytes per sprite: 21 rows * 3 bytes + 1 padding byte
- **bit_order**: MSB first, left to right in each sprite row
- **bit_mapping**:
  - `0` = transparent/background
  - `1` = sprite colour from sprite colour table
- **sprite_size**: 24x21 hardware pixels
- **bytes_per_sprite**: 64
- **color_table**: one low-nibble sprite colour per sprite

## Asset validation table

| Asset | Type | Exact geometry | Data sizes | Bit order | Result |
|---|---|---:|---:|---|---|
| `uber_mc_full_320x200` | `mcbitmap` | 320x200 | bitmap=8000, screen=1000, color=1000 | MSB-first bitpairs: 7-6,5-4,3-2,1-0 | **PASS** |
| `uber_mc_logo_320x64` | `mcbitmap` | 320x64 | bitmap=2560, screen=320, color=320 | MSB-first bitpairs: 7-6,5-4,3-2,1-0 | **PASS** |
| `uber_mc_banner_320x50` | `mcbitmap` | 320x56 | bitmap=2240, screen=280, color=280 | MSB-first bitpairs: 7-6,5-4,3-2,1-0 | **PASS** |
| `uber_mc_small_160x48` | `mcbitmap` | 160x48 | bitmap=960, screen=120, color=120 | MSB-first bitpairs: 7-6,5-4,3-2,1-0 | **PASS** |
| `uber_hires_320x64` | `hiresbitmap` | 320x64 | bitmap=2560, screen=320 | MSB-first bits: 7..0 left-to-right | **PASS** |
| `uber_hires_320x32` | `hiresbitmap` | 320x32 | bitmap=1280, screen=160 | MSB-first bits: 7..0 left-to-right | **PASS** |
| `uber_charset_320x64` | `charset` | 320x64 | screen=320, color=320, charset=432 | MSB-first bits: 7..0 left-to-right | **PASS** |
| `uber_charset_160x40` | `charset` | 160x40 | screen=100, color=100, charset=328 | MSB-first bits: 7..0 left-to-right | **PASS** |
| `uber_sprite_logo_144x42` | `sprites` |  | color=12, sprite=768 | MSB-first bits per row byte: 7..0 left-to-right | **PASS** |
