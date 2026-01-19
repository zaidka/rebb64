#!/usr/bin/env python3
"""
Level Data Converter for rebb64

Converts levels.txt (human-readable format) to binary data for the game.

Outputs:
  - level-bitmaps.bin: Level bitmap data (variable size per level)
  - level-colors.bin: 100 bytes of color data (D_FF30)
  - level-flags.bin: 100 bytes of symmetry/sidebar flags (D_FF94)
  - enemy-spawns.bin: Enemy spawn data for all 100 levels
  - item-positions.bin: Item spawn position tables (D_B569, D_B5CD, D_B631)
  - physics-flags.bin: Level physics/hole metadata (D_C58E)

Format specification for levels.txt:
  - Levels must appear in order from 1 to 100
  - Each level starts with "[Level N]" on its own line
  - Next line: "colors = $XX" (hex byte)
  - Next line: "sidebar = $XX" (hex byte, bits 0-6 only, bit 7 auto-detected)
  - Optional extended properties (any order):
    - "bubble_current = $X" (hex nibble 0-F) - bubble/air current direction
    - "wrap_openings = $X" (hex nibble 0-F) - screen wrap openings (bits: TL,TR,BL,BR)
    - "food_drop = X,Y" (coordinates)
    - "powerup_spawn = X,Y" (coordinates)
    - "spawn_flags = $X" (hex nibble)
  - Enemy lines: "enemy = X, Y, type, delay, $flags" (one per enemy)
    - X: column 0-31
    - Y: row 0-31
    - type: enemy type 0-7
    - delay: spawn delay 0-63
    - $flags: hex value ($0-$1F) controlling movement and facing:
        bit 4: move left
        bit 3: face left (initial spawn direction)
        bits 0-2: byte1 low bits (bit 0 = move right)
      Common values:
        $0  = stationary, face right
        $8  = stationary, face left
        $1  = move right, face right
        $9  = move right, face left
        $10 = move left, face right
        $18 = move left, face left
        $11 = alternate L/R, face right
        $19 = alternate L/R, face left
  - Next 23 lines: bitmap rows, exactly 32 characters each (# or .)
  - After bitmap: empty line (except after last level)

Any deviation from this format is an error.
"""

import sys
import os
import re


class LevelParseError(Exception):
    """Raised when level parsing fails"""

    pass


def parse_hex_byte(value: str, field_name: str, line_num: int) -> int:
    """Parse a hex byte value like '$21' or '$7F'"""
    value = value.strip()
    if not value.startswith("$"):
        raise LevelParseError(
            f"Line {line_num}: {field_name} must start with '$', got '{value}'"
        )
    try:
        result = int(value[1:], 16)
    except ValueError:
        raise LevelParseError(
            f"Line {line_num}: Invalid hex value for {field_name}: '{value}'"
        )
    if result < 0 or result > 255:
        raise LevelParseError(
            f"Line {line_num}: {field_name} value ${result:02X} out of range (0-255)"
        )
    return result


def parse_hex_nibble(value: str, field_name: str, line_num: int) -> int:
    """Parse a hex nibble value like '$1' or '$F'"""
    value = value.strip()
    if not value.startswith("$"):
        raise LevelParseError(
            f"Line {line_num}: {field_name} must start with '$', got '{value}'"
        )
    try:
        result = int(value[1:], 16)
    except ValueError:
        raise LevelParseError(
            f"Line {line_num}: Invalid hex value for {field_name}: '{value}'"
        )
    if result < 0 or result > 15:
        raise LevelParseError(
            f"Line {line_num}: {field_name} value ${result:X} out of range (0-F)"
        )
    return result


