package flixel

import "core:math"
import rl "vendor:raylib"

// Object is the base type for most game entities
Object :: struct {
	x:            f32,
	y:            f32,
	width:        f32,
	height:       f32,
	velocity:     rl.Vector2,
	acceleration: rl.Vector2,
	active:       bool,
	visible:      bool,
	exists:       bool,

	// Virtual table for polymorphism
	vtable:       ^Object_VTable,
}

Object_VTable :: struct {
	update:  proc(obj: ^Object, dt: f32),
	draw:    proc(obj: ^Object),
	destroy: proc(obj: ^Object),
}

// Default implementation for Object
object_update :: proc(obj: ^Object, dt: f32) {
	if !obj.active || !obj.exists {
		return
	}

	// Apply acceleration to velocity
	obj.velocity.x += obj.acceleration.x * dt
	obj.velocity.y += obj.acceleration.y * dt

	// Apply velocity to position
	obj.x += obj.velocity.x * dt
	obj.y += obj.velocity.y * dt
}

object_draw :: proc(obj: ^Object) {
	// Base object has no visual representation
}

object_destroy :: proc(obj: ^Object) {
	obj.exists = false
}

// Constructor
object_init :: proc(obj: ^Object, x: f32 = 0, y: f32 = 0, width: f32 = 0, height: f32 = 0) {
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height
	obj.velocity = {0, 0}
	obj.acceleration = {0, 0}
	obj.active = true
	obj.visible = true
	obj.exists = true
}
