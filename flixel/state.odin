package flixel

import "core:fmt"
import rl "vendor:raylib"

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
	create:  proc(state: ^State),
	update:  proc(state: ^State, dt: f32),
	draw:    proc(state: ^State),
}

// Setup a state with its lifecycle callbacks
// This is the simplified way to create a state - no manual vtable setup needed!
state_setup :: proc(
	state: ^State,
	create_proc: proc(state: ^State),
	update_proc: proc(state: ^State, dt: f32),
	draw_proc: proc(state: ^State),
) {
	// Allocate and setup vtable internally
	vtable := new(State_VTable)
	vtable.create = create_proc
	vtable.update = update_proc
	vtable.draw = draw_proc

	state.vtable = vtable
	state.members = make([dynamic]^Object, 0, 16)
	state.active = true
}

// Initialize a new state (used internally, prefer state_setup for user code)
state_init :: proc(state: ^State) {
	state.members = make([dynamic]^Object, 0, 16)
	state.active = true
}

// Add an object to the state
state_add :: proc(state: ^State, obj: ^Object) -> ^Object {
	append(&state.members, obj)
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
		if member.exists && member.active {
			object_update(member, dt)
		}
	}
}

// Draw all members
state_draw :: proc(state: ^State) {
	if !state.active {
		return
	}

	for member in state.members {
		if member.exists && member.visible {
			object_draw(member)
		}
	}
}

// Destroy the state and all its members
// This automatically frees the vtable and cleans up resources
state_destroy :: proc(state: ^State) {
	for member in state.members {
		if member.exists {
			object_destroy(member)
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
