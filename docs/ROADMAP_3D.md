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

## Focused Planning Pass — 2026-02-15 05:33 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Deliver a playable 3D combat loop (player attack -> enemy hit -> death) through one combat pipeline**
   - Add `CombatActor3D` + `DamageResolver` in `res://systems/combat/` and make them the only damage path.
   - Introduce a tiny `Hitbox3D`/attack event contract so attacks emit payloads instead of mutating health directly.
   - Validate with one measurable loop in `main_3d.tscn`: enemy can be killed, death signal fires, and loop is repeatable.

2. **Add one NavMesh-ready enemy slice that uses combat contracts, not prototype shortcuts**
   - Create `EnemyActor3D` + `EnemyBrain3D` (Idle/Chase/Attack/Leash) with `NavigationAgent3D` movement.
   - Use a tuning resource (`EnemyArchetype3D.tres`) for speed/range/cooldown so scaling stays data-driven.
   - Ensure enemy attacks also call `DamageResolver` to keep player/enemy parity for future balance tooling.

3. **Lay minimal open-world architecture rails before expanding content**
   - Define lightweight interfaces for `WorldSector`, `WorldStreamer`, and `SpawnDirector` under `res://systems/world/`.
   - Start with sector activation radius, unload distance hysteresis, and spawn budget caps.
   - Keep sector/spawn configuration in resources to support biome and endgame modifier layering later.

### Immediate Next Implementation Task
**Implement now:** create `res://systems/combat/damage_resolver.gd` + `res://systems/combat/combat_actor_3d.gd`, then wire a basic player light attack event in `player_3d.gd` through `request_damage()` (no direct HP writes).

### Why this order
The repo is currently movement-heavy; a real combat contract is the highest-leverage step to unlock AI, loot, progression, and open-world scaling without rework.

## Focused Planning Pass — 2026-02-15 06:34 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Convert prototype combat into a reusable 3D encounter slice (done once, reused everywhere)**
   - Add `res://systems/combat/damage_resolver.gd` + `combat_actor_3d.gd` as the only HP mutation path.
   - Create a tiny `AttackEvent3D` payload contract (`source`, `target`, `base_damage`, `damage_type`, `tags`, `poise_damage`) so player/enemy/skills all speak one format.
   - Wire one player melee and one enemy melee through resolver events to validate parity.

2. **Stand up open-world-safe AI movement contracts before adding more enemies**
   - Build `EnemyBrain3D` around `NavigationAgent3D` with explicit states (Idle/Chase/Attack/Leash).
   - Keep behavior knobs in resource data (`EnemyArchetype3D.tres`) so biome variants and elites are data-only additions.
   - Add leash + home-anchor rules now to prevent future streaming/sector edge bugs.

3. **Lay first world-streaming rails with strict boundaries**
   - Define `WorldSector`, `WorldStreamer`, and `SpawnDirector` interfaces under `res://systems/world/`.
   - Implement minimal load/unload radius + hysteresis and per-sector spawn budget caps.
   - Keep sector definitions in `.tres` resources so the open world can scale without scene rewrites.

### Immediate Next Implementation Task
**Implement now:** create `res://systems/combat/damage_resolver.gd` and `res://systems/combat/combat_actor_3d.gd`, then route one player light attack in `prototype3d/player_3d.gd` through `request_damage()` (no direct health writes).

### Why this order
Right now the project has strong movement feel but no durable combat/world contracts. Locking combat + Nav-ready AI + sector interfaces in this order gives the fastest path to a full 3D ARPG while staying open-world-ready.

## Focused Planning Pass — 2026-02-15 07:34 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Implement the combat foundation as an engine-level contract (highest leverage)**
   - Create `res://systems/combat/damage_resolver.gd` and `res://systems/combat/combat_actor_3d.gd`.
   - Enforce one damage entry point (`request_damage`) and one apply path (no direct health mutation in gameplay scripts).
   - Define a minimal `AttackEvent3D` payload now (`source`, `target`, `base_damage`, `damage_type`, `tags`, `poise_damage`) to keep loot/skills extensible.

2. **Deliver one complete 3D combat encounter slice using NavMesh-ready AI**
   - Add a prototype `EnemyActor3D` + `EnemyBrain3D` with `NavigationAgent3D` states: Idle/Chase/Attack/Leash.
   - Route enemy attacks through the same resolver to guarantee player/enemy combat parity.
   - Validate the full loop in `prototype3d/main_3d.tscn`: engage, exchange hits, death signal, respawn/retry.

