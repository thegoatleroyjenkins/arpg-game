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

## Focused Planning Pass — 2026-02-15 03:01 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Implement a single 3D combat pipeline (foundation first)**
   - Add `CombatActor3D`, `Hitbox3D`, `Hurtbox3D`, and `DamageResolver` under `res://systems/combat/`.
   - Ensure all damage events route through one resolver for deterministic balancing, affixes, and future multiplayer-safe simulation.
   - Keep attack metadata data-driven (base damage, tags, impulse, stamina cost).

2. **Build navigation-based enemy runtime for scalable encounters**
   - Create `EnemyActor3D` + `EnemyBrain3D` split (decision layer vs movement/animation layer).
   - Use `NavigationAgent3D` with explicit states: Idle / Investigate / Chase / Attack / Leash / Return.
   - Add leash and timeout rules now so enemies behave correctly across future streamed world sectors.

3. **Define open-world sector contracts before content expansion**
   - Introduce `WorldSector`, `WorldStreamer`, and `SpawnDirector` interfaces under `res://systems/world/`.
   - Specify activation radius, load budget, despawn/persistence rules, and handoff points for AI + loot systems.
   - Keep sector definitions in TRES/JSON for biome reuse and endgame modifier injection.

### Immediate Next Implementation Task
**Do this next:**
- Implement `res://systems/combat/damage_resolver.gd` and `res://systems/combat/combat_actor_3d.gd`.
- Add `res://prototype3d/weapons/player_melee_hitbox_3d.gd`.
- Wire one light melee action in `player_3d.gd` through `DamageResolver` (no direct HP mutation outside resolver).

### Why this order
A clean combat contract prevents rewrites when AI scaling, affix math, and streamed-world encounters are introduced.

## Rules During Migration
- No fake complexity.
- Prefer clear contracts over temporary hacks.
- Keep systems modular and data-driven.
