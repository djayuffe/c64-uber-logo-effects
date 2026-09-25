#!/usr/bin/env sh
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root_dir"

python3 scripts/validate_logo_pack.py
python3 scripts/validate_release.py
mkdir -p build
acme --strict-segments -f cbm -o build/c64_uber_logo_effects.prg c64_uber_logo_effects.asm
python3 scripts/verify_prg.py build/c64_uber_logo_effects.prg
