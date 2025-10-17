# Input Handling Guide

## Overview

The Flixel framework uses Raylib for input handling. This guide covers keyboard, mouse, and gamepad input, plus important notes about key configuration.

## Important: ESC Key

By default, Raylib uses ESC as the window close key. The Flixel framework **disables this behavior** so you can use ESC for game navigation (like returning to menus).

```odin
// This is automatically done in flx.init()
rl.SetExitKey(.KEY_NULL)  // ESC no longer closes the window
```

To quit your game, use:
```odin
flx.quit()
```

## Keyboard Input

### Checking Key Presses

```odin
// Key was just pressed this frame
if rl.IsKeyPressed(.SPACE) {
    fmt.println("Space pressed!")
}

// Key is being held down
if rl.IsKeyDown(.LEFT) {
    player.x -= 200 * dt  // Move left
}

// Key was just released
if rl.IsKeyReleased(.ENTER) {
    fmt.println("Enter released!")
}
```

### Common Keys

```odin
.SPACE          // Spacebar
.ENTER          // Enter/Return
.ESCAPE         // ESC (use for menus, not window closing)
.BACKSPACE      // Backspace

// Arrow keys
.UP, .DOWN, .LEFT, .RIGHT

// Letters (uppercase)
.A, .B, .C, ... .Z

// Numbers
.ZERO, .ONE, .TWO, ... .NINE

// Function keys
.F1, .F2, ... .F12

// Modifiers
.LEFT_SHIFT, .RIGHT_SHIFT
.LEFT_CONTROL, .RIGHT_CONTROL
.LEFT_ALT, .RIGHT_ALT
```

## Mouse Input

### Mouse Buttons

```odin
// Mouse button just pressed
if rl.IsMouseButtonPressed(.LEFT) {
    fmt.println("Left click!")
}

// Mouse button held down
if rl.IsMouseButtonDown(.RIGHT) {
    fmt.println("Right button held")
}

// Mouse button released
if rl.IsMouseButtonReleased(.LEFT) {
    fmt.println("Left button released")
}
```

### Mouse Position

```odin
mouse_pos := rl.GetMousePosition()
fmt.println("Mouse X:", mouse_pos.x, "Y:", mouse_pos.y)

// Check if mouse is in a rectangle
if rl.CheckCollisionPointRec(mouse_pos, button_rect) {
    // Mouse is over the button
}
```

### Mouse Wheel

```odin
wheel := rl.GetMouseWheelMove()
if wheel > 0 {
    // Scrolled up
} else if wheel < 0 {
    // Scrolled down
}
```

## Common Input Patterns

### Menu Navigation

```odin
menu_state_update :: proc(state: ^flx.State, dt: f32) {
    menu := cast(^MenuState)state
    
    // Start game
    if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
        play := play_state_new()
        flx.switch_state(flx.game, &play.base)
    }
    
    // Quit game
    if rl.IsKeyPressed(.ESCAPE) {
        flx.quit()
    }
    
    flx.state_update(&menu.base, dt)
}
```

### Player Movement (Held Keys)

```odin
play_state_update :: proc(state: ^flx.State, dt: f32) {
    play := cast(^PlayState)state
    
    speed : f32 = 200.0  // pixels per second
    
    if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
        play.player.x -= speed * dt
    }
    if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
        play.player.x += speed * dt
    }
    if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
        play.player.y -= speed * dt
    }
    if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
        play.player.y += speed * dt
    }
    
    flx.state_update(&play.base, dt)
}
```

### Jump (Single Press)

```odin
if rl.IsKeyPressed(.SPACE) && player_on_ground {
    player.velocity.y = -400  // Jump up
}
```

### Pause Menu Toggle

```odin
play_state_update :: proc(state: ^flx.State, dt: f32) {
    play := cast(^PlayState)state
    
    if rl.IsKeyPressed(.ESCAPE) {
        play.paused = !play.paused
    }
    
    if !play.paused {
        flx.state_update(&play.base, dt)
    }
}
```

### Return to Menu

