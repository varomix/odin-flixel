# Migration Guide: v0.2 → v0.3

## Overview

Version 0.3 removes the need for users to import raylib directly. All necessary types and constants are now exposed through the `flx` package.

## Major Changes

### 1. No More Raylib Import Required

**Before (v0.2):**
```odin
package mygame

import flx "../../flixel"
import rl "vendor:raylib"  // ❌ Required in v0.2

main :: proc() {
    // ...
}
```

**After (v0.3):**
```odin
package mygame

import flx "../../flixel"  // ✅ Only import needed!

main :: proc() {
    // ...
}
```

### 2. Color Type Changes

**Before (v0.2):**
```odin
// Using raylib colors
sprite := flx.sprite_new(100, 100)
flx.sprite_make_graphic(sprite, 32, 32, rl.Color{255, 0, 0, 255})
flx.set_bg_color(game, rl.BLACK)

text := flx.text_new(10, 10, 200, "Score: 0", 20)
text.color = rl.WHITE
```

**After (v0.3):**
```odin
// Using flixel colors
sprite := flx.sprite_new(100, 100)
flx.sprite_make_graphic(sprite, 32, 32, flx.Color{255, 0, 0, 255})
flx.set_bg_color(game, flx.BLACK)

text := flx.text_new(10, 10, 200, "Score: 0", 20)
text.color = flx.WHITE
```

### 3. Color Constants

All common colors are now available as `flx` constants:

**Available Constants:**
- `flx.BLACK` - `{0, 0, 0, 255}`
- `flx.WHITE` - `{255, 255, 255, 255}`
- `flx.RED` - `{230, 41, 55, 255}`
- `flx.GREEN` - `{0, 228, 48, 255}`
- `flx.BLUE` - `{0, 121, 241, 255}`
- `flx.YELLOW` - `{253, 249, 0, 255}`
- `flx.ORANGE` - `{255, 161, 0, 255}`
- `flx.PURPLE` - `{200, 122, 255, 255}`
- `flx.PINK` - `{255, 109, 194, 255}`
- `flx.BROWN` - `{127, 106, 79, 255}`
- `flx.GRAY` - `{130, 130, 130, 255}`
- `flx.DARK_GRAY` - `{80, 80, 80, 255}`
- `flx.LIGHT_GRAY` - `{200, 200, 200, 255}`

**Helper Functions:**
```odin
// Create custom colors
custom := flx.rgb(100, 200, 50)              // RGB (alpha = 255)
transparent := flx.rgba(100, 200, 50, 128)   // RGBA
```

### 4. Key Input Changes

**Before (v0.2):**
```odin
import rl "vendor:raylib"

// Checking for key press
if rl.IsKeyPressed(.ESCAPE) {
    flx.quit()
}
```

**After (v0.3):**
```odin
// No raylib import needed!
if flx.key_pressed(.ESCAPE) {
    flx.quit()
}
```

**Supported Keys:**
- `.ESCAPE`, `.SPACE`, `.ENTER`
- `.UP`, `.DOWN`, `.LEFT`, `.RIGHT`
- `.W`, `.A`, `.S`, `.D`

### 5. Scale Factor Support

Version 0.3 adds built-in pixel-perfect scaling:

**Before (v0.2):**
```odin
game := flx.init(
    640,  // Window size
    480,
    "My Game",
    &initial_state.base,
    60,
)
```

**After (v0.3):**
```odin
game := flx.init(
    320,  // Game resolution
    240,
    "My Game",
    &initial_state.base,
    60,
    2,    // Scale factor (window will be 640x480)
)
```

This renders your game at 320x240 and scales it up 2x to 640x480 with crisp pixel-perfect filtering.

## Complete Migration Example

### Before (v0.2):

