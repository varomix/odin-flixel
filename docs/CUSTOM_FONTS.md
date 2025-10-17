# Custom Fonts in Mix Motor

Mix Motor's flixel engine includes built-in support for custom fonts. By default, the engine automatically loads and uses the Nokia FC22 font located in `flixel/data/nokiafc22.ttf`.

## Quick Start

Custom fonts work automatically! When you initialize your game, the font is loaded:

```odin
game := flx.init(800, 600, "My Game", &initial_state.base, 60)
// The custom font is now loaded and used for all text rendering
```

All text in your game will automatically use the custom font:

```odin
// Text objects
title := flx.text_new(100, 50, 200, "Game Title", 32, flx.YELLOW)
flx.state_add(state, &title.base)

// Quick text (one-liners)
flx.text_quick(10, 10, "Score: 100", 20, flx.WHITE)
```

## How It Works

The flixel engine automatically:
1. Loads the font from `flixel/data/nokiafc22.ttf` during `flx.init()`
2. Uses it for all `text_new()` and `text_quick()` calls
3. Falls back to raylib's default font if loading fails
4. Unloads the font properly when the game closes

## Advanced Configuration

### Loading a Different Font

Replace the default font with your own:

```odin
// After flx.init()
flx.load_custom_font("my_assets/my_font.ttf")
```

### Adjusting Character Spacing

Fine-tune the spacing between characters:

```odin
// Tighter spacing (good for pixel fonts)
flx.set_font_spacing(0.5)

// Default spacing
flx.set_font_spacing(1.0)

// Wider spacing (more readable)
flx.set_font_spacing(2.0)

// Check current spacing
current := flx.get_font_spacing()
```

## Font Files

### Supported Formats

Mix Motor uses raylib's font loading, which supports:
- `.ttf` - TrueType fonts (recommended)
- `.otf` - OpenType fonts

### Adding Your Own Font

1. Place your font file in the `flixel/data/` directory (or any accessible path)
2. Call `flx.load_custom_font("path/to/your/font.ttf")` after `flx.init()`

```odin
main :: proc() {
    game := flx.init(800, 600, "My Game", &initial_state.base, 60)
    
    // Load your custom font
    flx.load_custom_font("flixel/data/my_pixel_font.ttf")
    
    // Optionally adjust spacing
    flx.set_font_spacing(0.8)
    
    flx.run(game)
}
```

## API Reference

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `load_custom_font()` | `font_path: string` | - | Load a custom font from file path |
| `set_font_spacing()` | `spacing: f32` | - | Set character spacing (default: 1.0) |
| `get_font_spacing()` | - | `f32` | Get current character spacing value |

### Global Variables

The following are internal to the flixel package but useful to understand:

- `custom_font: rl.Font` - The loaded font object
- `font_loaded: bool` - Whether a custom font was successfully loaded
- `font_spacing: f32` - Current character spacing (default: 1.0)

## Examples

### Example 1: Basic Text with Custom Font

```odin
MenuState :: struct {
    using base: flx.State,
    title: ^flx.Text,
}

menu_state_create :: proc(state: ^flx.State) {
    menu := cast(^MenuState)state
    
    // This automatically uses the custom font
    menu.title = flx.text_new(250, 150, 400, "GAME TITLE", 48, flx.YELLOW)
    flx.state_add(&menu.base, &menu.title.base)
}
```

### Example 2: Multiple Font Sizes

```odin
play_state_create :: proc(state: ^flx.State) {
    play := cast(^PlayState)state
    
    // Large header
    header := flx.text_new(100, 50, 600, "Level 1", 64, flx.WHITE)
    flx.state_add(&play.base, &header.base)
    
    // Medium subtitle
    subtitle := flx.text_new(100, 150, 600, "Castle Grounds", 32, flx.GRAY)
    flx.state_add(&play.base, &subtitle.base)
    
    // Small instructions
    hint := flx.text_new(100, 250, 600, "Use arrow keys to move", 16, flx.LIGHT_GRAY)
    flx.state_add(&play.base, &hint.base)
}
```

### Example 3: Quick Debug Text

```odin
play_state_draw :: proc(state: ^flx.State) {
    play := cast(^PlayState)state
    
    // Draw state members...
    
    // Quick debug info (no state object needed)
    flx.text_quick(10, 10, fmt.tprintf("FPS: %d", rl.GetFPS()), 16, flx.GREEN)
    flx.text_quick(10, 30, fmt.tprintf("Players: %d", play.player_count), 16, flx.WHITE)
}
```

### Example 4: Custom Font with Spacing

```odin
main :: proc() {
    game := flx.init(800, 600, "Pixel Perfect Game", &initial_state.base, 60)
    
    // Load a pixel art font
    flx.load_custom_font("flixel/data/pixel_font.ttf")
    
    // Pixel fonts often look better with tighter spacing
    flx.set_font_spacing(0.5)
    
    flx.run(game)
}
```

## Best Practices

### Font Size Recommendations

The Nokia FC22 font (and most pixel fonts) look best at specific sizes:

- **8px** - Tiny (hard to read, use sparingly)
- **16px** - Small (good for UI, instructions)
- **24px** - Medium (good for body text)
- **32px** - Large (good for headers)
- **48px+** - Extra Large (titles, logo)

### Spacing Guidelines

| Font Type | Recommended Spacing | Notes |
|-----------|-------------------|-------|
| Pixel fonts | 0.5 - 1.0 | Tighter spacing looks crisper |
| TrueType fonts | 1.0 - 1.5 | Standard spacing |
| Script fonts | 1.5 - 2.0 | Need more space to breathe |

### Performance Tips

1. **Load once**: Only call `load_custom_font()` once at startup
2. **Reuse text objects**: Don't create new text objects every frame
3. **Use `text_quick()` wisely**: It's great for debug info but creates overhead

## Troubleshooting

### Font Not Loading

If you see "Warning: Failed to load custom font, using default":

1. **Check the path**: Make sure the file exists
2. **Check permissions**: Ensure the file is readable
3. **Check format**: Use `.ttf` or `.otf` files
4. **Check working directory**: The path is relative to where you run the executable

### Font Looks Blurry

For pixel-perfect fonts:
1. Use font sizes that are multiples of the original design size
2. Adjust spacing with `set_font_spacing()`
3. Make sure your game scale factor is an integer (2x, 3x, not 1.5x)

### Text Not Appearing

1. **Check visibility**: Ensure `text.visible = true`
2. **Check position**: Make sure text is within screen bounds
3. **Check color**: Don't use same color as background
4. **Check state**: Verify the text object is added to the state

## Default Font Information

### Nokia FC22

The default font included with Mix Motor:

- **Name**: Nokia FC22
- **Type**: Pixel font
- **Style**: Monospace
- **Character set**: ASCII (95 glyphs)
- **Original size**: 32px
- **License**: Free for personal and commercial use
- **Best sizes**: 16px, 24px, 32px, 48px

This font is inspired by classic Nokia phone displays and gives your game a retro, pixelated look.

## Future Features

Planned improvements to the font system:

- [ ] Multiple font support (font per text object)
- [ ] Font atlas preloading for better performance
- [ ] Text alignment options (left, center, right)
- [ ] Text wrapping
- [ ] Rich text formatting (colors, styles within one text object)
- [ ] Bitmap font support (.fnt files)

## Related Documentation

- [Text System](./TEXT_SYSTEM.md) - Full text rendering documentation
- [Flixel Package](../flixel/README.md) - Main package documentation
- [Examples](../examples/) - Working code examples

---

**Mix Motor** - Making games, the Odin way 🎮