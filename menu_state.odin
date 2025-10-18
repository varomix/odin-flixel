package main

import "core:fmt"
import flx "flixel"

// MenuState is an example menu state
MenuState :: struct {
	using base:  flx.State,
	title:       ^flx.Text,
	subtitle:    ^flx.Text,
	info:        ^flx.Text,
	frame_count: f32,
}

// Create a new MenuState
menu_state_new :: proc() -> ^MenuState {
	state := new(MenuState)

	// Setup state with lifecycle callbacks - no manual vtable needed!
	flx.state_setup(&state.base, menu_state_create, menu_state_update)

	state.frame_count = 0

	return state
}

// Create - this is where we set up our menu
menu_state_create :: proc(state: ^flx.State) {
	menu := cast(^MenuState)state

	// Add a title (using new color parameter)
	menu.title = flx.text_new(200, 100, 400, "MIX MOTOR", 48, flx.YELLOW)
	flx.state_add(&menu.base, &menu.title.base)

	// Add a subtitle with instructions (using new color parameter)
	menu.subtitle = flx.text_new(150, 200, 400, "Press SPACE to start", 24, flx.WHITE)
	flx.state_add(&menu.base, &menu.subtitle.base)

	// Add info about custom font
	menu.info = flx.text_new(150, 280, 400, "Using Nokia FC22 Custom Font", 16, flx.LIGHT_GRAY)
	flx.state_add(&menu.base, &menu.info.base)
}

// Update the menu state
menu_state_update :: proc(state: ^flx.State, dt: f32) {
	menu := cast(^MenuState)state

	// Update frame counter for animations
	menu.frame_count += dt

	// Make the subtitle blink
	if int(menu.frame_count * 2) % 2 == 0 {
		menu.subtitle.visible = true
	} else {
		menu.subtitle.visible = false
	}

	// Check for input to switch to play state
	if flx.key_pressed(.SPACE) {
		fmt.println("Switching to Play State...")
		new_state := play_state_new()
		flx.switch_state(flx.game, &new_state.base)
	}

	// Check for ESC to quit
	if flx.key_pressed(.ESCAPE) {
		fmt.println("Quitting game...")
		flx.quit()
	}

	// Update all members
	flx.state_update(&menu.base, dt)

	// Draw additional instructions - one-liner!
	flx.text_quick(10, 550, "SPACE to play | ESC to quit", 16, flx.GRAY)

	// Show font info
	flx.text_quick(10, 10, "Custom Font Demo", 20, flx.GREEN)
	flx.text_quick(10, 35, "8px size", 8, flx.WHITE)
	flx.text_quick(10, 50, "16px size", 16, flx.WHITE)
	flx.text_quick(10, 70, "24px size", 24, flx.ORANGE)
	flx.text_quick(10, 100, "32px size", 32, flx.PURPLE)
}
