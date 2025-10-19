package flixel

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

// Global game utilities and state
Global :: struct {
	score:    int,
	bg_color: Color,
	keys:     Keys,
}

// Global instance
g: Global

// Keys structure for input handling
Keys :: struct {
	LEFT:         bool,
	RIGHT:        bool,
	UP:           bool,
	DOWN:         bool,
	SPACE:        bool,
	just_pressed: map[string]bool,
	was_pressed:  map[string]bool,
}

// Initialize global state
global_init :: proc() {
	g.score = 0
	g.bg_color = BLACK
	g.keys.just_pressed = make(map[string]bool)
	g.keys.was_pressed = make(map[string]bool)
}

// Update input state
global_update_input :: proc() {
	// Update previous frame state
	clear(&g.keys.was_pressed)
	for key, val in g.keys.just_pressed {
		if val {
			g.keys.was_pressed[key] = true
		}
	}
	clear(&g.keys.just_pressed)

	// Update current frame state
	g.keys.LEFT = rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A)
	g.keys.RIGHT = rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D)
	g.keys.UP = rl.IsKeyDown(.UP) || rl.IsKeyDown(.W)
	g.keys.DOWN = rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S)
	g.keys.SPACE = rl.IsKeyDown(.SPACE)

	// Just pressed detection
	if rl.IsKeyPressed(.SPACE) && !g.keys.was_pressed["SPACE"] {
		g.keys.just_pressed["SPACE"] = true
	}
	if rl.IsKeyPressed(.UP) && !g.keys.was_pressed["UP"] {
		g.keys.just_pressed["UP"] = true
	}
	if rl.IsKeyPressed(.W) && !g.keys.was_pressed["W"] {
		g.keys.just_pressed["W"] = true
	}
}

// Check if key was just pressed this frame
keys_just_pressed :: proc(key: string) -> bool {
	val, ok := g.keys.just_pressed[key]
	return ok && val
}

// Key enum for common keys (abstracts raylib dependency)
Key :: enum {
	ESCAPE,
	SPACE,
	ENTER,
	UP,
	DOWN,
	LEFT,
	RIGHT,
	W,
	A,
	S,
	D,
}

// Check if a key is currently pressed
key_pressed :: proc(key: Key) -> bool {
	switch key {
	case .ESCAPE:
		return rl.IsKeyPressed(.ESCAPE)
	case .SPACE:
		return rl.IsKeyPressed(.SPACE)
	case .ENTER:
		return rl.IsKeyPressed(.ENTER)
	case .UP:
		return rl.IsKeyPressed(.UP)
	case .DOWN:
		return rl.IsKeyPressed(.DOWN)
	case .LEFT:
		return rl.IsKeyPressed(.LEFT)
	case .RIGHT:
		return rl.IsKeyPressed(.RIGHT)
	case .W:
		return rl.IsKeyPressed(.W)
	case .A:
		return rl.IsKeyPressed(.A)
	case .S:
		return rl.IsKeyPressed(.S)
	case .D:
		return rl.IsKeyPressed(.D)
	}
	return false
}

// Overlap detection between group and sprite
overlap_group_sprite :: proc(
	group: ^Group,
	sprite: ^Sprite,
	callback: proc(_: ^Sprite, _: ^Sprite),
) {
	if !group.exists || !sprite.exists {
		return
	}

	for member in group.members {
		if member.exists && sprites_overlap(member, sprite) {
			if callback != nil {
				callback(member, sprite)
			}
		}
	}
}

// Overlap detection between sprite and group (reverse order for callback)
overlap_sprite_group :: proc(
	sprite: ^Sprite,
	group: ^Group,
	callback: proc(_: ^Sprite, _: ^Sprite),
) {
	overlap_group_sprite(group, sprite, callback)
}

// Overlap detection between two sprites
overlap_sprites :: proc(
	sprite1: ^Sprite,
	sprite2: ^Sprite,
	callback: proc(_: ^Sprite, _: ^Sprite),
) -> bool {
	if sprites_overlap(sprite1, sprite2) {
		if callback != nil {
			callback(sprite1, sprite2)
		}
		return true
	}
	return false
}

// Overlap detection between two groups
overlap_group_group :: proc(
	group1: ^Group,
	group2: ^Group,
	callback: proc(_: ^Sprite, _: ^Sprite),
) {
	if !group1.exists || !group2.exists {
		return
	}

	for member1 in group1.members {
		if !member1.exists do continue

		for member2 in group2.members {
			if member2.exists && sprites_overlap(member1, member2) {
				if callback != nil {
					callback(member1, member2)
				}
			}
		}
	}
}

// Generic overlap - handles different object types
overlap :: proc {
	overlap_group_sprite,
	overlap_sprite_group,
	overlap_sprites,
	overlap_group_group,
}

