package flixel

import "core:fmt"
import rl "vendor:raylib"

// Game is the main game engine
Game :: struct {
	width:         i32,
	height:        i32,
	title:         cstring,

	// Scale factor for pixel-perfect scaling
	scale:         i32,

	// Render texture for scaling
	render_target: rl.RenderTexture2D,

	// Current state
	state:         ^State,

	// Background color
	bg_color:      Color,

	// Frame timing
	target_fps:    i32,

	// Quit flag
	should_quit:   bool,
}

// Global game instance
game: ^Game

// Global custom font
custom_font: rl.Font
font_loaded: bool = false
font_spacing: f32 = 1.0 // Spacing between characters

// Initialize the game engine
init :: proc(
	width, height: i32,
	title: cstring,
	initial_state: ^State,
	target_fps: i32 = 60,
	scale: i32 = 1,
) -> ^Game {
	g := new(Game)

	g.width = width
	g.height = height
	g.title = title
	g.target_fps = target_fps
	g.scale = scale
	g.bg_color = BLACK
	g.should_quit = false

	// Set global reference
	game = g

	// Initialize Raylib with scaled window size
	window_width := width * scale
	window_height := height * scale
	rl.InitWindow(window_width, window_height, title)
	rl.SetTargetFPS(target_fps)

	// Disable ESC as exit key so games can use it for navigation
	rl.SetExitKey(.KEY_NULL)

	// Load custom font
	load_custom_font("flixel/data/nokiafc22.ttf")

	// Create render texture at base resolution for pixel-perfect scaling
	if scale > 1 {
		g.render_target = rl.LoadRenderTexture(width, height)
		rl.SetTextureFilter(g.render_target.texture, .POINT) // Nearest-neighbor for crisp pixels
	}

	// Set initial state
	if initial_state != nil {
		switch_state(g, initial_state)
	}

	return g
}

// Switch to a new state
switch_state :: proc(g: ^Game, new_state: ^State) {
	// Destroy old state if it exists
	if g.state != nil {
		state_destroy(g.state)
		free(g.state)
	}

	// Set new state
	g.state = new_state

	// Initialize new state (call create callback)
	if g.state != nil {
		if g.state.vtable != nil && g.state.vtable.create != nil {
			g.state.vtable.create(g.state)
		}
	}
}

// Run the game loop
run :: proc(g: ^Game) {
	for !rl.WindowShouldClose() && !g.should_quit {
		dt := rl.GetFrameTime()

		// Update
		if g.state != nil {
			if g.state.vtable != nil && g.state.vtable.update != nil {
				g.state.vtable.update(g.state, dt)
			} else {
				state_update(g.state, dt)
			}
		}

		// Draw
		if g.scale > 1 {
			// Render to texture at base resolution
			rl.BeginTextureMode(g.render_target)
			rl.ClearBackground(g.bg_color)

			if g.state != nil {
				if g.state.vtable != nil && g.state.vtable.draw != nil {
					g.state.vtable.draw(g.state)
				} else {
					state_draw(g.state)
				}
			}

			rl.EndTextureMode()

			// Draw scaled texture to screen
			rl.BeginDrawing()
			rl.ClearBackground(BLACK)

			// Flip texture vertically (Raylib render textures are upside down)
			source := rl.Rectangle{0, 0, f32(g.width), -f32(g.height)}
			dest := rl.Rectangle{0, 0, f32(g.width * g.scale), f32(g.height * g.scale)}
			rl.DrawTexturePro(g.render_target.texture, source, dest, {0, 0}, 0, rl.WHITE)

			rl.EndDrawing()
		} else {
			// No scaling, draw directly
			rl.BeginDrawing()
			rl.ClearBackground(g.bg_color)

			if g.state != nil {
				if g.state.vtable != nil && g.state.vtable.draw != nil {
					g.state.vtable.draw(g.state)
				} else {
					state_draw(g.state)
				}
			}

			rl.EndDrawing()
		}
	}

	// Cleanup
	if g.state != nil {
		state_destroy(g.state)
		free(g.state)
	}

	// Unload render texture
	if g.scale > 1 {
		rl.UnloadRenderTexture(g.render_target)
	}

	// Unload custom font if it was loaded
	if font_loaded {
		rl.UnloadFont(custom_font)
	}

	rl.CloseWindow()
}

// Set background color
set_bg_color :: proc(g: ^Game, color: Color) {
	g.bg_color = color
}

// Quit the game
quit :: proc() {
	if game != nil {
		game.should_quit = true
	}
}

// Load a custom font from a file path
load_custom_font :: proc(font_path: string) {
	custom_font = rl.LoadFont(cstring(raw_data(font_path)))
	if custom_font.texture.id != 0 {
		font_loaded = true
		fmt.println("Custom font loaded successfully:", font_path)
	} else {
		fmt.println("Warning: Failed to load custom font, using default")
		custom_font = rl.GetFontDefault()
	}
}

// Set the spacing between characters for the custom font
set_font_spacing :: proc(spacing: f32) {
	font_spacing = spacing
}

// Get the current font spacing
get_font_spacing :: proc() -> f32 {
	return font_spacing
}