def parse_coordinate(value: str, field_name: str, line_num: int) -> tuple[int, int]:
    """Parse a coordinate pair like '15,7' or '26,2'"""
    parts = value.strip().split(",")
    if len(parts) != 2:
        raise LevelParseError(
            f"Line {line_num}: {field_name} must be 'X,Y', got '{value}'"
        )
    try:
        x = int(parts[0].strip())
        y = int(parts[1].strip())
    except ValueError:
        raise LevelParseError(
            f"Line {line_num}: Invalid coordinate for {field_name}: '{value}'"
        )
    if x < 0 or x > 31:
        raise LevelParseError(
            f"Line {line_num}: {field_name} X value {x} out of range (0-31)"
        )
    if y < 0 or y > 22:
        raise LevelParseError(
            f"Line {line_num}: {field_name} Y value {y} out of range (0-22)"
        )
    return (x, y)


def parse_wrap_openings(value: str, field_name: str, line_num: int) -> int:
    """
    Parse wrap_openings field.

    Format: hex nibble ($0-$F)

    Returns: 4-bit value where:
      bit 0 = top_left wrap opening
      bit 1 = top_right wrap opening
      bit 2 = bottom_left wrap opening
      bit 3 = bottom_right wrap opening
    """
    return parse_hex_nibble(value, field_name, line_num)


def parse_enemy(value: str, line_num: int) -> dict:
    """
    Parse an enemy spawn line.

    Format: X, Y, type, delay, $flags
    - X: column 0-31
    - Y: row 0-31 (values > 22 spawn off-screen)
    - type: enemy type 0-7 (selects sprite/animation/delay from property tables)
    - delay: spawn delay 0-63
    - $flags: hex value combining movement and facing bits
              Bits map to binary as follows:
                $flags:  bit 4 = move left  --> byte2 bit 7
                         bit 3 = face left  --> byte2 bit 6
                         bits 0-2           --> byte1 bits 0-2 (bit 0 = move right)
    """
    parts = [p.strip() for p in value.strip().split(",")]
    if len(parts) != 5:
        raise LevelParseError(
            f"Line {line_num}: enemy must be 'X, Y, type, delay, $flags', got '{value}'"
        )

    # Parse flags (hex value)
    flags_str = parts[4].strip()
    if not flags_str.startswith("$"):
        raise LevelParseError(
            f"Line {line_num}: enemy flags must start with '$', got '{flags_str}'"
        )
    try:
        flags = int(flags_str[1:], 16)
    except ValueError:
        raise LevelParseError(
            f"Line {line_num}: invalid hex value for flags: '{flags_str}'"
        )
    if flags < 0 or flags > 31:
        raise LevelParseError(
            f"Line {line_num}: enemy flags ${flags:X} out of range ($0-$1F)"
        )

    # Extract fields from flags
    move_left = (flags >> 4) & 1  # bit 4 -> byte2 bit 7
    face_left = (flags >> 3) & 1  # bit 3 -> byte2 bit 6
    byte1_low = flags & 7  # bits 0-2 -> byte1 bits 0-2

    try:
        x_col = int(parts[0])
        y_row = int(parts[1])
        enemy_class = int(parts[2])
        delay = int(parts[3])
    except ValueError as e:
        raise LevelParseError(
            f"Line {line_num}: invalid number in enemy definition: {e}"
        )

    # Validate ranges
    if x_col < 0 or x_col > 31:
        raise LevelParseError(
            f"Line {line_num}: enemy X column {x_col} out of range (0-31)"
        )
    if y_row < 0 or y_row > 31:
        raise LevelParseError(
            f"Line {line_num}: enemy Y row {y_row} out of range (0-31)"
        )
    if enemy_class < 0 or enemy_class > 7:
        raise LevelParseError(
            f"Line {line_num}: enemy type {enemy_class} out of range (0-7)"
        )
    if delay < 0 or delay > 63:
        raise LevelParseError(
            f"Line {line_num}: enemy delay {delay} out of range (0-63)"
        )

    return {
        "x_col": x_col,
        "y_row": y_row,
        "enemy_class": enemy_class,
        "byte1_low": byte1_low,
        "face_left": face_left,
        "move_left": move_left,
        "delay": delay,
    }


