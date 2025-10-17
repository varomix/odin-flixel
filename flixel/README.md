# Flixel Package

The core game framework package for Mix Motor - a Flixel-inspired 2D game engine in Odin.

## Overview

This package contains the core components of the Mix Motor game engine. It is designed to be imported into any Odin project to provide Flixel-like game development capabilities.

Import it as:
```odin
import flx "flixel"
```

## Package Contents

### `game.odin`
Main game engine managing the game loop, window, and state lifecycle.

**Key Types:**
- `Game` - Main game engine struct

**Key Procedures:**
- `init()` - Initialize the game with window settings
- `run()` - Start the main game loop
- `switch_state()` - Switch to a new game state
- `set_bg_color()` - Set background color

### `state.odin`
State management system for organizing game screens (menus, gameplay, etc.).

**Key Types:**
- `State` - Base state struct
- `State_VTable` - Virtual function table for state behavior

**Key Procedures:**
- `state_init()` - Initialize a state
- `state_add()` - Add an object to the state
- `state_update()` - Update all objects in the state
- `state_draw()` - Draw all objects in the state
- `state_destroy()` - Clean up state resources

### `color.odin`
Color types and constants that abstract away raylib dependency.

**Key Types:**
- `Color` - RGBA color struct (wraps raylib Color internally)

**Key Constants:**
- `BLACK`, `WHITE`, `RED`, `GREEN`, `BLUE`, `YELLOW`
- `ORANGE`, `PURPLE`, `PINK`, `BROWN`
- `GRAY`, `DARK_GRAY`, `LIGHT_GRAY`

**Key Procedures:**
- `rgba()` - Create color from RGBA values
- `rgb()` - Create color from RGB values (alpha = 255)
- `make_color()` - Overloaded color creation

### `object.odin`
Base game object with position, velocity, and acceleration physics.

**Key Types:**
- `Object` - Base object for all game entities
- `Object_VTable` - Virtual function table for object behavior

**Key Procedures:**
- `object_init()` - Initialize an object
- `object_update()` - Update physics (velocity, acceleration)
- `object_draw()` - Draw the object (base does nothing)
- `object_destroy()` - Mark object as destroyed

**Properties:**
- `x, y` - Position
- `width, height` - Size
- `velocity` - Movement per second (Vector2)
- `acceleration` - Acceleration per second (Vector2)
- `active` - Whether object updates
- `visible` - Whether object draws
- `exists` - Whether object exists in world

### `text.odin`
Text rendering component that extends Object.

**Key Types:**
- `Text` - Text object for rendering strings

**Key Procedures:**
- `text_new()` - Create a new text object
- `text_draw()` - Render the text
- `text_set_text()` - Change the text content
- `text_set_color()` - Change the text color
- `text_destroy()` - Clean up text object

## Usage

### Basic Setup

```odin
package main

import flx "flixel"

main :: proc() {
    // Initialize global state
    flx.global_init()
    
    initial_state := my_state_new()
    
    game := flx.init(
        320,                    // width
        240,                    // height
        "My Game",              // title
        &initial_state.base,    // initial state
        60,                     // target FPS
        2,                      // scale factor (optional, default = 1)
    )
    
    flx.run(game)
}
```

### Creating a State (Simple!)

Creating states is incredibly simple - just define three functions:

```odin
MyState :: struct {
    using base: flx.State,
    // Add your custom fields here
}

my_state_new :: proc() -> ^MyState {
    state := new(MyState)
    
    // One line to set up the state - no manual vtable setup needed!
    flx.state_setup(&state.base, my_state_create, my_state_update, my_state_draw)
    
    return state
}

my_state_create :: proc(state: ^flx.State) {
    my := cast(^MyState)state
    
    // Add objects to your state
    text := flx.text_new(100, 100, 200, "Hello!", 24)
    flx.state_add(&my.base, &text.base)
}

my_state_update :: proc(state: ^flx.State, dt: f32) {
    my := cast(^MyState)state
    flx.state_update(&my.base, dt)
    // Add your update logic
}

my_state_draw :: proc(state: ^flx.State) {
    my := cast(^MyState)state
    
    for member in my.members {
        if member.exists && member.visible {
            text := cast(^flx.Text)member
            if text != nil {
                flx.text_draw(text)
            }
        }
    }
}

// No destroy function needed - framework handles cleanup automatically!
```

### Working with Colors

**No need to import raylib!** Use `flx.Color` instead:

```odin
// Using color constants
sprite := flx.sprite_new(100, 100)
flx.sprite_make_graphic(sprite, 32, 32, flx.RED)

// Creating custom colors
my_color := flx.Color{170, 170, 170, 255}  // Light gray
custom := flx.rgb(100, 200, 50)             // RGB helper
alpha := flx.rgba(100, 200, 50, 128)        // RGBA helper

// Set background color
flx.set_bg_color(game, flx.Color{20, 20, 40, 255})
```

