# Audit record

## Inputs examined

All four supplied ZIP archives passed `unzip -tq` integrity checks.

- `euro_pulsegrid_project_fix67.zip`
- `euro_pulsegrid_v4_1_halo_cache_release.zip`
- `c64_uber_super_cube_new2_eye3d_rho_x2_kappa_topsafe_perfect_release.zip`
- `uber_c64_logo_pack_v14_integrated_100_final.zip`

The two Pulsegrid inputs assembled and passed their supplied validators. Super Cube also assembled and passed its supplied verifier. Existing GitHub repositories `djayuffe/euro-pulsegrid` and `djayuffe/C64-Pulsegrid` are separate Pulsegrid histories; their sources do not match either supplied Pulsegrid archive closely enough for a safe overwrite.

## Issues found in the UBER logo archive

1. The advertised V14 integrated source did not assemble. Repeated ACME dot-local labels lived in one unnamed zone, producing duplicate-label errors and invalid branch targets.
2. After resolving the label problem, the source still embedded all 23,900 bytes of logo assets at `$7000`; that overlapped cube tables and exceeded the usable RAM area.
3. The old static report described the impossible all-assets layout as passing, so it did not prove a buildable release.
4. The archive contained multiple obsolete V1–V13 harnesses, duplicate release scripts, stale reports, and conflicting “final” documentation.

## Corrections in this repository

- Added named ACME zones around routines that use dot-local labels.
- Kept only the full 320×200 logo in the runnable PRG, at `$7000–$970F`.
- Moved cube data to `$9800` and added guards against I/O and asset overlap.
- Preserved all nine validated reusable logo assets without keeping obsolete harnesses or release claims.
- Replaced versioned legacy scripts with one build entry point and checked validators.
- Renamed the project and source to `c64-uber-logo-effects` and `c64_uber_logo_effects.asm`.

## Verification performed

```text
PASS: all UBER logo assets have exact expected C64 byte sizes, bit order assumptions and colour RAM nibble constraints.
PASS: C64 UBER Logo Effects v1.0.0 source validates.
runtime=$4000 logo_data=$7000-$970f bytes=10000 cube_data=$9800-$cfff
PASS: build/c64_uber_logo_effects.prg is 43657 bytes, loads at $0801, and starts with SYS 16384.
```

VICE was available for launch testing, but its macOS graphics backend could not initialize a screenshot renderer in this unattended environment. The checked-in image is the supplied full-logo source preview, not a claimed emulator capture.
