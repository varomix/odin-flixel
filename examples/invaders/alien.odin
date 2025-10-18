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
	flx.sprite_load_graphic(&alien.sprite, "alien.png")
	alien.sprite.color = color

	alien.original_x = x
	alien.bullets = bullets
	alien.shot_clock = 1 + flx.random() * 10

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
