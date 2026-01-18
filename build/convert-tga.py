#!/usr/bin/env python3
"""
Convert TGA images to C64 binary formats.

Usage:
    python3 convert-tga.py <input.tga> <output.bin> --format <type>

Formats:
    hires-chars    - 1-bit 8x8 characters (e.g., HUD font, charset)

To add a new format:
    1. Create a converter function: convert_<name>(pixels, width, height) -> bytes
    2. Add entry to FORMATS dict with grid dimensions and converter function
"""

import sys
import argparse


# =============================================================================
# TGA Parser
# =============================================================================


def parse_tga(filepath):
    """
    Parse a TGA file and return image metadata and pixel data.

    Returns:
        dict with keys:
            - width: image width in pixels
            - height: image height in pixels
            - pixels: list of palette indices (row-major, top-left origin)
            - palette: list of (r, g, b) tuples
    """
    with open(filepath, "rb") as f:
        tga = f.read()

    # Parse header
    id_length = tga[0]
    color_map_type = tga[1]
    image_type = tga[2]
    color_map_start = tga[3] | (tga[4] << 8)
    color_map_length = tga[5] | (tga[6] << 8)
    color_map_depth = tga[7]
    width = tga[12] | (tga[13] << 8)
    height = tga[14] | (tga[15] << 8)
    bits_per_pixel = tga[16]
    image_descriptor = tga[17]

    # Validate format
    if image_type != 1:
        raise ValueError(f"Expected indexed color TGA (type 1), got type {image_type}")
    if bits_per_pixel != 8:
        raise ValueError(f"Expected 8-bit indexed image, got {bits_per_pixel}-bit")

    # Parse palette
    header_size = 18
    id_size = id_length
    palette_offset = header_size + id_size
    bytes_per_color = color_map_depth // 8

    palette = []
    for i in range(color_map_length):
        offset = palette_offset + i * bytes_per_color
        if bytes_per_color == 3:
            b, g, r = tga[offset], tga[offset + 1], tga[offset + 2]
        elif bytes_per_color == 4:
            b, g, r = tga[offset], tga[offset + 1], tga[offset + 2]
            # alpha = tga[offset + 3]  # ignored
        else:
            raise ValueError(f"Unsupported palette depth: {color_map_depth} bits")
        palette.append((r, g, b))

    # Read pixel data
    pixel_data_offset = palette_offset + color_map_length * bytes_per_color
    pixels_raw = tga[pixel_data_offset : pixel_data_offset + width * height]

    if len(pixels_raw) != width * height:
        raise ValueError(f"Expected {width * height} pixels, got {len(pixels_raw)}")

    # Convert to top-left origin if needed
    top_left_origin = (image_descriptor & 0x20) != 0

    if top_left_origin:
        pixels = list(pixels_raw)
    else:
        # Flip vertically
        pixels = []
        for y in range(height - 1, -1, -1):
            row_start = y * width
            pixels.extend(pixels_raw[row_start : row_start + width])

    return {
        "width": width,
        "height": height,
        "pixels": pixels,
        "palette": palette,
    }


def get_pixel(image, x, y):
    """Get palette index at (x, y) from parsed image."""
    return image["pixels"][y * image["width"] + x]


# =============================================================================
# Format Converters
# =============================================================================


def convert_hires_chars(image, cell_width, cell_height, cells_per_row):
    """
    Convert image to 1-bit character data.

    Each character is 8 bytes (one byte per row).
    Palette index 0 = background (bit 0), any other index = foreground (bit 1).
    """
    width = image["width"]
    height = image["height"]

    cols = width // cell_width
    rows = height // cell_height

    output = bytearray()

    for char_idx in range(cols * rows):
        col = char_idx % cols
        row = char_idx // cols
        base_x = col * cell_width
        base_y = row * cell_height

        for y in range(cell_height):
            byte = 0
            for x in range(cell_width):
                color_idx = get_pixel(image, base_x + x, base_y + y)
                if color_idx != 0:
                    byte |= 1 << (7 - x)
            output.append(byte)

    return bytes(output)


# =============================================================================
# Format Registry
# =============================================================================

FORMATS = {
    "hires-chars": {
        "description": "1-bit 8x8 characters (e.g., HUD font, charset)",
        "cell_width": 8,
        "cell_height": 8,
        "converter": convert_hires_chars,
    },
    # Future formats:
    # 'multicolor-sprites': { ... }
    # 'hires-sprites': { ... }
}


# =============================================================================
# Main
# =============================================================================


def main():
    parser = argparse.ArgumentParser(
        description="Convert TGA images to C64 binary formats.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Formats:\n"
        + "\n".join(
            f"  {name:20} {info['description']}" for name, info in FORMATS.items()
        ),
    )
    parser.add_argument("input", help="Input TGA file")
    parser.add_argument("output", help="Output binary file")
    parser.add_argument(
        "--format", "-f", required=True, choices=FORMATS.keys(), help="Output format"
    )

    args = parser.parse_args()

    # Parse TGA
    try:
        image = parse_tga(args.input)
    except Exception as e:
        print(f"Error reading {args.input}: {e}", file=sys.stderr)
        sys.exit(1)

    # Get format info
    fmt = FORMATS[args.format]
    cell_width = fmt["cell_width"]
    cell_height = fmt["cell_height"]

    # Validate dimensions
    if image["width"] % cell_width != 0:
        print(
            f"Error: Image width {image['width']} not divisible by {cell_width}",
            file=sys.stderr,
        )
        sys.exit(1)
    if image["height"] % cell_height != 0:
        print(
            f"Error: Image height {image['height']} not divisible by {cell_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    # Convert
    cols = image["width"] // cell_width
    output = fmt["converter"](image, cell_width, cell_height, cols)

    # Write output
    with open(args.output, "wb") as f:
        f.write(output)

    print(f"Converted {args.input} -> {args.output} ({len(output)} bytes)")


if __name__ == "__main__":
    main()
