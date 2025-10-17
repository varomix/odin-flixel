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

// Create color with convenience proc
make_color :: proc {
	rgba,
	rgb,
}