def bitmap_row_to_bytes(row: str, line_num: int) -> list[int]:
    """Convert a 32-character bitmap row to 4 bytes"""
    if len(row) != 32:
        raise LevelParseError(
            f"Line {line_num}: Bitmap row must be exactly 32 characters, got {len(row)}"
        )

    for i, char in enumerate(row):
        if char not in ".#":
            raise LevelParseError(
                f"Line {line_num}: Invalid character '{char}' at position {i + 1}, "
                f"only '.' and '#' are allowed"
            )

    # Convert to 4 bytes (8 bits each)
    bytes_out = []
    for byte_idx in range(4):
        byte_val = 0
        for bit in range(8):
            char_idx = byte_idx * 8 + bit
            if row[char_idx] == "#":
                byte_val |= 0x80 >> bit  # MSB first
        bytes_out.append(byte_val)

    return bytes_out


def is_symmetric(rows: list[str]) -> bool:
    """Check if all rows are left-right symmetric"""
    for row in rows:
        left_half = row[:16]
        right_half = row[16:]
        if left_half != right_half[::-1]:
            return False
    return True


def compress_to_symmetric(rows: list[str]) -> list[int]:
    """Compress symmetric level to 46 bytes (left half only)"""
    bitmap_bytes = []
    for row in rows:
        # Take left 16 characters, convert to 2 bytes
        left_half = row[:16]
        for byte_idx in range(2):
            byte_val = 0
            for bit in range(8):
                char_idx = byte_idx * 8 + bit
                if left_half[char_idx] == "#":
                    byte_val |= 0x80 >> bit
            bitmap_bytes.append(byte_val)
    return bitmap_bytes


def expand_to_asymmetric(rows: list[str]) -> list[int]:
    """Expand asymmetric level to 92 bytes (full width)"""
    bitmap_bytes = []
    for row in rows:
        row_bytes = bitmap_row_to_bytes(row, 0)  # line_num not used for error here
        bitmap_bytes.extend(row_bytes)
    return bitmap_bytes


