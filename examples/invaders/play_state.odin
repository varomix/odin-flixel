package main

import "core:fmt"
import flx "../../flixel"

// PlayState is the main game state for Flx Invaders
PlayState :: struct {
	using base:      flx.State,
	player:          ^PlayerShip,
	player_bullets:  ^flx.Group,
	aliens:          ^flx.Group,
	alien_bullets:   ^flx.Group,
	shields:         ^flx.Group,
	status_text:     ^flx.Text,
	game_over:       bool,
	game_message:    string,
}

// Create a new PlayState
play_state_new :: proc() -> ^PlayState {
	state := new(PlayState)
	flx.state_setup(&state.base, play_state_create, play_state_update, play_state_draw)
	state.game_over = false
	state.game_message = "WELCOME TO FLX INVADERS"
	return state
}

// Create - initialize all game objects
play_state_create :: proc(state: ^flx.State) {
	play := cast(^PlayState)state

	// Initialize input system
	flx.global_init()

	// Create player bullets (8 bullets to recycle)
	play.player_bullets = flx.group_new()
	for i := 0; i < 8; i += 1 {
		bullet := flx.sprite_new(-100, -100)
		flx.sprite_make_graphic(bullet, 2, 8, flx.WHITE)
		bullet.exists = false
		flx.group_add(play.player_bullets, bullet)
	}
	flx.state_add(&play.base, &play.player_bullets.base)

	// Create player ship
	play.player = player_ship_new(play.player_bullets)
	flx.state_add(&play.base, &play.player.sprite.base)

	// Create alien bullets (32 bullets to recycle)
	play.alien_bullets = flx.group_new()
	for i := 0; i < 32; i += 1 {
		bullet := flx.sprite_new(-100, -100)
		flx.sprite_make_graphic(bullet, 2, 8, flx.WHITE)
		bullet.exists = false
		flx.group_add(play.alien_bullets, bullet)
	}
	flx.state_add(&play.base, &play.alien_bullets.base)

	// Create aliens (5 rows of 10)
	play.aliens = flx.group_new()
	colors := []flx.Color{
		flx.BLUE,
		flx.Color{0, 128, 128, 255}, // BLUE | GREEN
		flx.GREEN,
		flx.Color{128, 128, 0, 255}, // GREEN | RED
		flx.RED,
	}
	for i := 0; i < 50; i += 1 {
		x := f32(8 + (i % 10) * 32)
		y := f32(24 + (i / 10) * 32)
		color := colors[i / 10]
		alien := alien_new(x, y, color, play.alien_bullets)
		flx.group_add(play.aliens, alien)
	}
	flx.state_add(&play.base, &play.aliens.base)

	// Create shields (4 shields, each made of 16 blocks)
	play.shields = flx.group_new()
	for i := 0; i < 64; i += 1 {
		x := f32(32 + 80 * (i / 16) + (i % 4) * 4)
		y := f32(flx.get_height()) - 32 + f32(((i % 16) / 4) * 4)
		shield := flx.sprite_new(x, y)
		flx.sprite_make_graphic(shield, 4, 4, flx.WHITE)
		shield.active = false
		flx.group_add(play.shields, shield)
	}
	flx.state_add(&play.base, &play.shields.base)

	// Create status text
	play.status_text = flx.text_new(
		4,
		4,
		f32(flx.get_width()) - 8,
		play.game_message,
		16,
		flx.WHITE,
	)
	flx.state_add(&play.base, &play.status_text.base)
}

// Update game logic
play_state_update :: proc(state: ^flx.State, dt: f32) {
	play := cast(^PlayState)state

	// Update input
	flx.global_update_input()

	if play.game_over {
		if flx.key_pressed(.SPACE) {
			flx.reset_state()
			play.game_over = false
		}
		return
	}

	// Check collisions - player bullets vs aliens and shields
	for bullet in play.player_bullets.members {
		if !bullet.exists do continue

		// Check vs aliens
		for alien in play.aliens.members {
			if alien.exists && flx.sprites_overlap(bullet, alien) {
				flx.sprite_kill(bullet)
				flx.sprite_kill(alien)
			}
		}

		// Check vs shields
		for shield in play.shields.members {
			if shield.exists && flx.sprites_overlap(bullet, shield) {
				flx.sprite_kill(bullet)
				flx.sprite_kill(shield)
			}
		}
	}

	// Check collisions - alien bullets vs player and shields
	for bullet in play.alien_bullets.members {
		if !bullet.exists do continue

		// Check vs player
		if play.player.exists && flx.sprites_overlap(bullet, &play.player.sprite) {
			flx.sprite_kill(bullet)
			flx.sprite_kill(&play.player.sprite)
		}

		// Check vs shields
		for shield in play.shields.members {
			if shield.exists && flx.sprites_overlap(bullet, shield) {
				flx.sprite_kill(bullet)
				flx.sprite_kill(shield)
			}
		}
	}

	// Update all objects
	flx.state_update(&play.base, dt)

	// Check win/lose conditions
	if !play.player.exists {
		play.game_message = "YOU LOST - SPACE TO RETRY"
		flx.text_set_text(play.status_text, play.game_message)
		play.game_over = true
	} else if flx.group_get_first_existing(play.aliens) == nil {
		play.game_message = "YOU WON - SPACE TO RETRY"
		flx.text_set_text(play.status_text, play.game_message)
		play.game_over = true
	}
}

// Draw game
play_state_draw :: proc(state: ^flx.State) {
	play := cast(^PlayState)state
	flx.state_draw(&play.base)
}
