package flixybird

import flx "../../flixel"
import "core:math"

Pipe :: struct {
	using sprite: flx.Sprite,
}

pipe_new :: proc(x, y: f32, rotation: f32) -> ^Pipe {
	pipe := new(Pipe)

	pipe.sprite = flx.sprite_new(x, y)^
	flx.sprite_load_graphic(&pipe.sprite, "sprites/pipe-green.png")

	pipe.velocity.x = -100

	return pipe

}