def parse_levels(filepath: str) -> list[dict]:
    """Parse levels.txt and return list of level data"""
    with open(filepath, "r") as f:
        lines = f.read().split("\n")

    levels = []
    line_num = 0
    expected_level = 1

    while line_num < len(lines) and expected_level <= 100:
        # Expect "[Level N]"
        line = lines[line_num]

        # Check level header
        match = re.match(r"^\[Level (\d+)\]$", line)
        if not match:
            raise LevelParseError(
                f"Line {line_num + 1}: Expected '[Level {expected_level}]', got '{line}'"
            )

        level_num = int(match.group(1))
        if level_num != expected_level:
            raise LevelParseError(
                f"Line {line_num + 1}: Expected Level {expected_level}, got Level {level_num}"
            )

        line_num += 1

        # Expect "colors = $XX"
        if line_num >= len(lines):
            raise LevelParseError(
                f"Line {line_num + 1}: Unexpected end of file, expected 'colors = $XX'"
            )

        line = lines[line_num]
        match = re.match(r"^colors = (\$[0-9A-Fa-f]{2})$", line)
        if not match:
            raise LevelParseError(
                f"Line {line_num + 1}: Expected 'colors = $XX', got '{line}'"
            )
        colors = parse_hex_byte(match.group(1), "colors", line_num + 1)
        line_num += 1

        # Expect "sidebar = $XX"
        if line_num >= len(lines):
            raise LevelParseError(
                f"Line {line_num + 1}: Unexpected end of file, expected 'sidebar = $XX'"
            )

        line = lines[line_num]
        match = re.match(r"^sidebar = (\$[0-9A-Fa-f]{2})$", line)
        if not match:
            raise LevelParseError(
                f"Line {line_num + 1}: Expected 'sidebar = $XX', got '{line}'"
            )
        sidebar = parse_hex_byte(match.group(1), "sidebar", line_num + 1)

        # Sidebar should only use bits 0-6 (bit 7 is for symmetry, auto-detected)
        if sidebar > 0x7F:
            raise LevelParseError(
                f"Line {line_num + 1}: sidebar value ${sidebar:02X} has bit 7 set; "
                f"bit 7 is reserved for symmetry flag (auto-detected)"
            )
        line_num += 1

        # Initialize extended properties with defaults
        bubble_current = None
        wrap_openings = None
        food_drop = None
        powerup_spawn = None
        spawn_flags = None
        enemies = []

        # Parse optional extended properties and enemy lines
        while line_num < len(lines):
            line = lines[line_num]

            # Skip blank lines
            if line == "":
                line_num += 1
                continue

            # Parse bubble_current (upper nibble)
            match = re.match(r"^bubble_current = (\$[0-9A-Fa-f]+)$", line)
            if match:
                bubble_current = parse_hex_nibble(
                    match.group(1), "bubble_current", line_num + 1
                )
                line_num += 1
                continue

            # Parse wrap_openings (lower nibble)
            match = re.match(r"^wrap_openings = (\$[0-9A-Fa-f]+)$", line)
            if match:
                wrap_openings = parse_wrap_openings(
                    match.group(1), "wrap_openings", line_num + 1
                )
                line_num += 1
                continue

            # Parse food_drop
            match = re.match(r"^food_drop = (.+)$", line)
            if match:
                food_drop = parse_coordinate(match.group(1), "food_drop", line_num + 1)
                line_num += 1
                continue

            # Parse powerup_spawn
            match = re.match(r"^powerup_spawn = (.+)$", line)
            if match:
                powerup_spawn = parse_coordinate(
                    match.group(1), "powerup_spawn", line_num + 1
                )
                line_num += 1
                continue

            # Parse spawn_flags
            match = re.match(r"^spawn_flags = (\$[0-9A-Fa-f]+)$", line)
            if match:
                spawn_flags = parse_hex_nibble(
                    match.group(1), "spawn_flags", line_num + 1
                )
                line_num += 1
                continue

            # Parse enemy line
            match = re.match(r"^enemy = (.+)$", line)
            if match:
                enemy = parse_enemy(match.group(1), line_num + 1)
                enemies.append(enemy)
                line_num += 1
                continue

            # If it's a bitmap row (32 chars of . and #), we've found the bitmap
            if len(line) == 32 and all(c in ".#" for c in line):
                break

            # Otherwise it's an error
            raise LevelParseError(
                f"Line {line_num + 1}: Unexpected line before bitmap: '{line}'"
            )

        # Validate required extended properties
        if bubble_current is None:
            raise LevelParseError(f"Level {level_num}: Missing 'bubble_current' field")
        if wrap_openings is None:
            raise LevelParseError(f"Level {level_num}: Missing 'wrap_openings' field")

        # Combine into physics byte
        physics = (bubble_current << 4) | wrap_openings

        if food_drop is None:
            raise LevelParseError(f"Level {level_num}: Missing 'food_drop' property")
        if powerup_spawn is None:
            raise LevelParseError(
                f"Level {level_num}: Missing 'powerup_spawn' property"
            )
        if spawn_flags is None:
            raise LevelParseError(f"Level {level_num}: Missing 'spawn_flags' property")

        # Expect 23 bitmap rows
        bitmap_rows = []
        for row_idx in range(23):
            if line_num >= len(lines):
                raise LevelParseError(
                    f"Line {line_num + 1}: Unexpected end of file, expected bitmap row {row_idx + 1}/23"
                )

            line = lines[line_num]
            if len(line) != 32:
                raise LevelParseError(
                    f"Line {line_num + 1}: Bitmap row {row_idx + 1} must be exactly 32 characters, got {len(line)}"
                )

            for i, char in enumerate(line):
                if char not in ".#":
                    raise LevelParseError(
                        f"Line {line_num + 1}: Invalid character '{char}' at position {i + 1}, "
                        f"only '.' and '#' are allowed"
                    )

            bitmap_rows.append(line)
            line_num += 1

        # Skip blank line after bitmap (if present)
        if line_num < len(lines) and lines[line_num] == "":
            line_num += 1

        # Store level data
        levels.append(
            {
                "num": level_num,
                "colors": colors,
                "sidebar": sidebar,
                "physics": physics,
                "food_drop": food_drop,
                "powerup_spawn": powerup_spawn,
                "spawn_flags": spawn_flags,
                "enemies": enemies,
                "bitmap_rows": bitmap_rows,
            }
        )

        expected_level += 1

    if len(levels) != 100:
        raise LevelParseError(f"Expected 100 levels, got {len(levels)}")

    return levels


