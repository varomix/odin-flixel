package flixel

import "core:fmt"
import rl "vendor:raylib"

// Global texture cache
texture_cache: map[string]rl.Texture2D

// Animation frame data
AnimationFrame :: struct {
	frame_index: i32,
	duration:    f32,
}

// Animation data
Animation :: struct {
	name:       string,
	frames:     [dynamic]AnimationFrame,
	frame_rate: f32,
	loop:       bool,
}

// Sprite is a visual game object that can be drawn and collided with
Sprite :: struct {
	using base:        Object,

	// Graphics
	texture:           rl.Texture2D,
	has_texture:       bool,
	color:             Color,

	// Animation
	animations:        map[string]^Animation,
	current_animation: ^Animation,
	current_frame:     i32,
	frame_timer:       f32,
	frame_width:       f32,
	frame_height:      f32,
	frames_per_row:    i32,
	playing:           bool,

	// Physics
	max_velocity:      Vec2,
	drag:              Vec2,

	// Collision flags
	touching:          u32,
	was_touching:      u32,
	allow_collisions:  u32,
}

// Collision direction flags
COLLISION_NONE :: 0x0000
COLLISION_LEFT :: 0x0001
COLLISION_RIGHT :: 0x0002
COLLISION_UP :: 0x0004
COLLISION_DOWN :: 0x0008
COLLISION_CEILING :: COLLISION_UP
COLLISION_FLOOR :: COLLISION_DOWN
COLLISION_WALL :: COLLISION_LEFT | COLLISION_RIGHT
COLLISION_ANY :: 0xFFFF

// Create a new sprite
sprite_new :: proc(x: f32 = 0, y: f32 = 0) -> ^Sprite {
	sprite := new(Sprite)
	object_init(&sprite.base, x, y, 0, 0)

	sprite.has_texture = false
	sprite.color = WHITE
	sprite.max_velocity = {10000, 10000}
	sprite.drag = {0, 0}
	sprite.touching = COLLISION_NONE
	sprite.was_touching = COLLISION_NONE
	sprite.allow_collisions = COLLISION_ANY

	// Initialize animation fields
	sprite.animations = make(map[string]^Animation)
	sprite.current_animation = nil
	sprite.current_frame = 0
	sprite.frame_timer = 0
	sprite.frame_width = 0
	sprite.frame_height = 0
	sprite.frames_per_row = 0
	sprite.playing = false

	// Override vtable for sprite
	sprite.vtable.update = sprite_update
	sprite.vtable.draw = sprite_draw
	sprite.vtable.destroy = sprite_destroy

	return sprite
}

// Make a solid color graphic for the sprite
sprite_make_graphic :: proc(sprite: ^Sprite, width: i32, height: i32, color: Color) {
	sprite.width = f32(width)
	sprite.height = f32(height)
	sprite.color = color
	sprite.has_texture = false
}

// Load a graphic from a file
sprite_load_graphic :: proc(sprite: ^Sprite, path: string) -> bool {
	// Check cache first
	cached_texture, exists := texture_cache[path]
	if exists {
		sprite.texture = cached_texture
		sprite.has_texture = true
		sprite.width = f32(sprite.texture.width)
		sprite.height = f32(sprite.texture.height)
		return true
	}

	// Load new texture
	sprite.texture = rl.LoadTexture(cstring(raw_data(path)))
	if sprite.texture.id == 0 {
		fmt.println("Warning: Failed to load texture:", path)
		return false
	}

	// Cache it
	texture_cache[path] = sprite.texture

	sprite.has_texture = true
	sprite.width = f32(sprite.texture.width)
	sprite.height = f32(sprite.texture.height)
	return true
}

// Load an animated graphic from a file with frame dimensions
sprite_load_animated_graphic :: proc(
	sprite: ^Sprite,
	path: string,
	frame_width: i32,
	frame_height: i32,
) -> bool {
	if !sprite_load_graphic(sprite, path) {
		return false
	}

	// Set up animation frame dimensions
	sprite.frame_width = f32(frame_width)
	sprite.frame_height = f32(frame_height)
	sprite.frames_per_row = i32(sprite.texture.width) / frame_width

	// Update sprite dimensions to match frame size
	sprite.width = sprite.frame_width
	sprite.height = sprite.frame_height

	return true
}

