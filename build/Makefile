# rebb64 - Build System
# ========================================
#
# Usage:
#   make          - Build the game
#   make clean    - Remove build artifacts
#   make verify   - Build and verify against original
#   make release  - Build runnable PRG (requires tscrunch)

# Tools
CA65 = ca65
LD65 = ld65
TSCRUNCH = tscrunch
PYTHON = python3

# Directories
SRC_DIR = ../src
DATA_DIR = ../data

# Config
CONFIG = c64-prg.cfg

# Output
OUTPUT = rebb64-raw.prg
RELEASE = rebb64.prg

# SHA256 hash of original Bubble Bobble C64 PRG (decompressed)
REFERENCE_SHA256 = fdba2390782653ba2533b2d87c44c8f0480ab18968a2c0ccc0cef8300fcee7b6

all: $(OUTPUT)

# TGA to binary conversion
hud-font.bin: $(DATA_DIR)/hud-font.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format hires-chars

# Assemble load address
loadaddr.o: $(SRC_DIR)/loadaddr.s
	$(CA65) --cpu 6502 -o $@ $<

# Assemble main source
master.o: $(SRC_DIR)/master.s hud-font.bin
	$(CA65) --cpu 6502 -I $(SRC_DIR) -o $@ $<

# Link
$(OUTPUT): loadaddr.o master.o $(CONFIG)
	$(LD65) -C $(CONFIG) -o $@ loadaddr.o master.o

# Verify against original hash
verify: $(OUTPUT)
	@echo "Verifying SHA256 hash..."
	@echo "$(REFERENCE_SHA256)  $(OUTPUT)" | sha256sum -c - && echo "SUCCESS: Hash matches original!"

# Create runnable PRG with TSCrunch
release: $(OUTPUT)
	$(TSCRUNCH) -p -x '$$4830' $(OUTPUT) $(RELEASE)

# Clean build artifacts
clean:
	rm -f loadaddr.o master.o $(OUTPUT) $(RELEASE) *.bin

.PHONY: all clean verify release