3. **Add world-streaming scaffolding before open-world content expansion**
   - Define `WorldSector`, `WorldStreamer`, and `SpawnDirector` interfaces under `res://systems/world/`.
   - Start with sector activation radius, unload hysteresis, and per-sector spawn budgets.
   - Keep sector/spawn configs resource-driven (`.tres`) so biome and endgame layering is data-only.

### Immediate Next Implementation Task
**Implement now:** scaffold `res://systems/combat/` with `damage_resolver.gd` and `combat_actor_3d.gd`, then wire one light melee action in `prototype3d/player_3d.gd` to call `request_damage()` instead of directly mutating target health.

### Why this order
The repo is still prototype-heavy; locking a reusable combat contract first unlocks AI, progression, loot scaling, and streamed open-world systems with minimal rework.

## Focused Planning Pass — 2026-02-15 08:48 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Build the first combat-capable 3D vertical slice (highest leverage now)**
   - Add `res://systems/combat/damage_resolver.gd` and `combat_actor_3d.gd`.
   - Route all damage through a single request/apply path.
   - Validate one loop in `prototype3d/main_3d.tscn`: player hit -> enemy HP loss -> death event.

2. **Introduce one NavMesh enemy that uses the same combat contract**
   - Create `EnemyActor3D` + `EnemyBrain3D` (Idle/Chase/Attack/Leash) with `NavigationAgent3D`.
   - Move tuning values into a resource (speed/range/cooldowns) for data-driven scaling.
   - Ensure enemy attacks call the resolver (no direct HP writes).

3. **Harden open-world scaffolding already started under `systems/world/`**
   - Expand `WorldSector`, `WorldStreamer`, and `SpawnDirector` from stubs into runnable contracts.
   - Add activation/unload hysteresis, spawn budgets, and sector lifecycle signals.
   - Define `.tres` sector config format so content can scale without scene rewrites.

### Immediate Next Implementation Task
**Implement now:** create `res://systems/combat/damage_resolver.gd` + `res://systems/combat/combat_actor_3d.gd`, then wire `prototype3d/player_3d.gd` to issue a basic light-attack `request_damage()` event.

### Why this order
The project already has movement feel and initial world-streaming stubs; a real combat contract is the blocking dependency for enemy AI, progression balancing, and open-world encounter scalability.

## Focused Planning Pass — 2026-02-15 09:02 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Ship the first true 3D combat loop in-engine (player + enemy + death) this pass**
   - Create `res://systems/combat/damage_resolver.gd` and `combat_actor_3d.gd` and treat them as the only HP mutation path.
   - Add a minimal attack payload contract (`source`, `target`, `base_damage`, `damage_type`, `tags`) so skills/loot can scale without rewrites.
   - Validate in `prototype3d/main_3d.tscn`: player can damage enemy, enemy can damage player, death signal fires.

2. **Replace placeholder enemy behavior with NavMesh-ready combat AI**
   - Implement one `EnemyBrain3D` state loop (Idle/Chase/Attack/Leash) driven by `NavigationAgent3D`.
   - Move enemy tuning values (move speed, aggro range, attack cooldown) into a resource for data-driven scaling.
   - Route enemy attacks through the same resolver contract to keep parity with player combat.

3. **Turn world streaming stubs into open-world-ready lifecycle hooks**
   - Extend `WorldSector` + `WorldStreamer` + `SpawnDirector` with explicit load/activate/deactivate/unload signals.
   - Add per-chunk spawn budget caps + cooldowns so encounters stay deterministic under streaming.
   - Keep chunk/biome metadata in resource/data files; avoid embedding progression logic in scene scripts.

### Immediate Next Implementation Task
**Implement now:** scaffold `res://systems/combat/` with `damage_resolver.gd` and `combat_actor_3d.gd`, then wire one light attack in `prototype3d/player_3d.gd` and one enemy attack call to `request_damage()`.

### Why this order
Combat is still the highest-risk missing contract. Locking it first unlocks AI encounter tuning and prevents costly rework when streamed open-world combat density increases.

## Focused Planning Pass — 2026-02-15 11:31 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Replace the combat dummy with a real NavMesh enemy encounter slice**
   - Implement `EnemyActor3D` + `EnemyBrain3D` (Idle/Chase/Attack/Leash) using `NavigationAgent3D`.
   - Route enemy attack payloads through `DamageResolver.request_damage()` only.
   - Validate bidirectional combat loop in `prototype3d/main_3d.tscn` (player↔enemy, death/retry).

