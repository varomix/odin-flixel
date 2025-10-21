package ezplatformer

import flx "../../flixel"
import "core:fmt"

Play_State :: struct {
	using base: flx.State,
	level:      ^flx.Tilemap,
	exit:       ^flx.Sprite,
	coins:      ^flx.Group,
	player:     ^flx.Sprite,
	score:      ^flx.Text,
	status:     ^flx.Text,
}

// Create a new play state
play_state_new :: proc() -> ^Play_State {
	return flx.state_make(Play_State, play_state_create, play_state_update, play_state_draw)
}

// Create callback
play_state_create :: proc(state: ^flx.State) {
	ps := cast(^Play_State)state

	// Set background color to light gray
	if flx.game != nil {
		flx.set_bg_color(flx.game, flx.Color{170, 170, 170, 255})
	}

	// odinfmt: disable
	// Level data (40x30 tiles to fill 320x240 screen at 8x8 tile size)
	data := [1200]int {
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1,
	1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
	1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
	1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
	}
	// odinfmt: enable

	// Create tilemap
	ps.level = flx.tilemap_new()
	csv_data := flx.tilemap_array_to_csv(data[:], 40)
	defer delete(csv_data)
	flx.tilemap_load_map(ps.level, csv_data, 8, 8, flx.AUTO)
	flx.state_add(&ps.base, cast(^flx.Object)ps.level)

	// Create exit (dark gray box, hidden at first)
	ps.exit = flx.sprite_new(35 * 8 + 1, 25 * 8)
	flx.sprite_make_graphic(ps.exit, 14, 16, flx.Color{63, 63, 63, 255})
	ps.exit.exists = false
	flx.state_add(&ps.base, cast(^flx.Object)ps.exit)

	// Create coins group
	ps.coins = flx.group_new()

	// Top left coins
	create_coin(ps, 18, 4)
	create_coin(ps, 12, 4)
	create_coin(ps, 9, 4)
	create_coin(ps, 8, 11)
	create_coin(ps, 1, 7)
	create_coin(ps, 3, 4)
	create_coin(ps, 5, 2)
	create_coin(ps, 15, 11)
	create_coin(ps, 16, 11)

	// Bottom left coins
	create_coin(ps, 3, 16)
	create_coin(ps, 4, 16)
	create_coin(ps, 1, 23)
	create_coin(ps, 2, 23)
	create_coin(ps, 3, 23)
	create_coin(ps, 4, 23)
	create_coin(ps, 5, 23)
	create_coin(ps, 12, 26)
	create_coin(ps, 13, 26)
	create_coin(ps, 17, 20)
	create_coin(ps, 18, 20)

	// Top right coins
	create_coin(ps, 21, 4)
	create_coin(ps, 26, 2)
	create_coin(ps, 29, 2)
	create_coin(ps, 31, 5)
	create_coin(ps, 34, 5)
	create_coin(ps, 36, 8)
	create_coin(ps, 33, 11)
	create_coin(ps, 31, 11)
	create_coin(ps, 29, 11)
	create_coin(ps, 27, 11)
	create_coin(ps, 25, 11)
	create_coin(ps, 36, 14)

	// Bottom right coins
	create_coin(ps, 38, 17)
	create_coin(ps, 33, 17)
	create_coin(ps, 28, 19)
	create_coin(ps, 25, 20)
	create_coin(ps, 18, 26)
	create_coin(ps, 22, 26)
	create_coin(ps, 26, 26)
	create_coin(ps, 30, 26)

	flx.state_add(&ps.base, cast(^flx.Object)ps.coins)

	// Create player (red box) - start at middle top of screen (tile 20, 1)
	ps.player = flx.sprite_new(cast(f32)flx.get_width() / 2.0, 1 * 8)
	flx.sprite_make_graphic(ps.player, 10, 12, flx.Color{170, 17, 17, 255})
	ps.player.max_velocity = {80, 200}
	ps.player.acceleration.y = 200
	ps.player.drag.x = ps.player.max_velocity.x * 4
	flx.state_add(&ps.base, cast(^flx.Object)ps.player)

	// Create score text
	ps.score = flx.text_new(2, 2, 80, "SCORE: 0", 10)
	flx.state_add(&ps.base, cast(^flx.Object)ps.score)

	// Create status text
	status_text := "Collect coins."
	if flx.g.score == 1 {
		status_text = "Aww, you died!"
	}
	ps.status = flx.text_new(f32(flx.get_width()) - 162, 2, 160, status_text, 10)
	flx.state_add(&ps.base, cast(^flx.Object)ps.status)
}

