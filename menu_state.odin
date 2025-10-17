package main

import "core:fmt"
import flx "flixel"
import rl "vendor:raylib"

// MenuState is an example menu state
MenuState :: struct {
	using base:  flx.State,
	title:       ^flx.Text,
	subtitle:    ^flx.Text,
	frame_count: f32,
}

// Create a new MenuState
menu_state_new :: proc() -> ^MenuState {
	state := new(MenuState)

	// Setup state with lifecycle callbacks - no manual vtable needed!
	flx.state_setup(&state.base, menu_state_create, menu_state_update, menu_state_draw)

	state.frame_count = 0

	return state
}

// Create - this is where we set up our menu
menu_state_create :: proc(state: ^flx.State) {
	menu := cast(^MenuState)state

	// Add a title
	menu.title = flx.text_new(250, 150, 400, "MIX MOTOR", 48)
	flx.text_set_color(menu.title, rl.YELLOW)
	flx.state_add(&menu.base, &menu.title.base)

	// Add a subtitle with instructions
	menu.subtitle = flx.text_new(200, 250, 400, "Press SPACE to start", 24)
	flx.text_set_color(menu.subtitle, rl.WHITE)
	flx.state_add(&menu.base, &menu.subtitle.base)
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
	if rl.IsKeyPressed(.SPACE) {
		fmt.println("Switching to Play State...")
		new_state := play_state_new()
		flx.switch_state(flx.game, &new_state.base)
	}

	// Check for ESC to quit
	if rl.IsKeyPressed(.ESCAPE) {
		fmt.println("Quitting game...")
		flx.quit()
	}

	// Update all members
	flx.state_update(&menu.base, dt)
}

// Draw the menu state
menu_state_draw :: proc(state: ^flx.State) {
	menu := cast(^MenuState)state

	// Draw all members
	for member in menu.members {
		if member.exists && member.visible {
			text := cast(^flx.Text)member
			if text != nil {
				flx.text_draw(text)
			}
		}
	}

	// Draw additional instructions
	rl.DrawText("SPACE to play | ESC to quit", 10, 570, 16, rl.GRAY)
}
