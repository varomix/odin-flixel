package flixybird

import flx "../../flixel"

PlayState :: struct {
	using base: flx.State,
	player:     ^flx.Sprite,
	score:      ^flx.Text,
}

// Create a new play state
play_state_new :: proc() -> ^PlayState {
	return flx.state_make(PlayState, play_state_create, play_state_update)
}

play_state_create :: proc(state: ^flx.State) {
	ps := cast(^PlayState)state

	flx.set_bg_color(flx.game, flx.BLUE)

	player_size := [2]i32{16, 16}

	// Create score
	ps.score = flx.text_new(2, 2, 80, "SCORE: 0", 10)
	flx.state_add(ps, ps.score)

	// Create player
	ps.player = flx.sprite_new(f32(flx.get_width() / 3.0), f32(flx.get_height() / 2.0))
	// flx.sprite_make_graphic(ps.player, player_size.x, player_size.y, flx.GREEN)
	flx.sprite_load_graphic(ps.player, "sprites/bluebird-midflap.png")
	ps.player.max_velocity = {80, 200}
	ps.player.acceleration.y = 200
	ps.player.drag.x = ps.player.max_velocity.x * 4

	flx.state_add(ps, ps.player)
}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	ps := cast(^PlayState)state

	flx.global_update_input()

	ps.player.acceleration.x = 0

	if flx.keys_just_pressed("SPACE") {
		ps.player.velocity.y = -ps.player.max_velocity.y / 2.0
	}


	flx.state_update(&ps.base, dt)
	// Update score
	// score_txt := ps.score
	// score_txt.text = "SCORE: " + str(ps.score.value)
	flx.text_quick(10, 20, "ESC to return to menu", 16, flx.BLACK)

}
