# Memory map

| Address range | Purpose |
| --- | --- |
| `$0801–$0810` | BASIC loader: `10 SYS 16384` |
| `$4000–$6FFF` | Demo code and lookup tables |
| `$7000–$970F` | Full UBER multicolor bitmap, screen, and colour data (10,000 bytes) |
| `$9800–$CFFF` | Wire-cube frame tables |
| `$D000–$DFFF` | C64 I/O; never used for program data |
| `$D800–$DBE7` | Colour RAM at runtime |

The runtime sets processor port `$01` to `$35`, keeping RAM visible under BASIC and KERNAL while I/O remains available. It uses VIC bank 0, bitmap RAM at `$2000`, screen RAM at `$0400`, and charset RAM at `$3000`.

The build uses `acme --strict-segments`. Source-level guards reject code that reaches `$7000`, logo data that reaches `$9800`, and cube data that reaches `$D000`.
