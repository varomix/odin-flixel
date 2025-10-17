# Quick Font Guide - Mix Motor

## TL;DR

Your flixel engine now uses a custom Nokia FC22 pixel font for all text automatically! 🎮

## It Just Works™

```odin
game := flx.init(800, 600, "My Game", &initial_state.base, 60)
// ✅ Custom font loaded and active!

text := flx.text_new(100, 100, 200, "Hello World!", 24, flx.WHITE)
// ✅ Uses custom font automatically!
```

## What Changed?

### Before
- Used raylib's default font (boring, generic)
- No consistent visual style

### After
- Uses Nokia FC22 pixel font (retro, cool)
- Automatic loading from `flixel/data/nokiafc22.ttf`
- Consistent look across your entire game
- Zero configuration required

## Quick Commands

```odin
// Load a different font
flx.load_custom_font("path/to/myfont.ttf")

// Adjust character spacing
flx.set_font_spacing(0.8)  // Tighter
flx.set_font_spacing(1.0)  // Default
flx.set_font_spacing(1.5)  // Wider

// Check current spacing
spacing := flx.get_font_spacing()
```

## Font Sizes That Look Good

```odin
flx.text_quick(10, 10, "8px - tiny",     8,  flx.WHITE)
flx.text_quick(10, 30, "16px - small",   16, flx.WHITE)
flx.text_quick(10, 50, "24px - medium",  24, flx.WHITE)
flx.text_quick(10, 80, "32px - large",   32, flx.WHITE)
flx.text_quick(10, 120, "48px - title",  48, flx.WHITE)
```

## Common Use Cases

### Game Title
```odin
title := flx.text_new(200, 100, 400, "MY GAME", 48, flx.YELLOW)
```

### Score Display
```odin
score := flx.text_new(10, 10, 200, "Score: 1000", 20, flx.WHITE)
```

### Instructions
```odin
flx.text_quick(10, 570, "Press SPACE to jump", 16, flx.GRAY)
```

### Debug Info
```odin
flx.text_quick(10, 10, fmt.tprintf("FPS: %d", rl.GetFPS()), 14, flx.GREEN)
```

## Troubleshooting

### Font not loading?
Check the console output:
- ✅ `Custom font loaded successfully: ...` = Working!
- ⚠️  `Warning: Failed to load custom font...` = Using fallback

### Font looks weird?
Try adjusting spacing:
```odin
flx.set_font_spacing(0.5)  // Try different values
```

### Need a different font?
1. Put your `.ttf` or `.otf` file somewhere
2. Load it after `flx.init()`:
```odin
flx.load_custom_font("assets/myfont.ttf")
```

## That's It!

Your game now has a custom font. No extra work needed. Just use `text_new()` and `text_quick()` as usual!

For more details, see [CUSTOM_FONTS.md](./CUSTOM_FONTS.md)

---

**Mix Motor** - Where games look good by default 🎮✨