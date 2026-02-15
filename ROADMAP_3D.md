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

## Focused Planning Pass — 2026-02-15 03:16 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Lock in the 3D combat contract (single source of truth)**
   - Implement `CombatActor3D` and `DamageResolver` under `res://systems/combat/`.
   - Route every outgoing hit through one resolver event (`request_damage`) and one apply path (`apply_damage_result`).
   - Keep payloads data-driven (`damage_type`, `base_damage`, `tags`, `stamina_cost`, `poise_damage`) so loot/skills can extend without rewrites.

2. **Ship one vertical-slice enemy using NavAgent + combat hooks**
   - Add `EnemyActor3D` + `EnemyBrain3D` with explicit states (Idle / Chase / Attack / Return).
   - Use `NavigationAgent3D` now (no direct move-to-target hacks) to stay compatible with streamed world sectors.
   - Connect enemy attacks to the same `DamageResolver` used by player attacks.

3. **Create minimal world streaming interfaces before map scale-up**
   - Define `WorldSector`, `WorldStreamer`, and `SpawnDirector` interfaces in `res://systems/world/`.
   - Start with simple activation/deactivation + spawn budget settings.
   - Store sector config in resources (`.tres`) so biomes and endgame modifiers can layer in later.

### Immediate Next Implementation Task
**Do this next:**
- Create `res://systems/combat/damage_resolver.gd` with a tiny request/resolve/apply pipeline.
- Create `res://systems/combat/combat_actor_3d.gd` (health, armor placeholder, receive damage API).
- Wire one light melee in `player_3d.gd` to call `DamageResolver` instead of mutating health directly.

### Why this order
A stable combat contract first prevents expensive rewrites when enemy scaling, affix systems, and streamed open-world sectors arrive.

## Rules During Migration
- No fake complexity.
- Prefer clear contracts over temporary hacks.
- Keep systems modular and data-driven.

## Focused Planning Pass — 2026-02-15 03:32 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Stand up a reusable 3D combat core now**
   - Add `res://systems/combat/damage_resolver.gd` and `res://systems/combat/combat_actor_3d.gd`.
   - Define one request path (`request_damage`) and one application path (`apply_damage_result`) for both player and enemies.
   - Keep payload fields future-proof (`damage_type`, `base_damage`, `crit`, `tags`, `poise_damage`, `source_id`).

2. **Add one NavMesh-driven enemy in the 3D slice**
   - Create `EnemyActor3D` + `EnemyBrain3D` (Idle/Chase/Attack/Leash) in `res://prototype3d/` or `res://systems/ai/`.
   - Use `NavigationAgent3D` movement and trigger attacks through `DamageResolver` only.
   - Keep behavior data-driven via a tunable resource for speed/ranges/cooldowns.

3. **Define open-world-ready world streaming interfaces before content scale-up**
   - Add lightweight contracts for `WorldSector`, `WorldStreamer`, and `SpawnDirector` under `res://systems/world/`.
   - Start with sector activation radius + spawn budget caps (no full procedural generation yet).
   - Store sector and spawn settings in resources so biome/endgame layering stays modular.

### Immediate Next Implementation Task
**Implement first:** create `res://systems/combat/damage_resolver.gd` with a minimal request→resolve→apply pipeline, then hook one player light attack call in `player_3d.gd` to that resolver.

### Why this order
A stable combat contract first avoids churn across AI, loot scaling, and streamed world systems as the project expands toward open-world scope.

## Focused Planning Pass — 2026-02-15 04:32 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Build a reusable 3D combat encounter slice (player + one enemy + resolver)**
   - Finish `res://systems/combat/damage_resolver.gd` and `combat_actor_3d.gd` as the only damage path.
   - Add `EnemyActor3D` wired into the same resolver (no direct HP mutation in actor scripts).
   - Validate one full loop: player light attack, enemy attack, hit reactions, death event.

2. **Create open-world-safe world partition contracts before adding more content**
   - Add `WorldSector`, `WorldStreamer`, and `SpawnDirector` stubs under `res://systems/world/`.
   - Support sector load/unload callbacks and per-sector spawn budgets.
   - Keep settings resource-driven (`.tres`) so biome and endgame modifiers can plug in later.

3. **Stabilize data boundaries for progression systems (skills/loot/enemy scaling)**
   - Define minimal schemas for `SkillData`, `AffixData`, and `EnemyArchetypeData` resources.
   - Ensure combat reads these through adapters, not hardcoded constants.
   - Add a simple debug overlay readout for final damage contributors to protect combat clarity.

### Immediate Next Implementation Task
**Implement now:** create `res://systems/combat/damage_resolver.gd` + `res://systems/combat/combat_actor_3d.gd`, then wire one player light attack and one prototype enemy attack through `request_damage()`.

### Why this order
A single combat contract + early world streaming interfaces prevents architecture churn and keeps the project aligned with a full 3D, open-world-ready ARPG trajectory.
