package main

import "core:fmt"
import flx "../../flixel"

main :: proc() {
	fmt.println("Starting Flx Invaders...")

	// Create the initial play state
	initial_state := play_state_new()

	// Initialize the game engine
	game := flx.init(
		320, // width
		240, // height
		"Flx Invaders", // title
		&initial_state.base, // initial state
		60, // target FPS
		2, // scale factor
	)

	// Set background color
	flx.set_bg_color(game, flx.BLACK)

	// Run the game loop
	flx.run(game)

	fmt.println("Flx Invaders closed!")
}
