# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Godotcraft is a Minecraft-inspired blocky open world game built with Godot 4.4. The game features voxel-based terrain, a first-person player controller, inventory system, and various visual effects.

## Architecture

### Core Systems

- **GridMap-based world**: The game world is built using Godot's GridMap system with a mesh library containing various block types
- **Signal-based architecture**: Global signals are managed through an autoloaded `Signals` singleton for decoupled communication
- **Scene management**: Handled by the `SceneChanger` singleton for transitioning between game states
- **VFX system**: Particle effects managed through `VfxSpawner` singleton

### Key Components

- **Player Controller** (`scripts/player.gd`): First-person controller with mouse look, movement, jumping, head bobbing, and FOV changes
- **World System** (`scripts/world.gd`): Manages the game world, inventory display, and handles block placement/destruction
- **Grid Map** (`scripts/grid_map.gd`): Handles voxel world generation and block manipulation
- **Hotbar** (`scripts/hotbar.gd`): Manages inventory UI and item selection

### File Structure

```
scripts/           - GDScript files for game logic
scenes/            - Scene files (.tscn)
models/            - 3D models organized by category (blocks, animals, enemies, items, tools)
materials/         - Material resources
meshes/            - Mesh resources for blocks
textures/          - Texture assets
shaders/           - Custom shaders (stylized sky, water effects)
resources/         - Mesh libraries and other resources
```

## Development Commands

This is a Godot project with no external build system. Development is done entirely within the Godot editor.

- **Run the game**: Open project in Godot editor and press F5 or click the play button
- **Export**: Use Godot's export system (Project > Export)

## Key Features

- **Block System**: Uses mesh library with various block types (dirt, stone, wood, etc.)
- **First-Person Controls**: WASD movement, mouse look, space to jump, shift to sprint
- **Inventory**: Q key toggles 2D inventory display, Tab shows hotbar
- **Visual Effects**: Particle systems for block creation/destruction
- **Dynamic Sky**: Custom stylized sky shader with day/night cycle

## Input Mapping

- Movement: WASD keys
- Look: Mouse movement
- Jump: Space
- Sprint: Left Shift
- Inventory: Q key
- Hotbar: Tab key
- Block interaction: Left/Right mouse clicks

## Technical Notes

- Uses Godot 4.4 with Forward+ renderer
- Target resolution: 1280x720
- Gravity: Uses project default physics settings
- All scripts follow MIT license
- Code includes proper signal disconnection and memory management

## Assets Attribution

- Based on tutorials by LegionGames
- Uses MIT-licensed FirstPersonController
- CC0-licensed Cube World Kit by Quaternius
- MIT-licensed Stylized Sky by GDQuest