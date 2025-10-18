package flixybird

import flx "../../flixel"
import "core:sys/darwin/CoreFoundation"

PlayState :: struct {
	using base: flx.State,
	player:     ^flx.Sprite,
	score:      ^flx.Text,
}

// Create a new play state
play_state_new :: proc() -> ^PlayState {
	state := new(PlayState)
	flx.state_setup(&state.base, play_state_create, play_state_update)
	return state
}

play_state_create :: proc(state: ^flx.State) {
	ps := cast(^PlayState)state

	flx.set_bg_color(flx.game, flx.BLUE)

	// Create score
	ps.score = flx.text_new(2, 2, 80, "SCORE: 0", 10)
	flx.state_add(&ps.base, cast(^flx.Object)ps.score)

	// Create player
	ps.player = flx.sprite_new(f32(flx.get_width() / 2.0), f32(flx.get_height() / 2.0))
	flx.sprite_make_graphic(ps.player, 16, 16, flx.GREEN)
	flx.state_add(&ps.base, cast(^flx.Object)ps.player)
}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	ps := cast(^PlayState)state

	// Update score
	// score_txt := ps.score
	// score_txt.text = "SCORE: " + str(ps.score.value)
	flx.text_quick(10, 20, "ESC to return to menu", 16, flx.BLACK)

}
