package flixel

import "base:intrinsics"

// State represents a game state (menu, play, game over, etc.)
State :: struct {
	// List of objects in this state
	members: [dynamic]^Object,

	// State management
	active:  bool,

	// Virtual table for polymorphism
	vtable:  ^State_VTable,
}

State_VTable :: struct {
	create: proc(state: ^State),
	update: proc(state: ^State, dt: f32),
	draw:   proc(state: ^State),
}

// Setup a state with its lifecycle callbacks
// This is the simplified way to create a state - no manual vtable setup needed!
state_setup :: proc(
	state: ^State,
	create_proc: proc(state: ^State),
	update_proc: proc(state: ^State, dt: f32),
	draw_proc: proc(state: ^State) = nil, // Optional draw function
) {
	// Allocate and setup vtable internally
	vtable := new(State_VTable)
	vtable.create = create_proc
	vtable.update = update_proc

	// If a custom draw function is provided, use it. Otherwise, use the generic one.
	if draw_proc != nil {
		vtable.draw = draw_proc
	} else {
		vtable.draw = state_draw // Default draw
	}

	state.vtable = vtable
	state.members = make([dynamic]^Object, 0, 16)
	state.active = true
}

// Convenience function: Create a state with simpler setup
// Usage: state := state_make(MenuState, menu_state_create, menu_state_update)
// Note: Callbacks still use ^State but you cast once at the top of your function
state_make :: proc(
	$T: typeid,
	create_proc: proc(_: ^State),
	update_proc: proc(_: ^State, _: f32),
	draw_proc: proc(_: ^State) = nil,
) -> ^T {
	state := new(T)
	state_setup(&state.base, create_proc, update_proc, draw_proc)
	return state
}

// Initialize a new state (used internally, prefer state_setup for user code)
state_init :: proc(state: ^State) {
	state.members = make([dynamic]^Object, 0, 16)
	state.active = true
}

// Add an object to the state (overloaded for common types)
state_add :: proc {
	state_add_object,
	state_add_sprite,
	state_add_text,
	state_add_group,
	state_add_tilemap,
	state_add_emitter,
	state_add_to_custom_state,
}

// Add a raw Object to the state
state_add_object :: proc(state: ^State, obj: ^Object) -> ^Object {
	append(&state.members, obj)
	return obj
}

// Add a Sprite to the state (automatically extracts the base)
state_add_sprite :: proc(state: ^State, sprite: ^Sprite) -> ^Sprite {
	append(&state.members, &sprite.base)
	return sprite
}

// Add a Text to the state (automatically extracts the base)
state_add_text :: proc(state: ^State, text: ^Text) -> ^Text {
	append(&state.members, &text.base)
	return text
}

// Add a Group to the state (automatically extracts the base)
state_add_group :: proc(state: ^State, group: ^Group) -> ^Group {
	append(&state.members, &group.base)
	return group
}

// Add a Tilemap to the state (automatically extracts the base)
state_add_tilemap :: proc(state: ^State, tilemap: ^Tilemap) -> ^Tilemap {
	append(&state.members, &tilemap.base)
	return tilemap
}

// Add an Emitter to the state (automatically extracts the base)
state_add_emitter :: proc(state: ^State, emitter: ^Emitter) -> ^Emitter {
	append(&state.members, &emitter.base)
	return emitter
}
// Generic add for custom state types (works with MenuState, PlayState, etc.)
// This allows: state_add(menu, obj) instead of state_add(&menu.base, obj)
state_add_to_custom_state :: proc(state: ^$T, obj: ^$O) -> ^O {
	// Since the custom state uses "using base: State", we can access members directly
	// The cast is needed to make Odin understand the type relationship
	base_state := cast(^State)state
	append(&base_state.members, &obj.base)
	return obj
}

// Default create - does nothing, meant to be overridden
state_create :: proc(state: ^State) {
	// Override this in your state
}

// Update all members
state_update :: proc(state: ^State, dt: f32) {
	if !state.active {
		return
	}

	for member in state.members {
		if member != nil && member.exists && member.active {
			member.vtable.update(member, dt)
		}
	}
}

// Draw all members
state_draw :: proc(state: ^State) {
	if !state.active {
		return
	}

	for member in state.members {
		if member != nil && member.exists && member.visible {
			member.vtable.draw(member)
		}
	}
}

// Destroy the state and all its members
// This automatically frees the vtable and cleans up resources
state_destroy :: proc(state: ^State) {
	for member in state.members {
		if member != nil {
			object_destroy(member)
			// Free the actual object memory
			free(member)
		}
	}
	delete(state.members)

	// Free vtable if it exists
	if state.vtable != nil {
		free(state.vtable)
		state.vtable = nil
	}

	state.active = false
}
