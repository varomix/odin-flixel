package main

import flx "../../flixel"

// Alien is the enemy invader
Alien :: struct {
	using sprite: flx.Sprite,
	shot_clock:   f32,
	original_x:   f32,
	bullets:      ^flx.Group,
}

// Create a new alien
alien_new :: proc(x: f32, y: f32, color: flx.Color, bullets: ^flx.Group) -> ^Alien {
	alien := new(Alien)

	alien.sprite = flx.sprite_new(x, y)^
	// Load animated graphic - alien.png is 48x16 with 3 frames of 16x16 each
	flx.sprite_load_animated_graphic(&alien.sprite, "alien.png", 16, 16)
	alien.sprite.color = color

	alien.original_x = x
	alien.bullets = bullets
	alien.shot_clock = 1 + flx.random() * 10

	// Create animation - frames [0,1,0,2] at 6-10 FPS (randomized)
	frame_rate := 6 + flx.random() * 4
	frames := []i32{0, 1, 0, 2}
	flx.sprite_add_animation(&alien.sprite, "Default", frames, frame_rate, true)
	flx.sprite_play(&alien.sprite, "Default")

	// Start moving right
	alien.velocity.x = 10

	// Override update
	alien.sprite.vtable.update = alien_update

	return alien
}

// Update alien
alien_update :: proc(obj: ^flx.Object, dt: f32) {
	alien := cast(^Alien)obj

	if !alien.active || !alien.exists {
		return
	}

	// Move back and forth
	if alien.x < alien.original_x - 8 {
		alien.x = alien.original_x - 8
		alien.velocity.x = -alien.velocity.x
		alien.velocity.y = alien.velocity.y + 1
	}
	if alien.x > alien.original_x + 8 {
		alien.x = alien.original_x + 8
		alien.velocity.x = -alien.velocity.x
	}

	// Update physics
	flx.sprite_update(obj, dt)

	// Shooting logic
	if alien.y > f32(flx.get_height()) * 0.35 {
		alien.shot_clock -= dt
		if alien.shot_clock <= 0 {
			alien.shot_clock = 1 + flx.random() * 10
			bullet := flx.group_recycle(alien.bullets)
			if bullet != nil {
				flx.sprite_reset(bullet, alien.x + alien.width/2 - bullet.width/2, alien.y)
				bullet.velocity.y = 65
			}
		}
	}
}