def convert_bitmaps(levels: list[dict]) -> tuple[bytes, bytes, bytes]:
    """
    Convert parsed levels to bitmap binary data.

    Returns:
        (bitmap_data, colors_data, flags_data)
    """
    bitmap_bytes = []
    colors_bytes = []
    flags_bytes = []

    for level in levels:
        colors_bytes.append(level["colors"])

        # Check symmetry and generate appropriate bitmap
        symmetric = is_symmetric(level["bitmap_rows"])

        if symmetric:
            # Symmetric: 46 bytes, set bit 7 in flags
            level_bitmap = compress_to_symmetric(level["bitmap_rows"])
            flags_byte = level["sidebar"] | 0x80
        else:
            # Asymmetric: 92 bytes, bit 7 clear in flags
            level_bitmap = expand_to_asymmetric(level["bitmap_rows"])
            flags_byte = level["sidebar"]

        bitmap_bytes.extend(level_bitmap)
        flags_bytes.append(flags_byte)

    return bytes(bitmap_bytes), bytes(colors_bytes), bytes(flags_bytes)


def convert_enemy_spawns(levels: list[dict]) -> bytes:
    """
    Convert enemy spawn data to binary format.

    Binary format (3 bytes per enemy):
    - Byte 0: (column << 3) | enemy_class
    - Byte 1: (row << 3) | byte1_low
    - Byte 2: (move_left << 7) | (face_left << 6) | delay

    Each level's enemies are terminated by a $00 byte.
    """
    spawn_bytes = []

    for level in levels:
        for enemy in level["enemies"]:
            byte0 = (enemy["x_col"] << 3) | enemy["enemy_class"]
            byte1 = (enemy["y_row"] << 3) | enemy["byte1_low"]
            byte2 = enemy["delay"]
            if enemy["face_left"]:
                byte2 |= 0x40
            if enemy["move_left"]:
                byte2 |= 0x80

            spawn_bytes.extend([byte0, byte1, byte2])

        # Null terminator for this level
        spawn_bytes.append(0x00)

    return bytes(spawn_bytes)


