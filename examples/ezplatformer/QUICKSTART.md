# EZPlatformer Quick Start Guide

## Build and Run (5 seconds)

```bash
./build.sh
./ezplatformer
```

## Controls

| Key | Action |
|-----|--------|
| ←→ or A/D | Move left/right |
| Space | Jump |
| ESC | Close game |

## Objective

1. Collect all 40 **yellow coins** 
2. Find the **dark gray exit door** (appears after collecting all coins)
3. Reach the exit to win!
4. Don't fall off the bottom of the screen!

## Tips

- You can only jump when standing on solid ground
- The player is a **red rectangle**
- Gray tiles are solid walls and platforms
- Watch your score in the top-left corner
- Status messages appear in the top-right

## What This Demonstrates

This example showcases the Odin-Flixel framework's core features:

- ✓ **Tilemap system** - 40×30 tile level with collision
- ✓ **Sprite physics** - Gravity, jumping, movement
- ✓ **Group management** - 40 coin sprites
- ✓ **Collision detection** - Player vs tiles
- ✓ **Overlap detection** - Collecting coins, reaching exit
- ✓ **Input handling** - Keyboard controls
- ✓ **UI rendering** - Score and status text
- ✓ **Game states** - Win/lose/reset logic

## Code Tour

- **main.odin** (32 lines) - Game initialization
- **play_state.odin** (1431 lines) - All game logic
  - Lines 24-1380: Level data array (40×30 = 1200 tiles)
  - Lines 1382-1393: Coin creation
  - Lines 1395-1407: Player movement/jumping
  - Lines 1409-1429: Collision and game logic

## Modify It!

Try changing these values in `play_state.odin`:

```odin
// Make player jump higher (line ~1402)
ps.player.velocity.y = -ps.player.max_velocity.y / 2  // Change /2 to /1.5

// Make player faster (line ~1390)
ps.player.max_velocity = {80, 200}  // Change 80 to 120

// Change gravity (line ~1391)
ps.player.acceleration.y = 200  // Change 200 to 150 (floatier)

// Change player color (line ~1389)
flx.sprite_make_graphic(ps.player, 10, 12, rl.Color{170, 17, 17, 255})
// Try: {17, 170, 17, 255} for green
```

## Performance

- **Build time**: ~1 second
- **Binary size**: 1.3 MB (debug)
- **FPS**: Solid 60 FPS
- **Tiles rendered**: ~1200 per frame
- **Sprites**: 40+ (coins + player + exit)

## Next Steps

1. Read the full [README.md](README.md)
2. Explore the [implementation details](../../IMPLEMENTATION_SUMMARY.md)
3. Check out the [framework features](../EXAMPLES.md)
4. Create your own game using this as a template!

## Troubleshooting

**Build fails?**
- Ensure Odin compiler is installed and in PATH
- Check that Raylib vendor library is available

**Game crashes?**
- Run with `-debug` flag for better error messages
- Check console output for initialization errors

**Controls not working?**
- Window must be focused
- Try clicking on the game window first

## Have Fun!

This is your starting point for making games with Odin-Flixel. Experiment, break things, learn, and most importantly - have fun building games! 🎮