```odin
package ezplatformer

import flx "../../flixel"
import "core:fmt"
import rl "vendor:raylib"  // ❌ Need raylib

Play_State :: struct {
    using base: flx.State,
    player:     ^flx.Sprite,
    score:      ^flx.Text,
}

play_state_create :: proc(state: ^flx.State) {
    ps := cast(^Play_State)state
    
    // Set background (using rl.Color)
    flx.set_bg_color(flx.game, rl.Color{170, 170, 170, 255})
    
    // Create player (using rl.Color)
    ps.player = flx.sprite_new(100, 100)
    flx.sprite_make_graphic(ps.player, 16, 16, rl.Color{170, 17, 17, 255})
    flx.state_add(&ps.base, cast(^flx.Object)ps.player)
    
    // Create score text (using rl.WHITE)
    ps.score = flx.text_new(10, 10, 100, "SCORE: 0", 20)
    ps.score.color = rl.WHITE
    flx.state_add(&ps.base, cast(^flx.Object)ps.score)
}

play_state_update :: proc(state: ^flx.State, dt: f32) {
    ps := cast(^Play_State)state
    
    // Check for quit (using rl.IsKeyPressed)
    if rl.IsKeyPressed(.ESCAPE) {
        flx.quit()
    }
    
    flx.state_update(&ps.base, dt)
}

main :: proc() {
    flx.global_init()
    
    initial_state := play_state_new()
    
    game := flx.init(640, 480, "My Game", &initial_state.base, 60)
    flx.run(game)
}
```

### After (v0.3):

```odin
package ezplatformer

import flx "../../flixel"
import "core:fmt"
// ✅ No raylib import needed!

Play_State :: struct {
    using base: flx.State,
    player:     ^flx.Sprite,
    score:      ^flx.Text,
}

play_state_create :: proc(state: ^flx.State) {
    ps := cast(^Play_State)state
    
    // Set background (using flx.Color)
    flx.set_bg_color(flx.game, flx.Color{170, 170, 170, 255})
    
    // Create player (using flx.Color)
    ps.player = flx.sprite_new(100, 100)
    flx.sprite_make_graphic(ps.player, 16, 16, flx.Color{170, 17, 17, 255})
    flx.state_add(&ps.base, cast(^flx.Object)ps.player)
    
    // Create score text (using flx.WHITE)
    ps.score = flx.text_new(10, 10, 100, "SCORE: 0", 20)
    ps.score.color = flx.WHITE
    flx.state_add(&ps.base, cast(^flx.Object)ps.score)
}

play_state_update :: proc(state: ^flx.State, dt: f32) {
    ps := cast(^Play_State)state
    
    // Check for quit (using flx.key_pressed)
    if flx.key_pressed(.ESCAPE) {
        flx.quit()
    }
    
    flx.state_update(&ps.base, dt)
}

main :: proc() {
    flx.global_init()
    
    initial_state := play_state_new()
    
    // With scale factor for pixel-perfect rendering!
    game := flx.init(320, 240, "My Game", &initial_state.base, 60, 2)
    flx.run(game)
}
```

## Quick Find & Replace Guide

Use these regex patterns to quickly migrate your code:

1. **Remove raylib import:**
   - Find: `import rl "vendor:raylib"\n`
   - Replace: _(delete line)_

2. **Replace color type:**
   - Find: `rl\.Color`
   - Replace: `flx.Color`

3. **Replace color constants:**
   - Find: `rl\.(BLACK|WHITE|RED|GREEN|BLUE|YELLOW|GRAY|DARKGRAY|LIGHTGRAY)`
   - Replace: `flx.$1`

4. **Replace key checks:**
   - Find: `rl\.IsKeyPressed`
   - Replace: `flx.key_pressed`

## API Compatibility

### Still Using Raylib Internally

The flixel engine still uses raylib internally for rendering and windowing. The change is purely about the **public API** - users no longer need to know or care about raylib.

### When You Still Need Raylib

In most cases, you won't need to import raylib anymore. However, if you're doing advanced custom rendering or need raylib-specific features, you can still import it:

```odin
import rl "vendor:raylib"  // Only if you need advanced features
import flx "../../flixel"
```

But for typical game development with flixel, everything you need is in the `flx` package.

## Benefits of v0.3

✅ **Cleaner imports** - One import instead of two  
✅ **Better abstraction** - Don't need to know about underlying library  
✅ **Future-proof** - If we switch from raylib, your code won't break  
✅ **Easier for beginners** - Less to learn and remember  
✅ **Pixel-perfect scaling** - Built-in retro-style rendering  

## Need Help?

- Check the updated examples in `examples/ezplatformer/`
- Read the updated README in `flixel/README.md`
- See the color constants in `flixel/color.odin`

## Version History

- **v0.3.0** - Abstracted raylib dependency (this version)
- **v0.2.1** - Simplified state creation API
- **v0.2.0** - Refactored naming convention
- **v0.1.0** - Initial release

---

Happy game making! 🎮