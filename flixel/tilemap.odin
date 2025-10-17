package flixel

import "core:fmt"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

// Tilemap for level rendering and collision
Tilemap :: struct {
	using base:       Object,

	// Tile data
	data:             []int,
	width_in_tiles:   int,
	height_in_tiles:  int,
	tile_width:       int,
	tile_height:      int,

	// Collision
	allow_collisions: u32,

	// Auto-tiling (simplified)
	auto_tile:        bool,
}

// Auto tile constants
AUTO :: 0
ALT :: 1
RANDOM :: 2

// Create a new tilemap
tilemap_new :: proc() -> ^Tilemap {
	tilemap := new(Tilemap)
	object_init(&tilemap.base, 0, 0, 0, 0)
	tilemap.tile_width = 8
	tilemap.tile_height = 8
	tilemap.allow_collisions = COLLISION_ANY
	tilemap.auto_tile = false
	return tilemap
}

// Load map from CSV string and tile size
tilemap_load_map :: proc(
	tilemap: ^Tilemap,
	map_data: string,
	tile_width: int = 8,
	tile_height: int = 0,
	auto_tile: int = 0,
) {
	tilemap.tile_width = tile_width
	tilemap.tile_height = tile_height if tile_height > 0 else tile_width
	tilemap.auto_tile = (auto_tile == AUTO)

	// Parse CSV data
	lines := strings.split(map_data, "\n")
	rows := make([dynamic][]int)
	defer delete(rows)

	max_cols := 0

	for line in lines {
		trimmed := strings.trim_space(line)
		if len(trimmed) == 0 {
			continue
		}

		values := strings.split(trimmed, ",")
		defer delete(values)

		row := make([dynamic]int)

		for val_str in values {
			val_trimmed := strings.trim_space(val_str)
			if len(val_trimmed) > 0 {
				val, ok := strconv.parse_int(val_trimmed)
				if ok {
					append(&row, val)
				}
			}
		}

		if len(row) > max_cols {
			max_cols = len(row)
		}

		append(&rows, row[:])
	}

	tilemap.height_in_tiles = len(rows)
	tilemap.width_in_tiles = max_cols

	// Flatten to 1D array
	total_tiles := tilemap.width_in_tiles * tilemap.height_in_tiles
	tilemap.data = make([]int, total_tiles)

	for row_idx := 0; row_idx < len(rows); row_idx += 1 {
		row := rows[row_idx]
		for col_idx := 0; col_idx < len(row); col_idx += 1 {
			if col_idx < tilemap.width_in_tiles {
				idx := row_idx * tilemap.width_in_tiles + col_idx
				tilemap.data[idx] = row[col_idx]
			}
		}
		delete(row)
	}

	// Set size
	tilemap.width = f32(tilemap.width_in_tiles * tilemap.tile_width)
	tilemap.height = f32(tilemap.height_in_tiles * tilemap.tile_height)

	delete(lines)
}

// Convert array to CSV string (helper function)
tilemap_array_to_csv :: proc(data: []int, width_in_tiles: int) -> string {
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	for i := 0; i < len(data); i += 1 {
		if i > 0 && i % width_in_tiles == 0 {
			strings.write_string(&builder, "\n")
		} else if i > 0 {
			strings.write_string(&builder, ",")
		}
		strings.write_int(&builder, data[i])
	}

	return strings.clone(strings.to_string(builder))
}

// Get tile at position
tilemap_get_tile :: proc(tilemap: ^Tilemap, x: int, y: int) -> int {
	if x < 0 || y < 0 || x >= tilemap.width_in_tiles || y >= tilemap.height_in_tiles {
		return 0
	}

	idx := y * tilemap.width_in_tiles + x
	if idx >= 0 && idx < len(tilemap.data) {
		return tilemap.data[idx]
	}

	return 0
}

// Set tile at position
tilemap_set_tile :: proc(tilemap: ^Tilemap, x: int, y: int, value: int) {
	if x < 0 || y < 0 || x >= tilemap.width_in_tiles || y >= tilemap.height_in_tiles {
		return
	}

	idx := y * tilemap.width_in_tiles + x
	if idx >= 0 && idx < len(tilemap.data) {
		tilemap.data[idx] = value
	}
}

// Get tile at world position
tilemap_get_tile_at_world :: proc(tilemap: ^Tilemap, world_x: f32, world_y: f32) -> int {
	tile_x := int((world_x - tilemap.x) / f32(tilemap.tile_width))
	tile_y := int((world_y - tilemap.y) / f32(tilemap.tile_height))
	return tilemap_get_tile(tilemap, tile_x, tile_y)
}

// Draw the tilemap
tilemap_draw :: proc(tilemap: ^Tilemap) {
	if !tilemap.visible || !tilemap.exists {
		return
	}

	for row := 0; row < tilemap.height_in_tiles; row += 1 {
		for col := 0; col < tilemap.width_in_tiles; col += 1 {
			tile := tilemap_get_tile(tilemap, col, row)

			if tile != 0 {
				x := tilemap.x + f32(col * tilemap.tile_width)
				y := tilemap.y + f32(row * tilemap.tile_height)

				// Simple rendering - solid tiles
				// In a real implementation, you'd use a tileset texture
				color := rl.GRAY

				if tile == 1 {
					color = Color{100, 100, 100, 255}
				}

				rl.DrawRectangle(
					i32(x),
					i32(y),
					i32(tilemap.tile_width),
					i32(tilemap.tile_height),
					color,
				)
			}
		}
	}
}

// Check if a tile is solid
tilemap_is_solid :: proc(tilemap: ^Tilemap, x: int, y: int) -> bool {
	tile := tilemap_get_tile(tilemap, x, y)
	return tile != 0
}

// Overlaps tilemap - check if sprite overlaps any solid tiles
tilemap_overlaps_sprite :: proc(tilemap: ^Tilemap, sprite: ^Sprite) -> bool {
	if !tilemap.exists || !sprite.exists {
		return false
	}

	// Get sprite bounds in tile coordinates
	left := int((sprite.x - tilemap.x) / f32(tilemap.tile_width))
	right := int((sprite.x + sprite.width - tilemap.x) / f32(tilemap.tile_width))
	top := int((sprite.y - tilemap.y) / f32(tilemap.tile_height))
	bottom := int((sprite.y + sprite.height - tilemap.y) / f32(tilemap.tile_height))

	// Check all tiles in range
	for ty := top; ty <= bottom; ty += 1 {
		for tx := left; tx <= right; tx += 1 {
			if tilemap_is_solid(tilemap, tx, ty) {
				return true
			}
		}
	}

	return false
}

// Destroy tilemap
tilemap_destroy :: proc(tilemap: ^Tilemap) {
	if tilemap.data != nil {
		delete(tilemap.data)
	}
	tilemap.exists = false
	free(tilemap)
}
