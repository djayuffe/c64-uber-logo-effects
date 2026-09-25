.PHONY: all build check run clean

all: build

build:
	sh scripts/build.sh

check:
	python3 scripts/validate_logo_pack.py
	python3 scripts/validate_release.py

run: build
	x64sc build/c64_uber_logo_effects.prg

clean:
	rm -rf build