// Automatic separation function for collision resolution
separate_sprites :: proc(sprite1: ^Sprite, sprite2: ^Sprite) -> bool {
	if !sprite1.exists || !sprite2.exists {
		return false
	}

	// Calculate overlap
	overlap_x :=
		min(sprite1.x + sprite1.width, sprite2.x + sprite2.width) - max(sprite1.x, sprite2.x)
	overlap_y :=
		min(sprite1.y + sprite1.height, sprite2.y + sprite2.height) - max(sprite1.y, sprite2.y)

	if overlap_x > 0 && overlap_y > 0 {
		// Resolve on the axis with least overlap
		if overlap_x < overlap_y {
			// Resolve horizontally
			if sprite1.x < sprite2.x {
				// sprite1 is to the left
				sprite1.x = sprite2.x - sprite1.width
			} else {
				// sprite1 is to the right
				sprite1.x = sprite2.x + sprite2.width
			}
			sprite1.velocity.x = 0
		} else {
			// Resolve vertically
			if sprite1.y < sprite2.y {
				// sprite1 is above
				sprite1.y = sprite2.y - sprite1.height
			} else {
				// sprite1 is below
				sprite1.y = sprite2.y + sprite2.height
			}
			sprite1.velocity.y = 0
		}
		return true
	}

	return false
}

// Collide tilemap with sprite
collide_tilemap_sprite :: proc(tilemap: ^Tilemap, sprite: ^Sprite) -> bool {
	if !tilemap.exists || !sprite.exists {
		return false
	}

	if (tilemap.allow_collisions & sprite.allow_collisions) == 0 {
		return false
	}

	// Get sprite bounds in tile coordinates
	left := int((sprite.x - tilemap.x) / f32(tilemap.tile_width))
	right := int((sprite.x + sprite.width - tilemap.x) / f32(tilemap.tile_width))
	top := int((sprite.y - tilemap.y) / f32(tilemap.tile_height))
	bottom := int((sprite.y + sprite.height - tilemap.y) / f32(tilemap.tile_height))

	collided := false

	// Check all tiles in range
	for ty := top; ty <= bottom; ty += 1 {
		for tx := left; tx <= right; tx += 1 {
			if tilemap_is_solid(tilemap, tx, ty) {
				// Calculate tile bounds
				tile_x := tilemap.x + f32(tx * tilemap.tile_width)
				tile_y := tilemap.y + f32(ty * tilemap.tile_height)
				tile_w := f32(tilemap.tile_width)
				tile_h := f32(tilemap.tile_height)

				// Resolve collision
				resolve_collision_sprite_rect(sprite, tile_x, tile_y, tile_w, tile_h)
				collided = true
			}
		}
	}

	return collided
}

// Resolve collision between sprite and rectangle
resolve_collision_sprite_rect :: proc(
	sprite: ^Sprite,
	rect_x: f32,
	rect_y: f32,
	rect_w: f32,
	rect_h: f32,
) {
	// Calculate overlap on each axis
	overlap_x := min(sprite.x + sprite.width, rect_x + rect_w) - max(sprite.x, rect_x)
	overlap_y := min(sprite.y + sprite.height, rect_y + rect_h) - max(sprite.y, rect_y)

	if overlap_x > 0 && overlap_y > 0 {
		// Resolve on the axis with least overlap
		if overlap_x < overlap_y {
			// Resolve horizontally
			if sprite.x < rect_x {
				// Hit from left
				sprite.x = rect_x - sprite.width
				sprite.velocity.x = 0
				sprite.touching |= COLLISION_RIGHT
			} else {
				// Hit from right
				sprite.x = rect_x + rect_w
				sprite.velocity.x = 0
				sprite.touching |= COLLISION_LEFT
			}
		} else {
			// Resolve vertically
			if sprite.y < rect_y {
				// Hit from top
				sprite.y = rect_y - sprite.height
				sprite.velocity.y = 0
				sprite.touching |= COLLISION_DOWN
			} else {
				// Hit from bottom
				sprite.y = rect_y + rect_h
				sprite.velocity.y = 0
				sprite.touching |= COLLISION_UP
			}
		}
	}
}

// Generic collide function
collide :: proc {
	collide_tilemap_sprite,
}

// Reset the current state (reload)
reset_state :: proc() {
	if game != nil && game.state != nil {
		// Store the vtable pointer before destroying
		vtable := game.state.vtable

		// Destroy all members and free their memory
		for member in game.state.members {
			if member != nil {
				// Free the actual object memory
				free(member)
			}
		}
		delete(game.state.members)

		// Recreate the members array and reset state
		game.state.members = make([dynamic]^Object, 0, 16)
		game.state.active = true
		game.state.vtable = vtable // Restore vtable pointer

		// Call create to reinitialize
		if vtable != nil && vtable.create != nil {
			vtable.create(game.state)
		}
	}
}

// Get screen width
get_width :: proc() -> i32 {
	if game != nil {
		return game.width
	}
	return 800
}

// Get screen height
get_height :: proc() -> i32 {
	if game != nil {
		return game.height
	}
	return 600
}

// Get elapsed time (delta time)
get_elapsed :: proc() -> f32 {
	return rl.GetFrameTime()
}

// Get random float between 0 and 1
random :: proc() -> f32 {
	return rand.float32()
}

// Get random float between min and max
random_range :: proc(min: f32, max: f32) -> f32 {
	return min + rand.float32() * (max - min)
}

// Get random int between min and max (inclusive)
random_int :: proc(min: int, max: int) -> int {
	return min + int(rand.float32() * f32(max - min + 1))
}

// Shake the camera
shake :: proc(intensity: f32 = 0.05, duration: f32 = 0.5) {
	if game != nil && game.camera != nil {
		camera_shake(game.camera, intensity, duration)
	}
}
