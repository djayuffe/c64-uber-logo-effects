#!/usr/bin/env python3
"""Verify the C64 PRG load address and BASIC SYS stub produced by the build."""

from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: verify_prg.py PATH_TO_PRG")

prg = Path(sys.argv[1]).read_bytes()
expected_stub = bytes((0x01, 0x08, 0x0D, 0x08, 0x0A, 0x00, 0x9E, 0x20, 0x31, 0x36, 0x33, 0x38, 0x34, 0x00, 0x00, 0x00))
if len(prg) < len(expected_stub):
    raise SystemExit("FAIL: PRG is shorter than its expected BASIC stub")
if prg[:2] != b"\x01\x08":
    raise SystemExit(f"FAIL: expected load address $0801, got ${int.from_bytes(prg[:2], 'little'):04x}")
if prg[:len(expected_stub)] != expected_stub:
    raise SystemExit("FAIL: BASIC stub must be '10 SYS 16384'")
if len(prg) < 40000:
    raise SystemExit(f"FAIL: PRG unexpectedly small ({len(prg)} bytes)")
print(f"PASS: {sys.argv[1]} is {len(prg)} bytes, loads at $0801, and starts with SYS 16384.")
