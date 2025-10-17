package flixel

import "core:fmt"

// Group is a container for managing collections of sprites
Group :: struct {
	using base: Object,
	members:    [dynamic]^Sprite,
}

// Create a new group
group_new :: proc() -> ^Group {
	group := new(Group)
	object_init(&group.base, 0, 0, 0, 0)
	group.members = make([dynamic]^Sprite, 0, 32)
	return group
}

// Add a sprite to the group
group_add :: proc(group: ^Group, sprite: ^Sprite) -> ^Sprite {
	append(&group.members, sprite)
	return sprite
}

// Remove a sprite from the group
group_remove :: proc(group: ^Group, sprite: ^Sprite) -> ^Sprite {
	for i := 0; i < len(group.members); i += 1 {
		if group.members[i] == sprite {
			ordered_remove(&group.members, i)
			return sprite
		}
	}
	return nil
}

// Update all members in the group
group_update :: proc(group: ^Group, dt: f32) {
	if !group.active || !group.exists {
		return
	}

	for member in group.members {
		if member.exists && member.active {
			sprite_update(member, dt)
		}
	}
}

// Draw all members in the group
group_draw :: proc(group: ^Group) {
	if !group.visible || !group.exists {
		return
	}

	for member in group.members {
		if member.exists && member.visible {
			sprite_draw(member)
		}
	}
}

// Count living (existing) members
group_count_living :: proc(group: ^Group) -> int {
	count := 0
	for member in group.members {
		if member.exists {
			count += 1
		}
	}
	return count
}

// Count dead (non-existing) members
group_count_dead :: proc(group: ^Group) -> int {
	count := 0
	for member in group.members {
		if !member.exists {
			count += 1
		}
	}
	return count
}

// Get first available (dead) member
group_get_first_available :: proc(group: ^Group) -> ^Sprite {
	for member in group.members {
		if !member.exists {
			return member
		}
	}
	return nil
}

// Get first existing (alive) member
group_get_first_existing :: proc(group: ^Group) -> ^Sprite {
	for member in group.members {
		if member.exists {
			return member
		}
	}
	return nil
}

// Kill all members
group_kill_all :: proc(group: ^Group) {
	for member in group.members {
		if member.exists {
			sprite_kill(member)
		}
	}
}

// Revive all members
group_revive_all :: proc(group: ^Group) {
	for member in group.members {
		if !member.exists {
			sprite_revive(member)
		}
	}
}

// Clear the group (remove all members)
group_clear :: proc(group: ^Group) {
	clear(&group.members)
}

// Destroy the group and all its members
group_destroy :: proc(group: ^Group) {
	for member in group.members {
		if member != nil {
			sprite_destroy(member)
		}
	}
	delete(group.members)
	group.exists = false
	free(group)
}

// For each member that exists, call a function
group_for_each :: proc(group: ^Group, callback: proc(_: ^Sprite)) {
	for member in group.members {
		if member.exists {
			callback(member)
		}
	}
}
