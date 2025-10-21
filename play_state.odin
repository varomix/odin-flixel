package main

import "core:fmt"
import flx "flixel"

// PlayState is our main game state
PlayState :: struct {
	using base: flx.State,
}

// Create a new PlayState
play_state_new :: proc() -> ^PlayState {
	state := new(PlayState)

	// Setup state with lifecycle callbacks - no manual vtable needed!
	flx.state_setup(&state.base, play_state_create, play_state_update)

	return state
}

// Create - this is where we set up our state
play_state_create :: proc(state: ^flx.State) {
	play := cast(^PlayState)state

	// Add a text field at position 0,0 with width 100
	text := flx.text_new(200, 200, 100, "You are in the Play State!")
	flx.state_add(play, text)
}

// Update the state
play_state_update :: proc(state: ^flx.State, dt: f32) {
	play := cast(^PlayState)state

	// Check for input to return to menu
	if flx.key_pressed(.ESCAPE) {
		fmt.println("Returning to Menu State...")
		menu := menu_state_new()
		flx.switch_state(flx.game, menu)
		return
	}

	// Update all members
	flx.state_update(&play.base, dt)

	// Custom update logic can go here

	// Draw instructions - one-liner!
	flx.text_quick(10, 570, "ESC to return to menu", 16, flx.GRAY)
}