**Available Color Constants:**
- `flx.BLACK`, `flx.WHITE`
- `flx.RED`, `flx.GREEN`, `flx.BLUE`
- `flx.YELLOW`, `flx.ORANGE`, `flx.PURPLE`, `flx.PINK`
- `flx.BROWN`, `flx.GRAY`, `flx.DARK_GRAY`, `flx.LIGHT_GRAY`

### Adding Text Objects

**Three Ways to Use Text:**

```odin
// 1. Text objects in state (persistent, managed by state)
title := flx.text_new(100, 50, 200, "Game Title", 32, flx.YELLOW)
flx.state_add(state, &title.base)  // Draws automatically every frame

// 2. Text objects without color (defaults to WHITE)
score := flx.text_new(10, 10, 100, "Score: 0", 20)
flx.state_add(state, &score.base)

// 3. Quick text (one-liner, no state needed - perfect for debug/UI)
play_state_draw :: proc(state: ^flx.State) {
    // ... draw other stuff ...
    
    // One line - as simple as raylib!
    flx.text_quick(10, 570, "Press ESC to quit", 16, flx.GRAY)
}
```

**API Reference:**

| Function | Parameters | Use Case |
|----------|-----------|----------|
| `text_new()` | `x, y, width, text, font_size` | Persistent text, default WHITE color |
| `text_new()` | `x, y, width, text, font_size, color` | Persistent text, custom color |
| `text_quick()` | `x, y, text, font_size, color` | One-liner instant draw (no state) |

**When to Use Each:**

- **`text_new()` + state**: For game elements that need updates (scores, health, etc.)
- **`text_quick()`**: For static UI, debug info, or instructions

### Physics

```odin
// Create sprite with velocity
sprite := flx.sprite_new(100, 100)
flx.sprite_make_graphic(sprite, 16, 16, flx.RED)
sprite.velocity = {100, 0}        // Move right at 100 px/sec
sprite.acceleration = {0, 200}    // Gravity
sprite.max_velocity = {200, 400}  // Speed limits
sprite.drag = {400, 0}            // Horizontal friction

flx.state_add(state, &sprite.base)

// Physics updates automatically in flx.state_update()
```

### State Switching

```odin
// From any update function
new_state := another_state_new()
flx.switch_state(flx.game, &new_state.base)
```

### Input Handling

```odin
// Update input state each frame
flx.global_update_input()

// Check keys
if flx.g.keys.LEFT {
    player.acceleration.x = -200
}
if flx.g.keys.RIGHT {
    player.acceleration.x = 200
}

// Check for just pressed
if flx.keys_just_pressed("SPACE") {
    player.velocity.y = -200
}

// Check specific key press (no raylib import needed!)
if flx.key_pressed(.ESCAPE) {
    flx.quit()
}
```

## Dependencies

- **Odin core libraries** - Standard library
- **Raylib** - Graphics and windowing (used internally, users don't need to import it!)

**Note:** User code does NOT need to import raylib - all necessary types are exposed through the `flx` package!

## Design Patterns

### Virtual Tables
This engine uses vtables for polymorphism instead of OOP inheritance:

```odin
vtable := new(flx.State_VTable)
vtable.create = my_create_proc
vtable.update = my_update_proc
// etc.
```

### Struct Embedding
States and objects use Odin's `using` keyword for composition:

```odin
MyState :: struct {
    using base: flx.State,  // Embeds all State fields
    my_custom_field: int,
}
```

### Memory Management
Manual memory management - you allocate with `new()`, you clean up with `free()`:

```odin
state := new(MyState)           // Allocate
// ... use state ...
free(state.vtable)              // Free vtable
free(state)                     // Free state
```

## Performance Characteristics

- **Target**: 60 FPS
- **Rendering**: Hardware accelerated (OpenGL via Raylib)
- **Physics**: Simple Euler integration, O(n) per frame
- **Memory**: Manual control, no garbage collection
- **Thread Safety**: Single-threaded design

## Version

**0.3.0** - Abstracted raylib dependency
- Added `flx.Color` type - no need to import raylib!
- Added color constants: `BLACK`, `WHITE`, `RED`, etc.
- Added `flx.Key` enum and `key_pressed()` function
- Added scale factor support for pixel-perfect scaling
- Users no longer need to import raylib in their game code

**0.2.1** - Simplified state creation API
- Added `state_setup()` helper - one line to set up a state!
- Automatic vtable management - no manual allocation/cleanup
- No destroy functions needed - framework handles it
- Just define: create, update, and draw

**0.2.0** - Refactored naming convention
- Package renamed to `flixel`
- Removed `Flx` and `flx_` prefixes
- Cleaner API: `flx.init()` instead of `engine.flx_game_init()`

**0.1.0** - Initial release
- Basic game loop
- State management
- Text rendering
- Physics (velocity/acceleration)

## Future Features

See the main TODO.md for planned features:
- Sprite support
- Animation system
- Collision detection
- Tilemap rendering
- Audio system
- Camera system

## License

MIT License - See LICENSE file in project root

## Support

For documentation and examples, see the `docs/` directory in the project root.

---

**Flixel Package** - Making games, the Odin way 🎮