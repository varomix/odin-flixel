package spaceshooter

import flx "../../flixel"

main :: proc() {
	flx.global_init()

	init_state := play_state_new()

	game := flx.init(640, 480, "Flixel Space Shooter", &init_state.base, 60, 1)

	flx.set_bg_color(flx.game, flx.Color{171, 204, 125, 255})

	flx.run(game)
}