2. **Connect world streaming to actual sector lifecycle + spawn flow**
   - Wire `WorldStreamer` load/unload signals into `WorldSector` activation/deactivation.
   - Hook `SpawnDirector` into chunk load events with per-chunk spawn budgets.
   - Keep chunk/biome configuration in data files so expansion is data-only.

3. **Lock progression-facing data contracts before content expansion**
   - Define first resources for `EnemyArchetype3D`, `SkillData`, and `AffixData` with stable fields.
   - Add lightweight adapters so combat reads resource data, not hardcoded constants.
   - Add simple combat breakdown debug output to preserve clarity while tuning.

### Immediate Next Implementation Task
**Implement now:** add `prototype3d/enemy_brain_3d.gd` + `prototype3d/enemy_actor_3d.gd` and replace `CombatDummy` in `main_3d.tscn` with one `NavigationAgent3D`-driven enemy that can chase and execute one resolver-based melee attack.

### Why this order
The core resolver now exists; the highest-leverage move is proving a full encounter loop, then binding it to streaming/spawn architecture so open-world scaling can happen without refactors.

## Focused Planning Pass — 2026-02-15 11:48 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Replace the stationary combat dummy with a true NavMesh enemy encounter**
   - Add `prototype3d/enemy_actor_3d.gd` + `prototype3d/enemy_brain_3d.gd` with states (Idle/Chase/Attack/Leash).
   - Use `NavigationAgent3D` and keep attack execution routed through `DamageResolver.request_damage()`.
   - Validate one repeatable combat loop in `prototype3d/main_3d.tscn`: enemy pursues, attacks, can die, and cleanly resets.

2. **Wire world-streaming scaffolding into scene lifecycle (from stubs to behavior)**
   - Instantiate `WorldStreamer` + `WorldSector` in the 3D prototype and connect load/unload signals.
   - Hook `SpawnDirector.request_wilderness_wave()` on chunk activation with strict per-chunk spawn caps.
   - Keep all chunk metadata in `res://data/world/world_map_layout.json` so scaling stays data-first.

3. **Lock first progression data contracts used by combat and spawning**
   - Define minimal resource/data schemas for `EnemyArchetype3D`, `SkillData`, and `AffixData`.
   - Introduce adapter reads in combat/spawn systems so tuning moves out of hardcoded script constants.
   - Add a lightweight debug combat breakdown line for clarity while balancing.

### Immediate Next Implementation Task
**Implement now:** create `prototype3d/enemy_actor_3d.gd` and `prototype3d/enemy_brain_3d.gd`, then replace `CombatDummy` in `prototype3d/main_3d.tscn` with one `NavigationAgent3D`-driven enemy that performs resolver-based melee.

### Why this order
The project now has core combat and world streaming stubs; the highest-value step is proving a full moving encounter slice, then binding it to chunk lifecycle so open-world scale-up is data-driven instead of rewrite-heavy.

## Focused Planning Pass — 2026-02-15 11:49 (America/Chicago)

### Top 3 Priorities (ordered)
1. **Finish one production-style 3D enemy encounter loop (not a prototype placeholder)**
   - Land `enemy_actor_3d.gd` + `enemy_brain_3d.gd` with Idle/Chase/Attack/Leash using `NavigationAgent3D`.
   - Keep all attack resolution on `DamageResolver.request_damage()` (no direct HP writes).
   - Verify reset/retry behavior so this becomes the template encounter for future biomes.

2. **Bind streaming events to encounter spawning for open-world behavior**
   - Connect `WorldStreamer` chunk activation/deactivation signals to `WorldSector` + `SpawnDirector`.
   - Enforce per-chunk active-enemy caps and despawn-on-unload behavior.
   - Keep spawn definitions in data so scaling up to many chunks is additive, not rewrite-heavy.

3. **Stabilize data contracts for progression-facing combat tuning**
   - Define first-pass `EnemyArchetype3D`, `SkillData`, and `AffixData` resources with minimal required fields.
   - Route combat/spawn tuning reads through adapters to remove hardcoded constants from scene scripts.
   - Add one lightweight combat breakdown debug line to preserve tuning clarity.

### Immediate Next Implementation Task
**Implement now:** replace `CombatDummy` in `prototype3d/main_3d.tscn` with a `NavigationAgent3D`-driven enemy (`enemy_actor_3d.gd` + `enemy_brain_3d.gd`) that chases and performs one resolver-based melee attack.

### Why this order
This proves the first reusable combat encounter slice, then anchors it to streaming lifecycle so the architecture remains viable as world size and encounter density grow.
