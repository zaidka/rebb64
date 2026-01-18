#!/usr/bin/env python3
"""
Level Data Converter for rebb64

Converts levels.txt (human-readable format) to binary data for the game.

Outputs:
  - level-bitmaps.bin: Level bitmap data (variable size per level)
  - level-colors.bin: 100 bytes of color data (D_FF30)
  - level-flags.bin: 100 bytes of symmetry/sidebar flags (D_FF94)

Format specification for levels.txt:
  - Levels must appear in order from 1 to 100
  - Each level starts with "[Level N]" on its own line
  - Next line: "colors = $XX" (hex byte)
  - Next line: "sidebar = $XX" (hex byte, bits 0-6 only, bit 7 auto-detected)
  - Next line: empty (blank line)
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

        # Expect blank line
        if line_num >= len(lines):
            raise LevelParseError(
                f"Line {line_num + 1}: Unexpected end of file, expected blank line"
            )

        line = lines[line_num]
        if line != "":
            raise LevelParseError(
                f"Line {line_num + 1}: Expected blank line before bitmap, got '{line}'"
            )
        line_num += 1

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

        # Expect blank line after bitmap (except for last level)
        if expected_level < 100:
            if line_num >= len(lines):
                raise LevelParseError(
                    f"Line {line_num + 1}: Unexpected end of file, expected blank line after Level {expected_level}"
                )

            line = lines[line_num]
            if line != "":
                raise LevelParseError(
                    f"Line {line_num + 1}: Expected blank line after bitmap, got '{line}'"
                )
            line_num += 1

        # Store level data
        levels.append(
            {
                "num": level_num,
                "colors": colors,
                "sidebar": sidebar,
                "bitmap_rows": bitmap_rows,
            }
        )

        expected_level += 1

    if len(levels) != 100:
        raise LevelParseError(f"Expected 100 levels, got {len(levels)}")

    return levels


def convert_levels(levels: list[dict]) -> tuple[bytes, bytes, bytes]:
    """
    Convert parsed levels to binary data.

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


def main():
    if len(sys.argv) != 5:
        print(
            f"Usage: {sys.argv[0]} <levels.txt> <bitmaps.bin> <colors.bin> <flags.bin>"
        )
        sys.exit(1)

    input_file = sys.argv[1]
    bitmap_output = sys.argv[2]
    colors_output = sys.argv[3]
    flags_output = sys.argv[4]

    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)

    try:
        levels = parse_levels(input_file)
        bitmap_data, colors_data, flags_data = convert_levels(levels)

        with open(bitmap_output, "wb") as f:
            f.write(bitmap_data)

        with open(colors_output, "wb") as f:
            f.write(colors_data)

        with open(flags_output, "wb") as f:
            f.write(flags_data)

        # Count symmetric vs asymmetric
        sym_count = sum(1 for b in flags_data if b & 0x80)
        asym_count = 100 - sym_count

        print(f"Converted 100 levels successfully")
        print(f"  Symmetric: {sym_count}, Asymmetric: {asym_count}")
        print(f"  Bitmap data: {len(bitmap_data)} bytes")
        print(f"  Colors data: {len(colors_data)} bytes")
        print(f"  Flags data: {len(flags_data)} bytes")

    except LevelParseError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