// Add an animation to the sprite
sprite_add_animation :: proc(
	sprite: ^Sprite,
	name: string,
	frames: []i32,
	frame_rate: f32,
	loop: bool = true,
) {
	animation := new(Animation)
	animation.name = name
	animation.frame_rate = frame_rate
	animation.loop = loop
	animation.frames = make([dynamic]AnimationFrame, 0, len(frames))

	// Create frames with equal duration
	frame_duration := 1.0 / frame_rate
	for frame_index in frames {
		frame := AnimationFrame{frame_index, frame_duration}
		append(&animation.frames, frame)
	}

	sprite.animations[name] = animation
}

// Play an animation by name
sprite_play :: proc(sprite: ^Sprite, name: string) {
	if animation, exists := sprite.animations[name]; exists {
		sprite.current_animation = animation
		sprite.current_frame = 0
		sprite.frame_timer = 0
		sprite.playing = true
	}
}

// Stop the current animation
sprite_stop :: proc(sprite: ^Sprite) {
	sprite.playing = false
}

// Update sprite physics
sprite_update :: proc(obj: ^Object, dt: f32) {
	sprite := cast(^Sprite)obj
	if !sprite.active || !sprite.exists {
		return
	}

	// Update animation
	if sprite.playing && sprite.current_animation != nil {
		sprite.frame_timer += dt
		if sprite.frame_timer >= sprite.current_animation.frames[sprite.current_frame].duration {
			sprite.frame_timer = 0
			sprite.current_frame += 1

			if sprite.current_frame >= i32(len(sprite.current_animation.frames)) {
				if sprite.current_animation.loop {
					sprite.current_frame = 0
				} else {
					sprite.current_frame = i32(len(sprite.current_animation.frames)) - 1
					sprite.playing = false
				}
			}
		}
	}

	// Store previous touching state
	sprite.was_touching = sprite.touching
	sprite.touching = COLLISION_NONE

	// Apply acceleration to velocity
	sprite.velocity.x += sprite.acceleration.x * dt
	sprite.velocity.y += sprite.acceleration.y * dt

	// Apply drag
	if sprite.acceleration.x == 0 && sprite.drag.x != 0 {
		drag_force := sprite.drag.x * dt
		if sprite.velocity.x > 0 {
			sprite.velocity.x -= drag_force
			if sprite.velocity.x < 0 {
				sprite.velocity.x = 0
			}
		} else if sprite.velocity.x < 0 {
			sprite.velocity.x += drag_force
			if sprite.velocity.x > 0 {
				sprite.velocity.x = 0
			}
		}
	}

	if sprite.acceleration.y == 0 && sprite.drag.y != 0 {
		drag_force := sprite.drag.y * dt
		if sprite.velocity.y > 0 {
			sprite.velocity.y -= drag_force
			if sprite.velocity.y < 0 {
				sprite.velocity.y = 0
			}
		} else if sprite.velocity.y < 0 {
			sprite.velocity.y += drag_force
			if sprite.velocity.y > 0 {
				sprite.velocity.y = 0
			}
		}
	}

	// Clamp to max velocity
	if sprite.velocity.x > sprite.max_velocity.x {
		sprite.velocity.x = sprite.max_velocity.x
	} else if sprite.velocity.x < -sprite.max_velocity.x {
		sprite.velocity.x = -sprite.max_velocity.x
	}

	if sprite.velocity.y > sprite.max_velocity.y {
		sprite.velocity.y = sprite.max_velocity.y
	} else if sprite.velocity.y < -sprite.max_velocity.y {
		sprite.velocity.y = -sprite.max_velocity.y
	}

	// Apply velocity to position
	sprite.x += sprite.velocity.x * dt
	sprite.y += sprite.velocity.y * dt
}

