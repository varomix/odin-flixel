package spaceshooter

import flx "../../flixel"
import "core:math"

Alien :: struct {
	using sprite: flx.Sprite,
}

alien_new :: proc(x, y: f32) -> ^Alien {
	alien := new(Alien)

	alien.sprite = flx.sprite_new(x, y)^
	flx.sprite_load_graphic(&alien.sprite, "assets/png/Alien.png")

	alien.velocity.x = -200

	// override update
	alien.sprite.vtable.update = alien_update

	return alien
}

alien_update :: proc(obj: ^flx.Object, dt: f32) {
	alien := cast(^Alien)obj

	alien.velocity.y = math.cos(alien.x / 50) * 50

	flx.sprite_update(obj, dt)

}
