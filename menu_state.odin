package main

import "core:fmt"
import flx "flixel"

// MenuState is an example menu state
MenuState :: struct {
	using base:   flx.State,
	title:        ^flx.Text,
	instructions: ^flx.Text,
	subtitle:     ^flx.Text,
	info:         ^flx.Text,
	frame_count:  f32,
}

// Create a new MenuState
menu_state_new :: proc() -> ^MenuState {
	state := flx.state_make(MenuState, menu_state_create, menu_state_update)
	state.frame_count = 0
	return state
}

// Create - this is where we set up our menu
menu_state_create :: proc(state: ^flx.State) {
	menu := cast(^MenuState)state

	// Create title text - super clean API!
	menu.title = flx.text_new(100, 100, 400, "ODIN FLIXEL", 32, flx.WHITE)
	flx.state_add(menu, menu.title)

	// Create subtitle (blinking text)
	menu.subtitle = flx.text_new(100, 200, 400, "A Flixel-like Framework", 16, flx.GRAY)
	flx.text_enable_blink(menu.subtitle, 2.0) // Blink 2 times per second
	flx.state_add(menu, menu.subtitle)

	// Create instructions
	menu.instructions = flx.text_new(100, 250, 400, "Press SPACE to start", 16, flx.WHITE)
	flx.state_add(menu, menu.instructions)
}

menu_state_update :: proc(state: ^flx.State, dt: f32) {
	menu := cast(^MenuState)state

	// Update frame counter for animations
	menu.frame_count += dt

	// Check for input to switch to play state
	if flx.key_pressed(.SPACE) {
		fmt.println("Switching to Play State...")
		new_state := play_state_new()
		flx.switch_state(flx.game, new_state)
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
