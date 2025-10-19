package spaceshooter

import flx "../../flixel"

Player :: struct {
	using sprite: flx.Sprite,
}

player_ship :: proc() -> ^Player {
	player := new(Player)

	player.sprite = flx.sprite_new(50, 50)^
	flx.sprite_load_graphic(&player.sprite, "assets/png/Ship.png")

	// override update
	player.sprite.vtable.update = player_ship_update

	return player
}

player_ship_update :: proc(obj: ^flx.Object, dt: f32) {
	player := cast(^Player)obj

	player.velocity = {0, 0}

	if flx.g.keys.LEFT {
		player.velocity.x = -250
	} else if flx.g.keys.RIGHT {
		player.velocity.x = 250
	}

	if flx.g.keys.UP {
		player.velocity.y = -250
	} else if flx.g.keys.DOWN {
		player.velocity.y = 250
	}

	if player.x > f32(flx.get_width()) - player.sprite.width - 16 {
		player.x = f32(flx.get_width()) - player.sprite.width - 16
	} else if player.x < 16 {
		player.x = 16
	}

	if player.y > f32(flx.get_height()) - player.sprite.height - 16 {
		player.y = f32(flx.get_height()) - player.sprite.height - 16
	} else if player.y < 16 {
		player.y = 16
	}

	flx.sprite_update(obj, dt)

}
