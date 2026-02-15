# 3D Migration Roadmap

This project is now explicitly targeting a 3D ARPG.

## Goals
- Preserve the fast, readable combat feel.
- Keep loot/progression data-driven.
- Migrate in vertical slices so the game stays runnable.

## Current Slice (Completed)
- Added 3D prototype scene: `res://prototype3d/main_3d.tscn`
- Added basic 3D player controller: `res://prototype3d/player_3d.gd`

## Focused Planning Pass — 2026-02-15 02:31 (America/Chicago)

### Top 3 Priorities (ordered)
1. **3D Combat Vertical Slice (highest leverage)**
   - Add a reusable `CombatActor3D` + `Hitbox/Hurtbox` pipeline.
   - Keep deterministic damage resolution in one place (single source of truth).
   - Wire player basic attack into this pipeline with clear hit feedback.

2. **3D Enemy Navigation Foundation (open-world-ready baseline)**
   - Introduce `NavigationAgent3D`-driven enemy locomotion with explicit states (Idle/Chase/Attack/Leash).
   - Decouple AI decision logic from animation/FX so archetypes can scale without code duplication.
   - Add leash + return behavior to support large streaming zones.

3. **World Streaming/Chunk Architecture Spike**
   - Define world-sector contracts (load radius, spawn budgets, persistence boundaries).
   - Stand up a minimal `WorldStreamer` manager that can load/unload test chunks around the player.
   - Keep encounter spawning data-driven for future biome/endgame expansion.

### Immediate Next Implementation Task
**Implement Task 1 first:** build a minimal 3D combat slice in `prototype3d` by adding
- `systems/combat/combat_actor_3d.gd`
- `systems/combat/damage_resolver.gd`
- `prototype3d/weapons/player_melee_hitbox_3d.gd`
and integrate one basic player melee action in `prototype3d/player_3d.gd`.

### Why this order
Combat clarity and reliable damage contracts unblock enemy behaviors, loot affixes, and encounter scaling; world streaming can proceed in parallel once gameplay contracts are stable.

## Rules During Migration
- No fake complexity.
- Prefer clarity over temporary hacks.
- Keep systems modular and data-driven.
