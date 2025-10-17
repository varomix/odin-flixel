package main

import "core:fmt"
import flx "flixel"

main :: proc() {
	fmt.println("Starting Mix Motor - Flixel-like Game Engine...")

	// Create the initial state (start with menu)
	initial_state := menu_state_new()

	// Initialize the game engine
	game := flx.init(
		800, // width
		600, // height
		"Mix Motor - Game Framework", // title
		&initial_state.base, // initial state
		60, // target FPS
	)

	// Set background color
	flx.set_bg_color(game, flx.Color{20, 20, 40, 255})

	// Run the game loop
	flx.run(game)

	fmt.println("Game closed!")
}
