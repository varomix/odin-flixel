package flixybird

import flx "../../flixel"

PlayState :: struct {
	using base: flx.State,
	bg:         ^flx.Sprite,
	player:     ^flx.Sprite,
	score:      ^flx.Text,
	pipe:       ^Pipe,
}

bird_speed: f32 = 300.0
bird_drag: f32 = bird_speed * 100

// Create a new play state
play_state_new :: proc() -> ^PlayState {
	return flx.state_make(PlayState, play_state_create, play_state_update)
}

play_state_create :: proc(state: ^flx.State) {
	ps := cast(^PlayState)state

	flx.set_bg_color(flx.game, flx.BLUE)

	player_size := [2]i32{16, 16}

	// add background
	ps.bg = flx.sprite_new(0, 0)
	flx.sprite_load_graphic(ps.bg, "sprites/background-day.png")
	flx.state_add(ps, ps.bg)

	ps.score = flx.text_new(2, 2, 80, "SCORE: 0", 10) // Create score
	flx.state_add(ps, ps.score)

	// Create player
	ps.player = flx.sprite_new(f32(flx.get_width() / 4.0), f32(flx.get_height() / 2.0))
	// flx.sprite_make_graphic(ps.player, player_size.x, player_size.y, flx.GREEN)
	flx.sprite_load_graphic(ps.player, "sprites/bluebird-midflap.png")

	ps.player.max_velocity = {80, 2000}
	ps.player.acceleration.y = bird_speed
	ps.player.drag.y = bird_drag
	flx.state_add(ps, ps.player)

	// add pipes
	pipe := pipe_new(f32(flx.get_width()), 300, 0)
	flx.state_add(ps, pipe)


}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	ps := cast(^PlayState)state

	flx.global_update_input()

	ps.player.acceleration.x = 0

	if flx.keys_just_pressed("SPACE") {
		ps.player.velocity.y = -bird_speed
	}


	flx.state_update(&ps.base, dt)

}
