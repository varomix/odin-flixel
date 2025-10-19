package spaceshooter

import flx "../../flixel"


Bullet :: struct {
	using sprite: flx.Sprite,
}

bullet_new :: proc(x, y: f32) -> ^Bullet {
	bullet := new(Bullet)
	bullet.sprite = flx.sprite_new(x, y)^

	flx.sprite_make_graphic(&bullet.sprite, 16, 4, flx.Color{89, 113, 55, 255})
	bullet.velocity.x = 1000
	bullet.exists = true

	return bullet
}
