package spaceshooter

import flx "../../flixel"
import "core:math/rand"

PlayState :: struct {
	using base:    flx.State,
	player:        ^Player,
	aliens:        ^flx.Group,
	bullets:       ^flx.Group,
	spawnTimer:    f32,
	spawnInterval: f32,
}

// Package-level sounds (accessible by callbacks)
// This follows the original Flixel pattern where sounds are global
bullet_sound: ^flx.Sound
alien_expl_sound: ^flx.Sound
ship_expl_sound: ^flx.Sound


// Create a new play state
play_state_new :: proc() -> ^PlayState {
	// Use the convenience function - cleaner!
	st := flx.state_make(PlayState, play_state_create, play_state_update)
	st.spawnInterval = 2.5
	return st
}

play_state_create :: proc(state: ^flx.State) {
	st := cast(^PlayState)state

	// Load sounds (package-level, accessible by callbacks)
	bullet_sound = flx.sound_new()
	flx.sound_load(bullet_sound, "assets/mp3/Bullet.mp3")

	alien_expl_sound = flx.sound_new()
	flx.sound_load(alien_expl_sound, "assets/mp3/ExplosionAlien.mp3")

	ship_expl_sound = flx.sound_new()
	flx.sound_load(ship_expl_sound, "assets/mp3/ExplosionShip.mp3")

	// create player
	st.player = player_ship()
	flx.state_add(st, &st.player.sprite)

	st.aliens = flx.group_new()
	flx.state_add(st, st.aliens)

	st.bullets = flx.group_new()
	flx.state_add(st, st.bullets)

}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	st := cast(^PlayState)state

	flx.global_update_input()

	flx.overlap(st.aliens, st.bullets, overlap_alien_bullet)
	flx.overlap(st.aliens, st.player, overlap_alien_player)

	if flx.keys_just_pressed("SPACE") && st.player.active == true {
		spawn_bullet(st)
		// Play bullet sound
		flx.sound_play(bullet_sound, true)
	}

	st.spawnTimer -= flx.get_elapsed()

	if st.spawnTimer < 0 {
		spawn_aliens(st, dt)
		reset_spawn_timer(st)
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

	// fmt.println("")
}

overlap_alien_bullet :: proc(alien: ^flx.Sprite, bullet: ^flx.Sprite) {
	flx.sprite_kill(alien)
	flx.sprite_kill(bullet)
	// Play alien explosion sound
	flx.sound_play(alien_expl_sound, true)
}

overlap_alien_player :: proc(alien: ^flx.Sprite, player: ^flx.Sprite) {
	flx.sprite_kill(player)
	flx.sprite_kill(alien)
	flx.shake(0.05)
	// Play ship explosion sound
	flx.sound_play(ship_expl_sound, true)
}
