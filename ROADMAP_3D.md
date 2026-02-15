# 3D Migration Roadmap

This project is now explicitly targeting a full 3D ARPG with an open-world-ready architecture.

## Goals
- Preserve weighty, readable combat.
- Keep progression and combat data-driven.
- Build in vertical slices while keeping the project runnable.

## Current Slice (Completed)
- Added 3D prototype scene: `res://prototype3d/main_3d.tscn`
- Added 3D player controller + tuning resource (`player_3d.gd`, `default_player_tuning_3d.tres`)
- Added sprint/dash/stamina/jump-feel and basic 3D HUD telemetry

## Focused Planning Pass — 2026-02-15 02:46 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Ship a minimal 3D combat contract (highest leverage)**
   - Create reusable 3D combat primitives (`CombatActor3D`, `Hitbox3D`, `Hurtbox3D`, `DamageResolver`).
   - Route all damage through one resolver to keep deterministic, testable behavior.
   - Add simple hit confirmation (flash + knockback impulse hook).

2. **Stand up navigation-ready enemy runtime for large zones**
   - Add `EnemyActor3D` using `NavigationAgent3D` with explicit state boundaries (Idle/Chase/Attack/Leash/Return).
   - Separate behavior decisions from animation/VFX so archetypes scale without copy-paste logic.
   - Add leash/return limits to prevent far-away pursuit across future streamed sectors.

3. **Define world-sector streaming interfaces before content scale-up**
   - Add `WorldStreamer` + `WorldSector` contracts (load radius, activation budget, persistence boundary).
   - Support player-driven load/unload around current sector for open-world migration.
   - Keep sector spawn definitions data-driven (JSON/TRES) for biome/endgame reuse.

### Immediate Next Implementation Task
**Implement Priority #1 now:**
- Add `res://systems/combat/damage_resolver.gd`
- Add `res://systems/combat/combat_actor_3d.gd`
- Add `res://prototype3d/weapons/player_melee_hitbox_3d.gd`
- Wire one basic melee attack action from `player_3d.gd` into the resolver path

### Why this order
A stable 3D combat contract unlocks enemy AI, affix scaling, and sector encounter logic without rework.

## Rules During Migration
- No fake complexity.
- Prefer clear contracts over temporary hacks.
- Keep systems modular and data-driven.
