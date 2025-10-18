package flixybird

import flx "../../flixel"
import "core:fmt"

main :: proc() {
	fmt.println("Hello, World little bird!")

	// Init global state
	flx.global_init()

	// intial game state
	initial_state := play_state_new()

	// Initialize the game engine (320x240 scaled 2x )
	game := flx.init(320, 240, "FlixyBird", &initial_state.base, 60, 3)

	flx.run(game)
}
