package flixel

import rl "vendor:raylib"

// Color represents an RGBA color
// This wraps raylib's Color but provides a flixel-native type
Color :: rl.Color

// Common color constants
BLACK :: Color{0, 0, 0, 255}
WHITE :: Color{255, 255, 255, 255}
RED :: Color{230, 41, 55, 255}
GREEN :: Color{0, 228, 48, 255}
BLUE :: Color{0, 121, 241, 255}
YELLOW :: Color{253, 249, 0, 255}
ORANGE :: Color{255, 161, 0, 255}
PURPLE :: Color{200, 122, 255, 255}
PINK :: Color{255, 109, 194, 255}
BROWN :: Color{127, 106, 79, 255}
GRAY :: Color{130, 130, 130, 255}
DARK_GRAY :: Color{80, 80, 80, 255}
LIGHT_GRAY :: Color{200, 200, 200, 255}

// Helper function to create a color from RGBA values
rgba :: proc(r, g, b, a: u8) -> Color {
	return Color{r, g, b, a}
}

// Helper function to create a color from RGB values (alpha = 255)
rgb :: proc(r, g, b: u8) -> Color {
	return Color{r, g, b, 255}
}

// Helper function to create a color from a hex value
// Supports both 0xRRGGBB (RGB, alpha defaults to 0xFF) and 0xRRGGBBAA (RGBA) formats
hex :: proc(hex_value: u32) -> Color {
	// If value is <= 0xFFFFFF, treat as RGB (6 digits) with alpha = 0xFF
	if hex_value <= 0xFFFFFF {
		r := u8((hex_value >> 16) & 0xFF)
		g := u8((hex_value >> 8) & 0xFF)
		b := u8(hex_value & 0xFF)
		return Color{r, g, b, 0xFF}
	}

	// Otherwise treat as RGBA (8 digits)
	r := u8((hex_value >> 24) & 0xFF)
	g := u8((hex_value >> 16) & 0xFF)
	b := u8((hex_value >> 8) & 0xFF)
	a := u8(hex_value & 0xFF)
	return Color{r, g, b, a}
}

// Create color with convenience proc
make_color :: proc {
	rgba,
	rgb,
	hex,
}