// Create a coin at tile position
create_coin :: proc(ps: ^Play_State, x: int, y: int) {
	coin := flx.sprite_new(f32(x * 8 + 3), f32(y * 8 + 2))
	flx.sprite_make_graphic(coin, 2, 4, flx.YELLOW)
	flx.group_add(ps.coins, coin)
}

// Update callback
play_state_update :: proc(state: ^flx.State, dt: f32) {
	ps := cast(^Play_State)state

	// Update input
	flx.global_update_input()

	// Player movement and controls
	ps.player.acceleration.x = 0
	if flx.g.keys.LEFT {
		ps.player.acceleration.x = -ps.player.max_velocity.x * 4
	}
	if flx.g.keys.RIGHT {
		ps.player.acceleration.x = ps.player.max_velocity.x * 4
	}
	if flx.keys_just_pressed("SPACE") && flx.sprite_is_touching(ps.player, flx.COLLISION_FLOOR) {
		ps.player.velocity.y = -ps.player.max_velocity.y / 2
	}

	// Update all objects
	flx.state_update(&ps.base, dt)

	// Check for coin collection
	flx.overlap(ps.coins, ps.player, get_coin)

	// Check for exit collision
	flx.overlap(ps.exit, ps.player, win)

	// Collide player with level
	flx.collide(ps.level, ps.player)

	// Check lose condition
	if ps.player.y > f32(flx.get_height()) {
		flx.g.score = 1
		flx.reset_state()
	}

	// Check for ESC to quit
	if flx.key_pressed(.ESCAPE) {
		fmt.println("Quitting game...")
		flx.quit()
	}
}

// Coin collection callback
get_coin :: proc(coin: ^flx.Sprite, player: ^flx.Sprite) {
	// Need to access play state through global
	flx.sprite_kill(coin)
}

// Win callback
win :: proc(exit: ^flx.Sprite, player: ^flx.Sprite) {
	flx.sprite_kill(player)
}

// Draw callback
play_state_draw :: proc(state: ^flx.State) {
	ps := cast(^Play_State)state

	// Draw tilemap
	if ps.level.exists && ps.level.visible {
		flx.tilemap_draw(ps.level)
	}

	// Draw exit
	if ps.exit.exists && ps.exit.visible {
		flx.sprite_draw(ps.exit)
	}

	// Draw coins
	if ps.coins.exists && ps.coins.visible {
		flx.group_draw(ps.coins)
	}

	// Draw player
	if ps.player.exists && ps.player.visible {
		flx.sprite_draw(ps.player)
	}

	// Draw UI
	if ps.score.exists && ps.score.visible {
		flx.text_draw(ps.score)
	}
	if ps.status.exists && ps.status.visible {
		flx.text_draw(ps.status)
	}

	// Update score text
	dead_coins := flx.group_count_dead(ps.coins)
	score_str := fmt.tprintf("SCORE: %d", dead_coins * 100)
	flx.text_set_text(ps.score, score_str)

	// Update status based on coins
	if flx.group_count_living(ps.coins) == 0 && !ps.exit.exists {
		flx.text_set_text(ps.status, "Find the exit.")
		ps.exit.exists = true
		ps.exit.visible = true
	}

	// Check if player won
	if !ps.player.exists {
		flx.text_set_text(ps.status, "Yay, you won!")
		flx.text_set_text(ps.score, "SCORE: 5000")
	}
}