// Draw the sprite
sprite_draw :: proc(obj: ^Object) {
	sprite := cast(^Sprite)obj
	if !sprite.visible || !sprite.exists {
		return
	}

	if sprite.has_texture {
		if sprite.current_animation != nil && sprite.frame_width > 0 && sprite.frame_height > 0 {
			// Draw animated sprite with frame clipping
			frame_index := sprite.current_animation.frames[sprite.current_frame].frame_index
			frame_x := f32(frame_index % sprite.frames_per_row) * sprite.frame_width
			frame_y := f32(frame_index / sprite.frames_per_row) * sprite.frame_height

			source_rect := rl.Rectangle{frame_x, frame_y, sprite.frame_width, sprite.frame_height}
			dest_rect := rl.Rectangle{sprite.x, sprite.y, sprite.frame_width, sprite.frame_height}

			if sprite.color.r == 255 && sprite.color.g == 255 && sprite.color.b == 255 {
				rl.DrawTexturePro(sprite.texture, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
			} else {
				rl.DrawTexturePro(sprite.texture, source_rect, dest_rect, {0, 0}, 0, sprite.color)
			}
		} else {
			// Draw static sprite
			if sprite.color.r == 255 && sprite.color.g == 255 && sprite.color.b == 255 {
				rl.DrawTexture(sprite.texture, i32(sprite.x), i32(sprite.y), rl.WHITE)
			} else {
				rl.DrawTexture(sprite.texture, i32(sprite.x), i32(sprite.y), sprite.color)
			}
		}
	} else {
		// Draw solid color rectangle
		rl.DrawRectangle(
			i32(sprite.x),
			i32(sprite.y),
			i32(sprite.width),
			i32(sprite.height),
			sprite.color,
		)
	}
}

// Destroy sprite
sprite_destroy :: proc(obj: ^Object) {
	sprite := cast(^Sprite)obj

	// Clean up animation data
	for name, animation in sprite.animations {
		delete(animation.frames)
		free(animation)
	}
	delete(sprite.animations)

	// Don't unload texture - it's cached globally
	sprite.exists = false
	free(sprite)
}

// Kill sprite (disable it but don't free memory)
sprite_kill :: proc(sprite: ^Sprite) {
	sprite.exists = false
	sprite.active = false
	sprite.visible = false
}

// Revive sprite
sprite_revive :: proc(sprite: ^Sprite) {
	sprite.exists = true
	sprite.active = true
	sprite.visible = true
}

// Reset sprite to a new position and revive it
sprite_reset :: proc(sprite: ^Sprite, x: f32, y: f32) {
	sprite.x = x
	sprite.y = y
	sprite.velocity = {0, 0}
	sprite.acceleration = {0, 0}
	sprite_revive(sprite)
}

// Check if sprite is touching a direction
sprite_is_touching :: proc(sprite: ^Sprite, direction: u32) -> bool {
	return (sprite.touching & direction) > 0
}

// Get sprite bounds as rectangle
sprite_get_rect :: proc(sprite: ^Sprite) -> rl.Rectangle {
	return rl.Rectangle{sprite.x, sprite.y, sprite.width, sprite.height}
}

// Check if two sprites overlap
sprites_overlap :: proc(sprite1: ^Sprite, sprite2: ^Sprite) -> bool {
	if !sprite1.exists || !sprite2.exists {
		return false
	}

	rect1 := sprite_get_rect(sprite1)
	rect2 := sprite_get_rect(sprite2)

	return rl.CheckCollisionRecs(rect1, rect2)
}

// Get sprite position as a vector
sprite_get_position :: proc(sprite: ^Sprite) -> Vec2 {
	return Vec2{sprite.x, sprite.y}
}

// Set sprite position from a vector
sprite_set_position :: proc(sprite: ^Sprite, pos: Vec2) {
	sprite.x = pos.x
	sprite.y = pos.y
}

// Get sprite center position
sprite_get_center :: proc(sprite: ^Sprite) -> Vec2 {
	return Vec2{sprite.x + sprite.width / 2, sprite.y + sprite.height / 2}
}

// Set sprite position by its center
sprite_set_center :: proc(sprite: ^Sprite, center: Vec2) {
	sprite.x = center.x - sprite.width / 2
	sprite.y = center.y - sprite.height / 2
}
