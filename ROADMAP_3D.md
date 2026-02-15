# 3D Migration Roadmap

This project is now explicitly targeting a 3D ARPG.

## Goals
- Preserve the fast, readable combat feel.
- Keep loot/progression data-driven.
- Migrate in vertical slices so the game stays runnable.

## Current Slice (Completed)
- Added 3D prototype scene: `res://prototype3d/main_3d.tscn`
- Added basic 3D player controller: `res://prototype3d/player_3d.gd`

## Next Slices
1. **3D Combat Core**
   - Melee hit volumes in 3D
   - Damage pipeline parity with current 2D systems
2. **3D Enemy Foundation**
   - Nav + chase/attack states for one enemy archetype
3. **3D Loot Loop**
   - Item drops + pickup + equip in 3D world
4. **UI Pass**
   - Preserve stat clarity and build readability
5. **Content Expansion**
   - More enemy archetypes, skills, and equipment bases

## Rules During Migration
- No fake complexity.
- Prefer clarity over temporary hacks.
- Keep systems modular and data-driven.
