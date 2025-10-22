package spaceshooter

import flx "../../flixel"
import "core:fmt"
import "core:math/rand"

PlayState :: struct {
	using base:     flx.State,
	player:         ^Player,
	aliens:         ^flx.Group,
	bullets:        ^flx.Group,
	score_txt:      ^flx.Text,
	spawnTimer:     f32,
	spawnInterval:  f32,
	game_over_text: ^flx.Text,
}

// Package-level sounds and emitter (accessible by callbacks)
bullet_sound: ^flx.Sound
alien_expl_sound: ^flx.Sound
ship_expl_sound: ^flx.Sound
explosion_emitter: ^flx.Emitter

// Create a new play state
play_state_new :: proc() -> ^PlayState {
	// Use the convenience function - cleaner!
	st := flx.state_make(PlayState, play_state_create, play_state_update)
	st.spawnInterval = 2.5
	return st
}

play_state_create :: proc(state: ^flx.State) {
	st := cast(^PlayState)state

	// Reset global score
	flx.g.score = 0

	// Load sounds
	bullet_sound = flx.sound_new()
	flx.sound_load(bullet_sound, "assets/mp3/Bullet.mp3")
	alien_expl_sound = flx.sound_new()
	flx.sound_load(alien_expl_sound, "assets/mp3/ExplosionAlien.mp3")
	ship_expl_sound = flx.sound_new()
	flx.sound_load(ship_expl_sound, "assets/mp3/ExplosionShip.mp3")

	// Create and add the explosion emitter
	explosion_emitter = create_explosion_emitter()
	flx.state_add(st, explosion_emitter)

	// create player
	st.player = player_ship()
	flx.state_add(st, &st.player.sprite)

	st.aliens = flx.group_new()
	flx.state_add(st, st.aliens)

	st.bullets = flx.group_new()
	flx.state_add(st, st.bullets)

	st.score_txt = flx.text_new(10, 8, 0, "SCORE: 0")
	flx.text_set_color(st.score_txt, flx.make_color(0x597137))
	flx.text_set_alignment(st.score_txt, .LEFT)
	flx.state_add(st, st.score_txt)

	// Create game over text (initially hidden)
	st.game_over_text = flx.text_new(
		0,
		f32(flx.get_height() / 2.0),
		f32(flx.get_width()),
		"GAME OVER - PRESS ENTER TO PLAY AGAIN",
	)
	flx.text_set_alignment(st.game_over_text, .CENTER)
	st.game_over_text.visible = false
	flx.state_add(st, st.game_over_text)

}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	st := cast(^PlayState)state

	flx.global_update_input()

	flx.overlap(st.aliens, st.bullets, overlap_alien_bullet)
	flx.overlap(st.aliens, st.player, overlap_alien_player)

	if flx.key_pressed(.SPACE) && st.player.active == true {
		spawn_bullet(st)
		// Play bullet sound
		flx.sound_play(bullet_sound, true)
	}

	st.spawnTimer -= flx.get_elapsed()

	if st.spawnTimer < 0 {
		spawn_aliens(st, dt)
		reset_spawn_timer(st)
	}

	// Update score display
	flx.text_set_text(st.score_txt, fmt.tprintf("SCORE: %d", flx.g.score))

	// Toggle game over text visibility
	st.game_over_text.visible = !st.player.active

	if st.player.active == false && flx.key_pressed(.ENTER) {
		flx.switch_state(flx.game, play_state_new())
	}


	flx.state_update(&st.base, dt)
}

spawn_aliens :: proc(st: ^PlayState, dt: f32) {

	x := cast(f32)flx.get_width()
	y := cast(f32)rand.float32_range(0, f32(flx.get_height() - 50))

	alien := alien_new(x, y)
	flx.group_add(st.aliens, &alien.sprite)
}

reset_spawn_timer :: proc(st: ^PlayState) {
	st.spawnTimer = st.spawnInterval
	st.spawnInterval *= 0.95
	if st.spawnInterval < 0.1 {
		st.spawnInterval = 0.1
	}
}

spawn_bullet :: proc(st: ^PlayState) {
	x := st.player.sprite.x + st.player.sprite.width / 2
	y := st.player.sprite.y + 12

	bullet := bullet_new(x, y)
	flx.group_add(st.bullets, &bullet.sprite)
}

create_explosion_emitter :: proc() -> ^flx.Emitter {
	emitter := flx.emitter_new()
	emitter.gravity = 0
	emitter.lifespan = 0.5 // Particles live for 0.5 seconds
	flx.emitter_set_x_speed(emitter, -150, 150)
	flx.emitter_set_y_speed(emitter, -150, 150)

	// Configure particle properties
	emitter.particle_count = 20
	emitter.particle_color = flx.make_color(0x597137FF)
	flx.emitter_init(emitter)

	return emitter
}

overlap_alien_bullet :: proc(alien: ^flx.Sprite, bullet: ^flx.Sprite) {
	flx.emitter_set_center(explosion_emitter, flx.sprite_get_center(alien))
	flx.emitter_start(explosion_emitter)

	flx.sprite_kill(alien)
	flx.sprite_kill(bullet)
	flx.sound_play(alien_expl_sound, true)
	flx.g.score += 10
}

overlap_alien_player :: proc(alien: ^flx.Sprite, player: ^flx.Sprite) {
	// Position and start the emitter for the player
	flx.emitter_set_center(explosion_emitter, flx.sprite_get_center(player))
	flx.emitter_start(explosion_emitter)

	flx.sprite_kill(player)
	flx.sprite_kill(alien)
	flx.shake(0.05)
	flx.sound_play(ship_expl_sound, true)

	player.active = false
}