def convert_item_positions(levels: list[dict]) -> bytes:
    """
    Convert item position and spawn flag data to binary format.

    Generates three 100-byte tables that are concatenated:
    - D_B569: Food drop position encoding
    - D_B5CD: Shared position bits
    - D_B631: Power-up position encoding + spawn flags (lower nibble)

    Position encoding algorithm (reverse of the decode algorithm in docs):

    Food drop position (Slot 0):
      - D_B569 bits 7-3 = X column (0-31)
      - D_B569 bits 2-0 = Y row bits 4-2
      - D_B5CD bits 7-6 = Y row bits 1-0

    Power-up position (Slot 1):
      - D_B5CD bits 5-1 = X column (0-31)
      - D_B5CD bit 0 = Y position bit 7 (after multiply by 8)
      - D_B631 bits 7-4 = Y position bits 6-3 (after multiply by 8)

    D_B631 bits 3-0 = spawn_flags
    """
    b569_bytes = []
    b5cd_bytes = []
    b631_bytes = []

    for level in levels:
        food_x, food_y = level["food_drop"]
        powerup_x, powerup_y = level["powerup_spawn"]
        spawn_flags = level["spawn_flags"]

        # Encode food drop position into D_B569 and upper bits of D_B5CD
        # D_B569 = (food_x << 3) | (food_y >> 2)
        # D_B5CD upper 2 bits = food_y & 0x03
        b569 = (food_x << 3) | (food_y >> 2)

        # Encode power-up position into D_B5CD lower 6 bits and D_B631 upper nibble
        # The decoding formula is:
        #   y_combined = ((b5cd & 0x01) << 7) | ((b631 & 0xF0) >> 1)
        #   powerup_y = y_combined // 8
        # So to encode:
        #   y_combined = powerup_y * 8
        #   if y_combined < 128: b5cd_bit0 = 0, b631_upper = y_combined * 2
        #   if y_combined >= 128: b5cd_bit0 = 1, b631_upper = (y_combined - 128) * 2
        y_combined = powerup_y * 8
        if y_combined < 128:
            b5cd_bit0 = 0
            b631_upper = y_combined * 2
        else:
            b5cd_bit0 = 1
            b631_upper = (y_combined - 128) * 2

        b5cd = ((food_y & 0x03) << 6) | (powerup_x << 1) | b5cd_bit0
        b631 = (b631_upper & 0xF0) | (spawn_flags & 0x0F)

        b569_bytes.append(b569)
        b5cd_bytes.append(b5cd)
        b631_bytes.append(b631)

    # Concatenate all three tables
    return bytes(b569_bytes + b5cd_bytes + b631_bytes)


def convert_physics_flags(levels: list[dict]) -> bytes:
    """
    Convert physics flags to binary format.
    Simply 100 bytes, one per level.
    """
    return bytes([level["physics"] for level in levels])


def main():
    if len(sys.argv) != 8:
        print(
            f"Usage: {sys.argv[0]} <levels.txt> <bitmaps.bin> <colors.bin> <flags.bin> "
            f"<enemy-spawns.bin> <item-positions.bin> <physics-flags.bin>"
        )
        sys.exit(1)

    input_file = sys.argv[1]
    bitmap_output = sys.argv[2]
    colors_output = sys.argv[3]
    flags_output = sys.argv[4]
    enemy_spawns_output = sys.argv[5]
    item_positions_output = sys.argv[6]
    physics_flags_output = sys.argv[7]

    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)

    try:
        levels = parse_levels(input_file)

        # Generate all binary outputs
        bitmap_data, colors_data, flags_data = convert_bitmaps(levels)
        enemy_spawns_data = convert_enemy_spawns(levels)
        item_positions_data = convert_item_positions(levels)
        physics_flags_data = convert_physics_flags(levels)

        # Write all output files
        with open(bitmap_output, "wb") as f:
            f.write(bitmap_data)

        with open(colors_output, "wb") as f:
            f.write(colors_data)

        with open(flags_output, "wb") as f:
            f.write(flags_data)

        with open(enemy_spawns_output, "wb") as f:
            f.write(enemy_spawns_data)

        with open(item_positions_output, "wb") as f:
            f.write(item_positions_data)

        with open(physics_flags_output, "wb") as f:
            f.write(physics_flags_data)

        # Count statistics
        sym_count = sum(1 for b in flags_data if b & 0x80)
        asym_count = 100 - sym_count
        total_enemies = sum(len(level["enemies"]) for level in levels)

        print(f"Converted 100 levels successfully")
        print(f"  Symmetric: {sym_count}, Asymmetric: {asym_count}")
        print(f"  Bitmap data: {len(bitmap_data)} bytes")
        print(f"  Colors data: {len(colors_data)} bytes")
        print(f"  Flags data: {len(flags_data)} bytes")
        print(
            f"  Enemy spawns: {len(enemy_spawns_data)} bytes ({total_enemies} enemies)"
        )
        print(f"  Item positions: {len(item_positions_data)} bytes (3x100)")
        print(f"  Physics flags: {len(physics_flags_data)} bytes")

    except LevelParseError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        raise


if __name__ == "__main__":
    main()
