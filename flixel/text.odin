package flixel

import rl "vendor:raylib"

// A struct to hold all the info for a quick text draw call
QuickText :: struct {
	x:         f32,
	y:         f32,
	text:      string,
	font_size: i32,
	color:     Color,
}

// A queue to hold all the quick text draw calls for the current frame
quick_text_queue: [dynamic]QuickText

// Text alignment options
TextAlignment :: enum {
	LEFT,
	CENTER,
	RIGHT,
}

// Text is a text rendering object
Text :: struct {
	using base:    Object,
	text:          string,
	font_size:     i32,
	color:         Color,
	alignment:     TextAlignment,

	// Internal text bounds
	text_width:    f32,
	text_height:   f32,

	// Blinking properties
	blink_enabled: bool,
	blink_rate:    f32, // How fast to blink (times per second)
	blink_timer:   f32, // Internal timer for blinking
	blink_visible: bool, // Current blink state
}

// Constructor with default color
text_new_default :: proc(x, y: f32, width: f32, text: string, font_size: i32 = 20) -> ^Text {
	return text_new_with_color(x, y, width, text, font_size, WHITE)
}

// Constructor with custom color
text_new_with_color :: proc(
	x, y: f32,
	width: f32,
	text: string,
	font_size: i32,
	color: Color,
) -> ^Text {
	txt := new(Text)

	// Initialize base object
	object_init(&txt.base, x, y, width, f32(font_size))

	// Set text properties
	txt.text = text
	txt.font_size = font_size
	txt.color = color
	txt.alignment = .LEFT

	// Override vtable for text-specific behavior
	txt.base.vtable.update = text_update_obj
	txt.base.vtable.draw = text_draw_obj
	txt.base.vtable.destroy = text_destroy_obj

	// Measure text using custom font
	font := rl.GetFontDefault()
	if font_loaded {
		font = custom_font
	}
	measured := rl.MeasureTextEx(font, cstring(raw_data(text)), f32(font_size), font_spacing)
	txt.text_width = measured.x
	txt.text_height = measured.y

	return txt
}

// Overloaded constructor
text_new :: proc {
	text_new_default,
	text_new_with_color,
}

// VTable wrapper functions
text_update_obj :: proc(obj: ^Object, dt: f32) {
	txt := cast(^Text)obj
	text_update(txt, dt)
}

text_draw_obj :: proc(obj: ^Object) {
	txt := cast(^Text)obj
	text_draw(txt)
}

text_destroy_obj :: proc(obj: ^Object) {
	txt := cast(^Text)obj
	text_destroy(txt)
}

// Update text (handles blinking)
text_update :: proc(txt: ^Text, dt: f32) {
	if !txt.active || !txt.exists {
		return
	}

	// Handle blinking
	if txt.blink_enabled {
		txt.blink_timer += dt
		blink_interval := 1.0 / txt.blink_rate
		if txt.blink_timer >= blink_interval {
			txt.blink_timer = 0
			txt.blink_visible = !txt.blink_visible
			txt.visible = txt.blink_visible
		}
	}
}

// Draw the text
text_draw :: proc(txt: ^Text) {
	if !txt.visible || !txt.exists {
		return
	}

	// Calculate text position based on alignment
	text_x := txt.x
	switch txt.alignment {
	case .LEFT:
		text_x = txt.x
	case .CENTER:
		text_x = txt.x + (txt.width - txt.text_width) / 2
	case .RIGHT:
		text_x = txt.x + txt.width - txt.text_width
	}

	// Use custom font if loaded
	if font_loaded {
		rl.DrawTextEx(
			custom_font,
			cstring(raw_data(txt.text)),
			{text_x, txt.y},
			f32(txt.font_size),
			font_spacing,
			txt.color,
		)
	} else {
		rl.DrawText(cstring(raw_data(txt.text)), i32(text_x), i32(txt.y), txt.font_size, txt.color)
	}
}

// Destroy
text_destroy :: proc(txt: ^Text) {
	txt.exists = false
	free(txt)
}

// Helper to change text
text_set_text :: proc(txt: ^Text, text: string) {
	txt.text = text
	font := rl.GetFontDefault()
	if font_loaded {
		font = custom_font
	}
	measured := rl.MeasureTextEx(font, cstring(raw_data(text)), f32(txt.font_size), font_spacing)
	txt.text_width = measured.x
	txt.text_height = measured.y
}

// Helper to change color
text_set_color :: proc(txt: ^Text, color: Color) {
	txt.color = color
}

// Helper to set alignment
text_set_alignment :: proc(txt: ^Text, alignment: TextAlignment) {
	txt.alignment = alignment
}

// Enable blinking on text
text_enable_blink :: proc(txt: ^Text, rate: f32 = 2.0) {
	txt.blink_enabled = true
	txt.blink_rate = rate
	txt.blink_timer = 0
	txt.blink_visible = true
	txt.visible = true
}

// Disable blinking on text
text_disable_blink :: proc(txt: ^Text) {
	txt.blink_enabled = false
	txt.visible = true
}

// Quick text drawing - one-liner for simple text rendering
// This is useful for debug text or UI that doesn't need to be part of the state
text_quick :: proc(x, y: f32, text: string, font_size: i32 = 20, color: Color = WHITE) {
	// Add the text to the queue to be drawn at the end of the frame
	append(&quick_text_queue, QuickText{x, y, text, font_size, color})
}
