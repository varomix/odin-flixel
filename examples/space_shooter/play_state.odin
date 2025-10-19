package spaceshooter

import flx "../../flixel"
import "core:fmt"
import "core:math/rand"

PlayState :: struct {
	using base:    flx.State,
	player:        ^Player,
	aliens:        ^flx.Group,
	bullets:       ^flx.Group,
	spawnTimer:    f32,
	spawnInterval: f32,
}

state: PlayState


// Create a new play state
play_state_new :: proc() -> ^PlayState {
	state := new(PlayState)
	flx.state_setup(&state.base, play_state_create, play_state_update)

	state.spawnInterval = 2.5
	return state
}

play_state_create :: proc(state: ^flx.State) {
	st := cast(^PlayState)state

	// create player
	st.player = player_ship()
	flx.state_add(&st.base, &st.player.sprite.base)

	st.aliens = flx.group_new()
	flx.state_add(&st.base, &st.aliens.base)

	st.bullets = flx.group_new()
	// for i := 0; i < 10; i += 1 {
	// 	bullet := bullet()
	// 	// bullet.exists = false
	// 	flx.group_add(st.bullets, &bullet.sprite)
	// }
	flx.state_add(&st.base, &st.bullets.base)

}

play_state_update :: proc(state: ^flx.State, dt: f32) {
	st := cast(^PlayState)state

	flx.global_update_input()

	flx.overlap(st.aliens, st.bullets, overlap_alien_bullet)

	if flx.keys_just_pressed("SPACE") && st.player.active == true {
		fmt.println("Shooting!!")
		// fmt.println("Bullets amount", st.bullets)
		spawn_bullet(st)
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
}

overlap_alien_player :: proc(alien: ^flx.Sprite, player: ^flx.Sprite) {
	flx.sprite_kill(player)
	flx.sprite_kill(alien)
	// flx.camera.shake(0.02)
}
