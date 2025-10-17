# Odin-Flixel Examples

This directory contains example projects demonstrating the Odin-Flixel game framework.

## Available Examples

### EZPlatformer

**Directory**: `ezplatformer/`

A simple platformer game showcasing core Flixel features:

- **Tilemap-based levels**: 40x30 tile grid with collision detection
- **Player physics**: Gravity, jumping, drag, and velocity limits
- **Collectibles**: Coin collection system with group management
- **Win condition**: Collect all coins to reveal the exit
- **UI elements**: Score display and status text

**Controls**:
- Arrow Keys / WASD: Move
- Space: Jump

**Build**:
```bash
cd ezplatformer
./build.sh
./ezplatformer
```

## Framework Features Demonstrated

### Core Systems

| Feature | EZPlatformer | Description |
|---------|--------------|-------------|
| Tilemap | ✓ | Level design and collision |
| Sprite | ✓ | Player, coins, exit door |
| Group | ✓ | Managing multiple coins |
| Text | ✓ | Score and status display |
| State | ✓ | Game state management |
| Input | ✓ | Keyboard controls |
| Collision | ✓ | Tilemap-sprite collision |
| Overlap | ✓ | Coin/exit detection |

### Physics

- **Acceleration**: Gravity and player movement
- **Velocity**: Speed limits on X and Y axes
- **Drag**: Friction-like deceleration
- **Collision Response**: Separating sprites from solid tiles

### Rendering

- **Solid color sprites**: Simple colored rectangles
- **Tilemap rendering**: Automatic tile drawing
- **Text rendering**: UI overlays
- **Layer ordering**: Proper draw order management

## Creating Your Own Example

1. Create a new directory under `examples/`
2. Create a `main.odin` file with package name matching your directory
3. Import the flixel package: `import flx "../../flixel"`
4. Create a state with `create`, `update`, and `draw` callbacks
5. Initialize the game with `flx.init()` and `flx.run()`
6. Create a `build.sh` script for easy compilation

Example structure:
```
examples/
  my_example/
    main.odin
    my_state.odin
    build.sh
    README.md
```

## Next Steps

Try modifying the examples to learn more:

- **EZPlatformer**: Add enemies, different tile types, or power-ups
- Create your own example game using different Flixel features

## Resources

- Main project README: `../../README.md`
- Flixel API docs: `../../flixel/README.md`
- Original ActionScript Flixel examples: `../old_flixel_examples/`