```odin
play_state_update :: proc(state: ^flx.State, dt: f32) {
    play := cast(^PlayState)state
    
    if rl.IsKeyPressed(.ESCAPE) {
        menu := menu_state_new()
        flx.switch_state(flx.game, &menu.base)
        return  // Important: don't continue updating
    }
    
    flx.state_update(&play.base, dt)
}
```

### Mouse Click Detection

```odin
menu_state_update :: proc(state: ^flx.State, dt: f32) {
    menu := cast(^MenuState)state
    
    if rl.IsMouseButtonPressed(.LEFT) {
        mouse_pos := rl.GetMousePosition()
        
        // Check if clicked on play button
        play_button := rl.Rectangle{300, 200, 200, 50}
        if rl.CheckCollisionPointRec(mouse_pos, play_button) {
            play := play_state_new()
            flx.switch_state(flx.game, &play.base)
        }
    }
    
    flx.state_update(&menu.base, dt)
}
```

## Best Practices

### 1. Use IsKeyPressed for Actions

```odin
// ✅ Good - fires once per press
if rl.IsKeyPressed(.SPACE) {
    shoot()
}

// ❌ Bad - fires every frame while held
if rl.IsKeyDown(.SPACE) {
    shoot()  // Shoots way too fast!
}
```

### 2. Use IsKeyDown for Movement

```odin
// ✅ Good - smooth continuous movement
if rl.IsKeyDown(.LEFT) {
    player.x -= speed * dt
}

// ❌ Bad - jerky movement
if rl.IsKeyPressed(.LEFT) {
    player.x -= speed * dt  // Only moves one frame at a time
}
```

### 3. Always Multiply by Delta Time

```odin
// ✅ Good - frame-rate independent
player.x += speed * dt

// ❌ Bad - speed depends on frame rate
player.x += speed
```

### 4. Return Early After State Switch

```odin
if rl.IsKeyPressed(.ESCAPE) {
    menu := menu_state_new()
    flx.switch_state(flx.game, &menu.base)
    return  // ✅ Don't continue updating this state
}

// Continue normal update...
```

## Gamepad Input

### Check if Gamepad is Available

```odin
if rl.IsGamepadAvailable(0) {
    // Gamepad 0 is connected
}
```

### Gamepad Buttons

```odin
if rl.IsGamepadButtonPressed(0, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN) {  // A button
    fmt.println("A pressed!")
}

if rl.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_DOWN) {  // D-pad down
    player.y += speed * dt
}
```

### Gamepad Analog Sticks

```odin
left_x := rl.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_X)
left_y := rl.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_Y)

// Add deadzone
deadzone :: 0.2
if abs(left_x) > deadzone {
    player.x += left_x * speed * dt
}
if abs(left_y) > deadzone {
    player.y += left_y * speed * dt
}
```

## Example: Complete Input Handler

```odin
handle_player_input :: proc(player: ^Player, dt: f32) {
    speed : f32 = 200.0
    
    // Keyboard movement
    if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
        player.velocity.x = -speed
    } else if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
        player.velocity.x = speed
    } else {
        player.velocity.x = 0
    }
    
    // Jump
    if rl.IsKeyPressed(.SPACE) && player.on_ground {
        player.velocity.y = -400
    }
    
    // Gamepad support
    if rl.IsGamepadAvailable(0) {
        left_x := rl.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_X)
        if abs(left_x) > 0.2 {
            player.velocity.x = left_x * speed
        }
        
        if rl.IsGamepadButtonPressed(0, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN) && player.on_ground {
            player.velocity.y = -400  // Jump
        }
    }
}
```

## Debugging Input

```odin
// Print all pressed keys
key := rl.GetKeyPressed()
if key != .KEY_NULL {
    fmt.println("Key pressed:", key)
}

// Print mouse position
mouse_pos := rl.GetMousePosition()
fmt.println("Mouse:", mouse_pos)
```

## Summary

- **ESC is free to use** - Window closing is disabled
- Use `flx.quit()` to exit the game
- Use `IsKeyPressed()` for actions (shoot, jump, select)
- Use `IsKeyDown()` for movement (walk, run)
- Always multiply movement by `dt` for smooth frame-rate independent motion
- Return early after switching states

---

**Version:** 0.2.1  
**Master your input handling!** 🎮