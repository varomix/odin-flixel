package flixel

import "core:fmt"
import rl "vendor:raylib"

// Text is a text rendering object
Text :: struct {
	using base:  Object,
	text:        string,
	font_size:   i32,
	color:       rl.Color,

	// Internal text bounds
	text_width:  f32,
	text_height: f32,
}

// Constructor
text_new :: proc(x, y: f32, width: f32, text: string, font_size: i32 = 20) -> ^Text {
	txt := new(Text)

	// Initialize base object
	object_init(&txt.base, x, y, width, f32(font_size))

	// Set text properties
	txt.text = text
	txt.font_size = font_size
	txt.color = rl.WHITE

	// Measure text
	measured := rl.MeasureTextEx(rl.GetFontDefault(), cstring(raw_data(text)), f32(font_size), 1.0)
	txt.text_width = measured.x
	txt.text_height = measured.y

	return txt
}

// Update (text doesn't need updating by default)
text_update :: proc(txt: ^Text, dt: f32) {
	if !txt.active || !txt.exists {
		return
	}
	// Text objects don't typically need physics updates
	// but we keep this for consistency
}

// Draw the text
text_draw :: proc(txt: ^Text) {
	if !txt.visible || !txt.exists {
		return
	}

	rl.DrawText(cstring(raw_data(txt.text)), i32(txt.x), i32(txt.y), txt.font_size, txt.color)
}

// Destroy
text_destroy :: proc(txt: ^Text) {
	txt.exists = false
	free(txt)
}

// Helper to change text
text_set_text :: proc(txt: ^Text, text: string) {
	txt.text = text
	measured := rl.MeasureTextEx(
		rl.GetFontDefault(),
		cstring(raw_data(text)),
		f32(txt.font_size),
		1.0,
	)
	txt.text_width = measured.x
	txt.text_height = measured.y
}

// Helper to change color
text_set_color :: proc(txt: ^Text, color: rl.Color) {
	txt.color = color
}
