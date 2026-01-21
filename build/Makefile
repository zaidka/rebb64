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

# Generated level data files
LEVEL_BINS = level-bitmaps.bin level-colors.bin level-flags.bin \
             enemy-spawns.bin item-positions.bin physics-flags.bin

all: $(OUTPUT)

# Level data conversion (levels.txt -> binary files)
$(LEVEL_BINS): $(DATA_DIR)/levels.txt convert-levels.py
	$(PYTHON) convert-levels.py $< $(LEVEL_BINS)

# Zone data conversion (zone-data.txt -> zone-data.bin)
zone-data.bin: $(DATA_DIR)/zone-data.txt convert-zone-data.py
	$(PYTHON) convert-zone-data.py $< $@

# TGA to binary conversion
hud-font.bin: $(DATA_DIR)/hud-font.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format multicolor-chars

sidebars.bin: $(DATA_DIR)/sidebars.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format multicolor-chars

level-tiles.bin: $(DATA_DIR)/level-tiles.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format multicolor-chars

# Character set ($4000-$445F, 140 characters = 1120 bytes)
charset.bin: $(DATA_DIR)/charset.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format hires-chars

# Bonus sprites (cake, melon, diamond) - sprite sheet (8 sprites + melon tops = 530 bytes)
# Layout: [cake][melon_tops][melon][diamond]
# Slicing is done in binaries.s using .incbin offset/size parameters:
#   bytes 0-255:   cake (4 sprites)       -> BONUS_CAKE segment ($A320)
#   bytes 256-273: melon tops (18 bytes)  -> referenced via offset in binaries.s
#   bytes 274-401: melon (2 sprites)      -> BONUS_MELON segment ($A4A0)
#   bytes 402-529: diamond (2 sprites)    -> BONUS_DIAMOND segment ($A520)
# Source TGAs: bonus-cake.tga (24x42), bonus-melon.tga (24x24), bonus-diamond.tga (24x21)
# Padding bytes (byte 64 of each sprite) come from dead-bytes.txt.
bonus-sprites.bin: $(DATA_DIR)/bonus-cake.tga $(DATA_DIR)/bonus-melon.tga $(DATA_DIR)/bonus-diamond.tga $(DATA_DIR)/dead-bytes.txt extract-bonus-sprites.py
	$(PYTHON) extract-bonus-sprites.py

# Game sprites ($5800-$703F, 6208 bytes = 97 sprites)
# Combined from old sprites1.bin + sprite portion of level-data-part1.bin
# Padding bytes come from dead-bytes.txt (byte 64 of each sprite, unused by VIC-II)
sprites-game.bin: $(DATA_DIR)/sprites-game.tga $(DATA_DIR)/dead-bytes.txt convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format multicolor-sprites

# Bubble masks from sprites2-static region ($8000-$847F, 1152 bytes)
bubble-masks.bin: $(DATA_DIR)/bubble-masks.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format bubble-masks

# Software sprites ($8F00-$A31F, 5152 bytes)
# 107+ column-major 12x16 multicolor sprites (last sprite partial)
# The remaining 32 bytes ($A320-$A33F) come from bonus-cake-head.bin
software-sprites.bin: $(DATA_DIR)/software-sprites.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format software-sprites

# Diamond sprite ($A854, 36 bytes - embedded in game-tables-static.bin)
diamond-sprite.bin: $(DATA_DIR)/diamond-sprite.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format diamond-sprite

# Digit font ($AD75, 60 bytes - embedded in game-tables-static.bin)
digit-font.bin: $(DATA_DIR)/digit-font.tga convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format digit-font

# Level sprites ($7440-$75FF, 512 bytes = 8 sprites)
# Bubble dragon in bubble sprites (2 groups of 4 sprites each)
# Padding bytes come from dead-bytes.txt (byte 64 of each sprite, unused by VIC-II)
bubble-dragon-in-bubble.bin: $(DATA_DIR)/bubble-dragon-in-bubble.tga $(DATA_DIR)/dead-bytes.txt convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format level-sprites-stacked --stacked-groups 2

# Level sprites: Grumple Gromit (1728 bytes = 27 sprites)
# Left (9) + bubble (9) at $7600-$7ABF, right (9) at $7C40-$7E7F
# Sliced in binaries.s using .incbin offset/size parameters
# Padding bytes come from dead-bytes.txt (byte 64 of each sprite, unused by VIC-II)
grumple-gromit.bin: $(DATA_DIR)/grumple-gromit.tga $(DATA_DIR)/dead-bytes.txt convert-tga.py
	$(PYTHON) convert-tga.py $< $@ --format level-sprites-stacked --stacked-groups 3

# Assemble load address
loadaddr.o: $(SRC_DIR)/loadaddr.s
	$(CA65) --cpu 6502 -o $@ $<

# Assemble main source
master.o: $(SRC_DIR)/master.s hud-font.bin sidebars.bin level-tiles.bin sprites-game.bin zone-data.bin charset.bin bubble-masks.bin software-sprites.bin bonus-sprites.bin diamond-sprite.bin digit-font.bin bubble-dragon-in-bubble.bin grumple-gromit.bin $(LEVEL_BINS)
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
