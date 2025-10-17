# Mix Motor - A Flixel-like Game Framework in Odin

Mix Motor is a 2D game framework inspired by the classic Flixel framework, built in Odin using Raylib for rendering.

## 📁 Project Structure

```
mix_motor/
├── engine/              # Core framework package (reusable)
│   ├── flx_game.odin   # Game engine & loop
│   ├── flx_state.odin  # State management
│   ├── flx_object.odin # Base game object
│   └── flx_text.odin   # Text rendering
├── main.odin           # Example entry point
├── menu_state.odin     # Example menu state
├── play_state.odin     # Example play state
└── docs/               # Documentation
    ├── GETTING_STARTED.md
    ├── QUICK_START.md
    ├── EXAMPLES.md
    ├── FLIXEL_COMPARISON.md
    ├── PROJECT_OVERVIEW.md
    └── TODO.md
```

## 📚 Documentation

- **[Using the Engine](docs/USING_ENGINE.md)** - How to use the engine in your own projects
- **[Getting Started](docs/GETTING_STARTED.md)** - Complete beginner's guide with examples
- **[Quick Start](docs/QUICK_START.md)** - Common patterns and recipes
- **[Examples](docs/EXAMPLES.md)** - 10+ complete code examples
- **[Flixel Comparison](docs/FLIXEL_COMPARISON.md)** - Migration guide for Flixel developers
- **[Project Overview](docs/PROJECT_OVERVIEW.md)** - Architecture and design philosophy
- **[TODO](docs/TODO.md)** - Development roadmap and feature requests

## ⚡ Quick Start

```bash
# Build
./build.sh

# Or manually
odin build . -debug

# Run
./mix_motor
```

## Features

- **State Management**: Organize your game into states (menus, gameplay, game over, etc.)
- **Game Objects**: Base `FlxObject` class with position, velocity, and acceleration
- **Text Rendering**: `FlxText` for displaying text
- **Simple API**: Easy-to-use API similar to the original Flixel

## Getting Started

### Prerequisites

- **[Odin Compiler](https://odin-lang.org/)** installed
- **Raylib** vendor library (comes with Odin)

### Using the Engine in Your Project

The `engine` package is self-contained and can be imported into any Odin project:

```odin
import engine "path/to/mix_motor/engine"
```

See **[docs/USING_ENGINE.md](docs/USING_ENGINE.md)** for a complete guide on using the engine in your projects!

For learning the framework, see **[docs/GETTING_STARTED.md](docs/GETTING_STARTED.md)**.

## Hello World Example

Here's a simple example that creates a "Hello, World!" text:

```odin
package main

import "core:fmt"
import rl "vendor:raylib"
import engine "engine"

// PlayState is our main game state
PlayState :: struct {
    using base: engine.FlxState,
}

// Create a new PlayState
play_state_new :: proc() -> ^PlayState {
    state := new(PlayState)
    
    vtable := new(engine.FlxState_VTable)
    vtable.create = play_state_create
    vtable.update = play_state_update
    vtable.draw = play_state_draw
    vtable.destroy = play_state_destroy
    
    state.vtable = vtable
    return state
}

// Override create - this is where we set up our state
play_state_create :: proc(state: ^engine.FlxState) {
    play := cast(^PlayState)state
    engine.flx_state_init(&play.base)
    
    // Add a text field at position 0,0 with width 100
    text := engine.flx_text_new(0, 0, 100, "Hello, World!")
    engine.flx_state_add(&play.base, &text.base)
}

// In main.odin
main :: proc() {
    initial_state := play_state_new()
    
    game := engine.flx_game_init(
        800,                      // width
        600,                      // height
        "My Game",               // title
        &initial_state.base,     // initial state
        60,                      // target FPS
    )
    
    engine.flx_game_run(game)
}
```

## Core Components

### FlxGame

The main game engine that handles the game loop, state management, and rendering.

- `engine.flx_game_init()` - Initialize the game with window size, title, and initial state
- `engine.flx_game_run()` - Start the game loop
- `engine.flx_game_switch_state()` - Switch to a different game state
- `engine.flx_game_set_bg_color()` - Set the background color

### FlxState

Represents a game state (menu, gameplay, etc.). Create your own states by embedding `FlxState`.

- `create()` - Called when the state is initialized
- `update()` - Called every frame to update logic
- `draw()` - Called every frame to render
- `destroy()` - Called when the state is being destroyed
- `engine.flx_state_add()` - Add an object to the state

### FlxObject

The base type for all game entities. Has position, velocity, and acceleration.

- `x, y` - Position
- `width, height` - Size
- `velocity` - Movement speed per second
- `acceleration` - Acceleration per second
- `active` - Whether the object updates
- `visible` - Whether the object is drawn
- `exists` - Whether the object exists

### FlxText

A text rendering object that inherits from `FlxObject`.

- `engine.flx_text_new(x, y, width, text, font_size)` - Create a new text object
- `engine.flx_text_set_text()` - Change the text
- `engine.flx_text_set_color()` - Change the color

## Architecture

The framework uses a component-based architecture with virtual function tables for polymorphism:

1. **Game Loop**: The `FlxGame` manages the main game loop
2. **States**: Each state manages its own objects and logic
3. **Objects**: All game entities inherit from `FlxObject`
4. **Rendering**: Raylib handles low-level rendering

## Comparison to Original Flixel

### Original Flixel (ActionScript)
```actionscript
package {
    import org.flixel.*;
    
    public class PlayState extends FlxState {
        override public function create():void {
            add(new FlxText(0,0,100,"Hello, World!"));
        }
    }
}
```

### Mix Motor (Odin)
```odin
import engine "engine"

PlayState :: struct {
    using base: engine.FlxState,
}

play_state_create :: proc(state: ^engine.FlxState) {
    play := cast(^PlayState)state
    engine.flx_state_init(&play.base)
    
    text := engine.flx_text_new(0, 0, 100, "Hello, World!")
    engine.flx_state_add(&play.base, &text.base)
}
```

## 🗺️ Roadmap

**Version 0.1.0** (Current) ✅
- Basic game loop, states, text rendering

**Version 0.2.0** (Next) 🚧
- Sprite support
- Animation system
- More examples

**Future Versions**
- Collision detection
- Tilemap support
- Audio system
- Camera system
- Particle effects

See **[docs/TODO.md](docs/TODO.md)** for the complete roadmap!

## 🤝 Contributing

Contributions are welcome! Check out **[docs/TODO.md](docs/TODO.md)** for feature ideas.

**High Priority:**
- FlxSprite implementation
- Collision detection
- More examples

## 📖 Learn More

- **Raylib**: [raylib.com](https://www.raylib.com/)
- **Odin**: [odin-lang.org](https://odin-lang.org/)
- **Original Flixel**: [flixel.org](http://flixel.org/)

## 📜 License

This project is open source and available under the MIT License.

---

**Happy Game Making!** 🎮✨