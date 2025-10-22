package flixel

import rl "vendor:raylib"

// Particle extends Sprite with particle-specific behavior
Particle :: struct {
	using sprite: Sprite,
	lifespan:     f32,
	elasticity:   f32,
}

// Emitter is a particle emitter that extends the Group functionality
Emitter :: struct {
	using base:       Object,
	members:          [dynamic]^Particle,

	// Emitter properties
	lifespan:         f32,
	gravity:          f32,
	min_speed_x:      f32,
	max_speed_x:      f32,
	min_speed_y:      f32,
	max_speed_y:      f32,
	min_rotation:     f32,
	max_rotation:     f32,

	// Particle properties
	particle_drag:    Vec2,
	bounce:           f32,

	// Particle creation settings
	particle_count:   int,
	particle_width:   i32,
	particle_height:  i32,
	particle_color:   Color,

	// Emission control
	on:               bool,
	frequency:        f32,
	explode:          bool,

	// Internal state
	timer:            f32,
	quantity:         int,
	counter:          int,
}

// Create a new particle
particle_new :: proc(x: f32 = 0, y: f32 = 0) -> ^Particle {
	particle := new(Particle)
	sprite_ptr := cast(^Sprite)particle
	sprite_ptr^ = sprite_new(x, y)^

	particle.lifespan = 0
	particle.elasticity = 0

	return particle
}

// Convenience function to make a graphic for a particle
particle_make_graphic :: proc(particle: ^Particle, width: i32, height: i32, color: Color) {
	sprite_make_graphic(cast(^Sprite)particle, width, height, color)
}

// Create a new emitter
emitter_new :: proc(x: f32 = 0, y: f32 = 0) -> ^Emitter {
	emitter := new(Emitter)

	// Initialize object base
	object_init(&emitter.base, x, y, 0, 0)
	emitter.members = make([dynamic]^Particle, 0, 32)

	// Position and size
	emitter.width = 0
	emitter.height = 0

	// Initialize emitter properties
	emitter.lifespan = 3.0
	emitter.gravity = 0
	emitter.min_speed_x = -100
	emitter.max_speed_x = 100
	emitter.min_speed_y = -100
	emitter.max_speed_y = 100
	emitter.min_rotation = -360
	emitter.max_rotation = 360

	// Particle properties
	emitter.particle_drag = {0, 0}
	emitter.bounce = 0

	// Emission control
	emitter.on = false
	emitter.frequency = 0.1
	emitter.explode = true

	// Internal state
	emitter.timer = 0
	emitter.quantity = 0
	emitter.counter = 0

	// Particle creation defaults
	emitter.particle_count = 50
	emitter.particle_width = 2
	emitter.particle_height = 2
	emitter.particle_color = WHITE

	// Override vtable for emitter
	emitter.base.vtable.update = emitter_update
	emitter.base.vtable.draw = emitter_draw

	return emitter
}

// Initialize the emitter's particle pool based on its configuration
// Call this after setting particle_count, particle_width, particle_height, particle_color
emitter_init :: proc(emitter: ^Emitter) {
	// Clear existing particles if any
	for particle in emitter.members {
		sprite_destroy(&particle.base)
	}
	clear(&emitter.members)

	// Create new particles based on configuration
	for i in 0 ..< emitter.particle_count {
		particle := particle_new()
		particle_make_graphic(particle, emitter.particle_width, emitter.particle_height, emitter.particle_color)
		emitter_add_particle(emitter, particle)
	}
}

// Add a particle to the emitter's pool (internal)
_emitter_add_particle_sprite :: proc(emitter: ^Emitter, sprite: ^Sprite) {
	// Convert sprite to particle
	particle := cast(^Particle)sprite
	particle.lifespan = 0
	particle.elasticity = 0
	sprite.exists = false
	append(&emitter.members, particle)
}

// Add a particle to the emitter's pool (convenience)
_emitter_add_particle_particle :: proc(emitter: ^Emitter, particle: ^Particle) {
	particle.lifespan = 0
	particle.elasticity = 0
	particle.exists = false
	append(&emitter.members, particle)
}

// Overloaded add particle procedure
emitter_add_particle :: proc {
	_emitter_add_particle_sprite,
	_emitter_add_particle_particle,
}

// Create and add particles to the emitter pool
// This is a convenience function that generates a pool of particles
emitter_make_particles :: proc(
	emitter: ^Emitter,
	width: i32,
	height: i32,
	color: Color,
	quantity: int = 50,
) {
	for i in 0 ..< quantity {
		particle := particle_new()
		particle_make_graphic(particle, width, height, color)
		emitter_add_particle(emitter, particle)
	}
}

// Get the first available (dead) particle from the pool
emitter_get_first_available :: proc(emitter: ^Emitter) -> ^Sprite {
	for particle in emitter.members {
		if !particle.exists {
			return cast(^Sprite)particle
		}
	}
	return nil
}

// Start the emitter
// explode: if true, emit all particles at once (burst). If false, emit continuously
// lifespan_override: override the default lifespan (0 = use default)
// frequency_override: override the default frequency (0 = use default)
// quantity_override: how many particles to emit (0 = all of them)
emitter_start :: proc(
	emitter: ^Emitter,
	explode: bool = true,
	lifespan_override: f32 = 0,
	frequency_override: f32 = 0,
	quantity_override: int = 0,
) {
	emitter.on = true
	emitter.explode = explode

	if lifespan_override > 0 {
		emitter.lifespan = lifespan_override
	}

	if frequency_override > 0 {
		emitter.frequency = frequency_override
	}

	emitter.quantity = quantity_override
	emitter.counter = 0
	emitter.timer = 0
}

