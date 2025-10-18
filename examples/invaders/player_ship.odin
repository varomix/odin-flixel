package main

import flx "../../flixel"

// PlayerShip is the player-controlled ship at the bottom
PlayerShip :: struct {
	using sprite: flx.Sprite,
	bullets:      ^flx.Group,
}

// Create a new player ship
player_ship_new :: proc(bullets: ^flx.Group) -> ^PlayerShip {
	ship := new(PlayerShip)

	// Initialize sprite at bottom center of screen
	x := f32(flx.get_width()) / 2 - 6
	y := f32(flx.get_height()) - 12

	ship.sprite = flx.sprite_new(x, y)^
	flx.sprite_load_graphic(&ship.sprite, "ship.png")
	ship.sprite.color = flx.WHITE

	ship.bullets = bullets

	// Override update
	ship.sprite.vtable.update = player_ship_update

	return ship
}

// Update player ship
player_ship_update :: proc(obj: ^flx.Object, dt: f32) {
	ship := cast(^PlayerShip)obj

	if !ship.active || !ship.exists {
		return
	}

	// Controls
	ship.velocity.x = 0
	if flx.g.keys.LEFT {
		ship.velocity.x = -150
	}
	if flx.g.keys.RIGHT {
		ship.velocity.x = 150
	}

	// Update physics
	flx.sprite_update(obj, dt)

	// Clamp to screen bounds
	if ship.x > f32(flx.get_width()) - ship.width - 4 {
		ship.x = f32(flx.get_width()) - ship.width - 4
	}
	if ship.x < 4 {
		ship.x = 4
	}

	// Shooting
	if flx.keys_just_pressed("SPACE") {
		bullet := flx.group_recycle(ship.bullets)
		if bullet != nil {
			flx.sprite_reset(bullet, ship.x + ship.width/2 - bullet.width/2, ship.y)
			bullet.velocity.y = -140
		}
	}
}
