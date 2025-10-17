package flixel

import "core:fmt"
import rl "vendor:raylib"

// Game is the main game engine
Game :: struct {
	width:      i32,
	height:     i32,
	title:      cstring,

	// Current state
	state:      ^State,

	// Background color
	bg_color:   rl.Color,

	// Frame timing
	target_fps: i32,
}

// Global game instance
game: ^Game

// Initialize the game engine
init :: proc(
	width, height: i32,
	title: cstring,
	initial_state: ^State,
	target_fps: i32 = 60,
) -> ^Game {
	g := new(Game)

	g.width = width
	g.height = height
	g.title = title
	g.target_fps = target_fps
	g.bg_color = rl.BLACK

	// Set global reference
	game = g

	// Initialize Raylib
	rl.InitWindow(width, height, title)
	rl.SetTargetFPS(target_fps)

	// Disable ESC as exit key so games can use it for navigation
	rl.SetExitKey(.KEY_NULL)

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
	for !rl.WindowShouldClose() {
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

	// Cleanup
	if g.state != nil {
		state_destroy(g.state)
		free(g.state)
	}

	rl.CloseWindow()
}

// Set background color
set_bg_color :: proc(g: ^Game, color: rl.Color) {
	g.bg_color = color
}

// Quit the game
quit :: proc() {
	rl.CloseWindow()
}