// Stop the emitter
emitter_stop :: proc(emitter: ^Emitter) {
	emitter.on = false
}

// Emit a single particle
emitter_emit_particle :: proc(emitter: ^Emitter) {
	particle_sprite := emitter_get_first_available(emitter)
	if particle_sprite == nil {
		return
	}

	particle := cast(^Particle)particle_sprite

	// Set particle lifespan and elasticity
	particle.lifespan = emitter.lifespan
	particle.elasticity = emitter.bounce

	// Random position within emitter bounds
	spawn_x := emitter.x + random_range(0, emitter.width)
	spawn_y := emitter.y + random_range(0, emitter.height)
	sprite_reset(particle_sprite, spawn_x, spawn_y)

	// Set random velocity
	if emitter.min_speed_x != emitter.max_speed_x {
		particle_sprite.velocity.x = random_range(emitter.min_speed_x, emitter.max_speed_x)
	} else {
		particle_sprite.velocity.x = emitter.min_speed_x
	}

	if emitter.min_speed_y != emitter.max_speed_y {
		particle_sprite.velocity.y = random_range(emitter.min_speed_y, emitter.max_speed_y)
	} else {
		particle_sprite.velocity.y = emitter.min_speed_y
	}

	// Set gravity
	particle_sprite.acceleration.y = emitter.gravity

	// Set drag
	particle_sprite.drag = emitter.particle_drag

	// Set angular velocity (if needed)
	// Note: angular velocity/rotation not yet implemented in base sprite
	// but kept for future compatibility
}

// Set the X speed range for particles
emitter_set_x_speed :: proc(emitter: ^Emitter, min: f32, max: f32) {
	emitter.min_speed_x = min
	emitter.max_speed_x = max
}

// Set the Y speed range for particles
emitter_set_y_speed :: proc(emitter: ^Emitter, min: f32, max: f32) {
	emitter.min_speed_y = min
	emitter.max_speed_y = max
}

// Set the angular velocity range for particles
emitter_set_rotation :: proc(emitter: ^Emitter, min: f32, max: f32) {
	emitter.min_rotation = min
	emitter.max_rotation = max
}

// Set the size of the emitter (particles spawn randomly within this box)
emitter_set_size :: proc(emitter: ^Emitter, width: f32, height: f32) {
	emitter.width = width
	emitter.height = height
}

// Update the emitter and all its particles
emitter_update :: proc(obj: ^Object, dt: f32) {
	emitter := cast(^Emitter)obj

	// Handle emission
	if emitter.on {
		if emitter.explode {
			// Burst mode - emit all particles at once
			emitter.on = false
			particles_to_emit := emitter.quantity
			if particles_to_emit <= 0 || particles_to_emit > len(emitter.members) {
				particles_to_emit = len(emitter.members)
			}

			for i in 0 ..< particles_to_emit {
				emitter_emit_particle(emitter)
			}
			emitter.quantity = 0
		} else {
			// Continuous mode - emit particles over time
			emitter.timer += dt
			for emitter.frequency > 0 && emitter.timer > emitter.frequency && emitter.on {
				emitter.timer -= emitter.frequency
				emitter_emit_particle(emitter)

				if emitter.quantity > 0 {
					emitter.counter += 1
					if emitter.counter >= emitter.quantity {
						emitter.on = false
						emitter.quantity = 0
					}
				}
			}
		}
	}

	// Update all living particles
	for particle in emitter.members {
		if particle.exists {
			// Update particle lifespan
			if particle.lifespan > 0 {
				particle.lifespan -= dt
				if particle.lifespan <= 0 {
					sprite_kill(cast(^Sprite)particle)
					continue
				}
			}

			// Update particle physics
			sprite_update(&particle.base, dt)
		}
	}
}

// Draw the emitter's particles
emitter_draw :: proc(obj: ^Object) {
	emitter := cast(^Emitter)obj
	if !emitter.visible || !emitter.exists {
		return
	}

	for particle in emitter.members {
		if particle.exists && particle.visible {
			sprite_draw(&particle.base)
		}
	}
}

// Kill all particles in the emitter
emitter_kill :: proc(emitter: ^Emitter) {
	emitter.on = false
	for particle in emitter.members {
		sprite_kill(cast(^Sprite)particle)
	}
}

// Destroy the emitter and clean up memory
emitter_destroy :: proc(emitter: ^Emitter) {
	for particle in emitter.members {
		sprite_destroy(&particle.base)
	}
	delete(emitter.members)
	free(emitter)
}

// Get emitter position as a vector
emitter_get_position :: proc(emitter: ^Emitter) -> Vec2 {
	return Vec2{emitter.x, emitter.y}
}

// Set emitter position from a vector
emitter_set_position :: proc(emitter: ^Emitter, pos: Vec2) {
	emitter.x = pos.x
	emitter.y = pos.y
}

// Get emitter center position
emitter_get_center :: proc(emitter: ^Emitter) -> Vec2 {
	return Vec2{emitter.x + emitter.width / 2, emitter.y + emitter.height / 2}
}

// Set emitter position by its center
emitter_set_center :: proc(emitter: ^Emitter, center: Vec2) {
	emitter.x = center.x - emitter.width / 2
	emitter.y = center.y - emitter.height / 2
}
