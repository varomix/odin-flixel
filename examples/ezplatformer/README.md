# EZPlatformer Example

A simple platformer game demonstrating the Odin-Flixel framework capabilities.

## Features

- Tilemap-based level design (40x30 tiles at 8x8 pixels)
- Player physics with gravity, jumping, and collision
- Collectible coins system
- Win condition (collect all coins, find the exit)
- Score tracking

## Building

```bash
./build.sh
```

Or manually:

```bash
odin build . -out:ezplatformer -debug
```

## Running

```bash
./ezplatformer
```

## Controls

- **Arrow Keys / WASD**: Move left and right
- **Space**: Jump (only when on ground)

## Gameplay

1. Collect all the yellow coins scattered throughout the level
2. Once all coins are collected, a dark gray exit door will appear
3. Reach the exit to win!
4. Don't fall off the bottom of the screen or you'll have to restart

## Implementation Details

This example demonstrates:

- **Tilemap**: Level collision and rendering using a tile-based system
- **Sprite**: Player and coin entities with physics
- **Group**: Managing multiple coin sprites efficiently
- **Collision**: Tile-based collision detection and response
- **Overlap**: Detecting when player touches coins or exit
- **State Management**: Game state with create, update, and draw callbacks
- **Input Handling**: Keyboard input for player control

## Code Structure

- `main.odin`: Entry point, initializes the game engine
- `play_state.odin`: Main gameplay state with level, player, and game logic

## Original

This is a port of the classic ActionScript 3 Flixel example "EZPlatformer" to Odin.