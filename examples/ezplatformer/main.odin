package ezplatformer

import flx "../../flixel"
import "core:fmt"

main :: proc() {
	fmt.println("Starting EZPlatformer Example...")

	// Initialize global state
	flx.global_init()

	// Create the initial play state
	initial_state := play_state_new()

	// Initialize the game engine (320x240 scaled 2x = 640x480)
	game := flx.init(
		320, // width
		240, // height
		"EZPlatformer - Odin Flixel Example",
		&initial_state.base,
		60,
		2, // scale factor
	)

	// Set background color
	flx.set_bg_color(game, flx.Color{170, 170, 170, 255})

	// Run the game loop
	flx.run(game)

	fmt.println("EZPlatformer closed!")
}
