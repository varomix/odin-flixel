package flixel

import "core:fmt"
import rl "vendor:raylib"

// Text is a text rendering object
Text :: struct {
	using base:  Object,
	text:        string,
	font_size:   i32,
	color:       Color,

	// Internal text bounds
	text_width:  f32,
	text_height: f32,
}

// Constructor with default color
text_new_default :: proc(x, y: f32, width: f32, text: string, font_size: i32 = 20) -> ^Text {
	return text_new_with_color(x, y, width, text, font_size, WHITE)
}

// Constructor with custom color
text_new_with_color :: proc(x, y: f32, width: f32, text: string, font_size: i32, color: Color) -> ^Text {
	txt := new(Text)

	// Initialize base object
	object_init(&txt.base, x, y, width, f32(font_size))

	// Set text properties
	txt.text = text
	txt.font_size = font_size
	txt.color = color

	// Measure text
	measured := rl.MeasureTextEx(rl.GetFontDefault(), cstring(raw_data(text)), f32(font_size), 1.0)
	txt.text_width = measured.x
	txt.text_height = measured.y

	return txt
}

// Overloaded constructor
text_new :: proc {
	text_new_default,
	text_new_with_color,
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
text_set_color :: proc(txt: ^Text, color: Color) {
	txt.color = color
}

// Quick text drawing - one-liner for simple text rendering
// This is useful for debug text or UI that doesn't need to be part of the state
text_quick :: proc(x, y: f32, text: string, font_size: i32 = 20, color: Color = WHITE) {
	rl.DrawText(cstring(raw_data(text)), i32(x), i32(y), font_size, color)
}
