package main

import "core:fmt"
import flx "flixel"
import rl "vendor:raylib"

// PlayState is our main game state
PlayState :: struct {
	using base: flx.State,
}

// Create a new PlayState
play_state_new :: proc() -> ^PlayState {
	state := new(PlayState)

	// Setup state with lifecycle callbacks - no manual vtable needed!
	flx.state_setup(&state.base, play_state_create, play_state_update, play_state_draw)

	return state
}

// Create - this is where we set up our state
play_state_create :: proc(state: ^flx.State) {
	play := cast(^PlayState)state

	// Add a text field at position 0,0 with width 100
	text := flx.text_new(200, 200, 100, "You are in the Play State!")
	flx.state_add(&play.base, &text.base)
}

// Update the state
play_state_update :: proc(state: ^flx.State, dt: f32) {
	play := cast(^PlayState)state

	// Check for input to return to menu
	if rl.IsKeyPressed(.ESCAPE) {
		fmt.println("Returning to Menu State...")
		menu := menu_state_new()
		flx.switch_state(flx.game, &menu.base)
		return
	}

	// Update all members
	flx.state_update(&play.base, dt)

	// Custom update logic can go here
}

// Draw the state
play_state_draw :: proc(state: ^flx.State) {
	play := cast(^PlayState)state

	// Draw all members
	for member in play.members {
		if member.exists && member.visible {
			// Check if it's a Text and draw it appropriately
			text := cast(^flx.Text)member
			if text != nil {
				flx.text_draw(text)
			}
		}
	}

	// Draw instructions
	rl.DrawText("ESC to return to menu", 10, 570, 16, rl.GRAY)
}
