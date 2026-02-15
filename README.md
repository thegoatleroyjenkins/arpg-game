# ARPG Game

A Godot 4 action RPG currently transitioning from 2D prototype systems to a 3D gameplay target (Project Emberfall).

## Current Direction

- **Target:** Full 3D ARPG experience
- **Status:** Existing 2D systems remain playable while 3D foundations are being built in parallel.
- **Prototype Scene:** `res://prototype3d/main_3d.tscn`
- **Data-driven 3D tuning:** `res://prototype3d/default_player_tuning_3d.tres`
- **Starter level scaffold:** `res://world/levels/starter_village_3d.tscn`
- **Starter level design spec:** `docs/STARTER_LEVEL_SPEC.md`
- **Starter level data pack:**
  - `data/levels/starter_village_layout.json`
  - `data/sql/starter_level_schema.sql`
  - `data/sql/starter_level_seed.sql`
- **Open-world design spec:** `docs/OPEN_WORLD_SPEC.md`
- **Open-world data + systems scaffold:**
  - `data/world/world_map_layout.json` (now includes explicit `chunks[]` grid indexing)
  - `data/sql/open_world_schema.sql`
  - `data/sql/open_world_seed.sql`
  - `systems/world/world_streamer.gd`
  - `systems/world/world_sector.gd`
  - `systems/world/spawn_director.gd`

## Current Features

### Player Systems
- **Movement** — WASD/Arrow key movement with directional facing
- **Camera-Relative Movement (3D prototype)** — Data-driven movement mapping now follows camera forward/right vectors (with a toggle in tuning), improving directional readability and future-proofing control feel for camera-driven combat spaces
- **Input Deadzone Remapping (3D prototype)** — Data-driven movement input deadzone now filters analog drift and remaps post-deadzone strength, preserving fine control without hardcoded stick thresholds
- **Sprint (3D prototype)** — Sprint now uses an input action (Shift / gamepad LB) for modular remapping and burst movement speed
- **Dedicated Jump Input (3D prototype)** — Jump now uses its own `jump` action (Space / gamepad A) with fallback support, improving control clarity and input modularity
- **Dash (3D prototype)** — Tap Q (or gamepad B) for a short directional dash with cooldown (data-driven tuning)
- **Dash Chain Fatigue (3D prototype)** — Data-driven dash-chain stamina scaling now increases dash cost when chaining dashes inside a short window, adding cleaner mobility tradeoffs without hardcoded limits
- **Stamina (3D prototype)** — Sprint, dash, and jump now consume stamina with configurable regen/delay for better combat pacing
- **Attack Stamina Gating (3D prototype)** — Light attacks now consume a data-driven stamina cost (`light_attack_stamina_cost`), reinforcing resource tradeoffs between mobility and offense while reusing existing low-stamina feedback
- **Damage-Type Multipliers (3D prototype)** — `CombatActor3D` now exposes per-type `damage_type_multipliers` (for resist/weakness tuning), and the modular damage resolver applies them data-driven after mitigation so enemies can express archetype identity without hardcoded branches
- **Forgiving Jump Timing (3D prototype)** — Data-driven coyote time + jump buffering make jumps more responsive and reliable in moment-to-moment combat movement
- **Weighted Movement Feel (3D prototype)** — Data-driven acceleration/deceleration + air control make movement feel less twitchy and more intentional
- **Variable Jump Height (3D prototype)** — Data-driven jump-release gravity and terminal fall speed improve aerial control and landing readability
- **Air Jump (3D prototype)** — Data-driven extra mid-air jump count enables cleaner vertical repositioning and more expressive traversal/combat routing
- **Air Jump Directional Boost (3D prototype)** — Data-driven airborne jump horizontal boost + speed cap now preserve forward momentum and recent movement intent, improving mid-air reposition control without hardcoded impulses
- **Air Jump Stamina Scaling (3D prototype)** — Data-driven airborne jump stamina multiplier now increases air-jump cost versus grounded jumps, improving vertical mobility tradeoff clarity
- **Jump Apex Hang Time (3D prototype)** — Data-driven apex gravity tuning softens gravity near jump peak for cleaner aerial control and better mid-air repositioning readability
- **Sprint Jump Momentum Carry (3D prototype)** — Data-driven sprint-jump momentum boost and speed cap preserve forward flow when jumping out of sprint, improving traversal/combat movement continuity without hardcoded values
- **Directional Turn Smoothing (3D prototype)** — Data-driven turn speed + movement threshold smooth facing changes so directional control feels weightier without sacrificing responsiveness
- **Stamina HUD (3D prototype)** — Modular UI layer now reads player stamina signal and displays live stamina values for clearer sprint/dash decision-making
- **HUD Readability Pass (3D prototype)** — The stamina/mobility HUD now renders over a translucent backdrop, uses stronger text outlines, and includes an in-HUD control hint strip for better legibility during movement-heavy moments
- **Low-Stamina Warning Pulse (3D prototype)** — Data-driven HUD warning ratio + pulse speed now drive a pulsing stamina alert when resources get critical, improving combat pacing readability
- **Low-Stamina Action Feedback (3D prototype)** — Data-driven warning timing/cooldown now surface short HUD alerts when jump or dash fails from low stamina, improving input clarity during high-pressure movement chains
- **Dash Cooldown HUD (3D prototype)** — Modular UI now also tracks dash cooldown state (ready vs remaining time) to improve ability timing readability
- **Buffered Dash Input (3D prototype)** — Press dash slightly before cooldown ends to queue it (data-driven timing window), making combat movement chains more responsive under pressure
- **Recent Input Dash Direction Memory (3D prototype)** — Data-driven dash direction memory now uses your most recent movement input for a short window when dashing from neutral, preserving intended reposition direction during stop-and-go combat movement
- **Camera-Forward Neutral Dash Fallback (3D prototype)** — Data-driven neutral dash fallback can now use camera forward when no movement input/recent input exists, preserving camera-framed reposition intent instead of forcing character-facing dashes
- **Dash Queue HUD Feedback (3D prototype)** — Modular HUD now surfaces buffered dash queue state and remaining queue time, improving readability for clutch mobility timing
- **Jump Queue HUD Feedback (3D prototype)** — Modular HUD now also surfaces jump input buffer state and remaining queue time from player signals, making coyote-time jump timing windows clearer during fast movement chains
- **Buffered Light Attack Input (3D prototype)** — Data-driven light-attack input buffering now queues attacks pressed slightly before cooldown ends, improving melee responsiveness under pressure; HUD now surfaces attack queue timing for clearer execution feedback
- **Light Attack Cooldown HUD Readout (3D prototype)** — Modular HUD now tracks light-attack cooldown remaining time via a dedicated bar + label driven by player signals, making melee re-engage windows clearer during fast movement/combat chains
- **Light Attack Lunge Commitment (3D prototype)** — Data-driven light-attack lunge tuning (`light_attack_lunge_enabled`, duration/speed/control blend) now adds a short forward commit toward the primary target on successful swings, improving melee impact/readability while keeping movement behavior modular
- **Light Attack Cleave Damage Falloff (3D prototype)** — Multi-target light attacks now apply data-driven per-target falloff with a configurable minimum floor (`light_attack_cleave_falloff_per_target`, `light_attack_cleave_min_multiplier`), preserving satisfying cleave while rewarding cleaner target focus
- **Light Attack Backstab Bonus (3D prototype)** — Data-driven positional melee tuning now grants bonus damage when attacking from behind a target (`light_attack_backstab_enabled`, `light_attack_backstab_dot_threshold`, `light_attack_backstab_damage_multiplier`), improving intentional positioning and build expression without hardcoded enemy branches
- **Contextual Stamina Regen (3D prototype)** — Stamina regeneration is now data-driven with separate idle vs moving rates, improving combat pacing and recovery decision-making
- **Stamina Regen Delay HUD (3D prototype)** — Modular HUD now surfaces stamina regen lockout remaining time and active state via player signals, improving readability of post-action resource recovery windows
- **Dash I-Frame HUD Readout (3D prototype)** — Modular HUD now tracks remaining dash invulnerability time via player signals, making defensive timing windows readable during high-pressure movement chains
- **Stamina Pickup Orbs (3D prototype)** — World pickup nodes now restore player stamina on contact and respawn on a timer, adding a readable, data-driven sustain loop to movement-heavy combat pacing
- **Stamina Pickup Anti-Waste Threshold (3D prototype)** — Data-driven minimum missing-stamina ratio now prevents collecting stamina orbs when nearly full, preserving resource pickups for intentional routing during combat movement
- **Low-Stamina Pickup Magnet (3D prototype)** — Data-driven stamina orb magnet radius/speed now gently pulls nearby orbs toward the player only when missing stamina crosses a tunable threshold, improving recovery readability during high-pressure movement chains
- **Pickup Magnet Line-of-Sight Gating (3D prototype)** — Data-driven line-of-sight toggle + collision mask now prevent stamina orbs from magnetizing through walls, preserving clearer spatial routing and pickup readability in denser arenas
- **Pickup Magnet Ease-In + Auto-Collect (3D prototype)** — Data-driven magnet minimum speed ratio, distance-based speed curve, and close-range auto-collect radius now make stamina orbs accelerate smoothly into the player instead of jittering near contact
- **Pickup Spawn Recovery Drift Correction (3D prototype)** — Data-driven return-to-spawn speed and snap distance now pull uncollected stamina orbs back toward their spawn anchor when magnet conditions are not met, keeping resource locations readable after failed pulls
- **Pickup Respawn Telegraphs (3D prototype)** — Data-driven pre-respawn telegraph timing + pulse/alpha tuning now make stamina orb re-entry visible before reactivation, improving resource timing readability during combat routing
- **Stamina Orbs Grant Dash Recovery (3D prototype)** — Data-driven stamina pickups can now shave configurable time off dash readiness when dash resources are missing, allowing intentional sustain-or-routing plays even when stamina is near full
- **Stamina Orbs Grant Dash Charge Recovery (3D prototype)** — Data-driven pickup profiles can now restore configurable dash charge counts using separate collection/magnet missing-charge thresholds, enabling stronger mobility-route planning without hardcoded orb behavior
- **Stamina Orbs Grant Air Jump Recovery (3D prototype)** — Data-driven stamina pickups can now restore configurable air-jump charges when missing-jump thresholds are met, improving vertical recovery routing without hardcoded pickup behavior
- **Stamina Orbs Grant Sprint Efficiency Burst (3D prototype)** — Data-driven pickups can now grant a temporary sprint efficiency buff (reduced sprint stamina drain) with modular HUD timing/multiplier feedback, enabling short reposition windows without hardcoded stamina discounts
- **Stamina Orbs Grant Momentum Burst (3D prototype)** — Data-driven pickups can now grant a temporary move-speed multiplier (duration + multiplier tuning) with modular HUD timing/multiplier feedback, enabling short commit-and-reposition windows without hardcoded movement overrides
- **Pickup Profile Sprint-Efficiency Authoring (3D prototype)** — `StaminaPickupProfile3D` now exposes sprint-efficiency duration/multiplier fields, so reusable pickup profiles can tune mobility-burst behavior without falling back to per-node defaults
- **Nearest-Need Pickup Magnet Targeting (3D prototype)** — Stamina orb magnet targeting now chooses the nearest player who currently needs stamina/dash/air-jump recovery (instead of first-in-group), improving co-op readiness while keeping pickup logic modular and threshold-driven
- **Stamina Orb Regen Surge Buff (3D prototype)** — Data-driven stamina pickups can now apply a temporary stamina regeneration multiplier (duration + multiplier tuning) with HUD readout, enabling cleaner sustain windows after resource pickups
- **Pickup Profile Resources (3D prototype)** — Stamina orb tuning can now be authored as reusable `StaminaPickupProfile3D` resources and assigned per node, keeping pickup behavior modular/data-driven while reducing scene-level stat duplication
- **Pickup Profile Visual Identity (3D prototype)** — Data-driven pickup profile visual tuning now controls orb albedo/emission color and glow strength, making different pickup profiles readable at a glance without hardcoded per-node materials
- **Contextual Pickup Need Tinting (3D prototype)** — Data-driven pickup profiles can now tint orb visuals by nearby player need (stamina vs dash vs air-jump, with mixed fallback + blend tuning), improving resource-routing readability during movement-heavy combat
- **Pickup Proximity Intensity Feedback (3D prototype)** — Data-driven proximity feedback now scales stamina orb size and glow as eligible players get closer, making high-value pickup moments more anticipatory and spatially readable during movement chains
- **Airborne Stamina Regen Tuning (3D prototype)** — Data-driven airborne stamina regen rate now decouples in-air recovery from grounded movement, making jump/dash chains a clearer resource tradeoff
- **Low-Stamina Movement Drag (3D prototype)** — Data-driven low-stamina movement threshold + minimum speed multiplier now add gentle fatigue drag when stamina is critically low, reinforcing resource pacing without hardcoded movement penalties
- **Camera Zoom (3D prototype)** — Mouse wheel zoom is now data-driven (min/max/step in tuning resource) so players can quickly adjust combat readability and spatial awareness
- **Mouse Orbit Camera (3D prototype)** — Data-driven camera orbit yaw/pitch (sensitivity, pitch clamp, invert-Y toggle) now lets players rotate the combat camera while keeping movement camera-relative and modular
- **Pause Menu Invert-Y Toggle (3D prototype)** — Pause settings now expose a live invert-Y camera option wired directly into player tuning, improving camera comfort/accessibility without hardcoded input branches
- **Hold-to-Recenter Camera (3D prototype)** — Data-driven camera recenter action (R by default) smoothly aligns orbit yaw behind player facing, reducing camera drift after heavy orbit usage while keeping controls modular
- **Camera Follow Assist (3D prototype)** — Data-driven follow-assist yaw gently realigns orbit behind movement direction while traversing, with tunable speed/min-move threshold and a post-mouse-look lockout window to preserve manual camera control
- **Dash-Aware Camera Follow Assist (3D prototype)** — Data-driven dash follow-assist multiplier now temporarily boosts follow-assist yaw speed during active dashes, improving burst-mobility framing and short-window camera readability without hardcoded behavior
- **Dynamic Camera FOV (3D prototype)** — Data-driven FOV kick scales with movement speed and dash state, adding stronger sensation of momentum without hardcoding camera behavior
- **Sprint Ramp Smoothing (3D prototype)** — Data-driven sprint ramp-up/ramp-down blends acceleration into and out of sprint for weightier, cleaner movement transitions
- **Sprint Exhaustion Gate (3D prototype)** — Data-driven stamina thresholds now gate sprint re-engage after exhaustion, preventing rapid on/off sprint jitter at near-zero stamina
- **Velocity Look-Ahead Camera (3D prototype)** — Data-driven camera look-ahead shifts focus toward movement direction based on speed, improving forward readability during traversal and combat repositioning
- **Camera Collision Avoidance (3D prototype)** — Data-driven camera raycast + collision padding now prevent hard clipping through level geometry, preserving player readability in tight spaces while keeping camera behavior modular and tunable
- **Camera Collision Layer Mask (3D prototype)** — Data-driven camera collision mask now controls which physics layers can push the camera, preventing jitter from non-blocking gameplay props while preserving modular tuning
- **Dash Charges (3D prototype)** — Data-driven multi-charge dash model (max charges + recharge time) adds tactical mobility pacing without hardcoding ability logic
- **Dash Charge Recharge HUD (3D prototype)** — Modular HUD now surfaces next-charge refill timing, improving dash resource planning in high-pressure movement chains
- **Charge-Bypass Dash Chaining (3D prototype)** — Data-driven toggle now allows available dash charges to bypass cooldown gating, enabling cleaner back-to-back reposition bursts while depleted charges still recover on timer
- **Dash Steering Control (3D prototype)** — Data-driven in-dash steering (control + responsiveness tuning) allows limited course correction for more skill-expressive repositioning
- **Dash Wall-Collision Cancel (3D prototype)** — Data-driven wall-impact detection now ends dash travel when colliding head-on with level geometry, preventing awkward wall-grind movement and improving close-quarters control readability
- **Dash Trail Afterimage VFX (3D prototype)** — Data-driven dash trail toggles/timing/alpha plus tunable trail color/emission now spawn short-lived afterimages during dashes, improving burst readability and visual identity without hardcoded scene effects
- **Dash Invulnerability Window (3D prototype)** — Data-driven dash i-frame duration now grants a short post-activation safety window, setting up cleaner combat integration without hardcoded timings
- **Dash I-Frame Character Flash (3D prototype)** — Data-driven dash readability tuning now adds a pulsing character flash during active i-frames, making defensive timing windows visible in-world (not just on HUD)
- **Air Jump HUD Readout (3D prototype)** — Modular HUD now shows remaining air jumps in real time, improving vertical mobility clarity during combat and traversal
- **Sprint State HUD (3D prototype)** — Modular HUD now surfaces Sprint Ready / Active / Exhausted states for clearer stamina pacing and sprint re-engage timing during combat movement
- **Hard Landing Recovery (3D prototype)** — Data-driven landing impact tuning adds a brief recovery after high-speed falls, making movement weightier and reducing bunny-hop style chaining
- **Impact-Scaled Landing Penalties (3D prototype)** — Data-driven landing penalty scaling now lerps recovery lockout, stamina loss, and camera impact based on fall speed severity (threshold → max penalty speed), preserving readability while rewarding cleaner landings
- **Hard Landing Stamina Penalty (3D prototype)** — Data-driven hard-landing stamina cost makes rough falls a meaningful mobility tradeoff and reinforces cleaner traversal/combat routing
- **Fall Recovery Safety Reset (3D prototype)** — Data-driven fall reset height now safely respawns the player at their start anchor with tunable stamina/recovery penalties, preventing softlocks from arena falls while preserving movement tradeoffs
- **Landing Recovery Dash Cancel Window (3D prototype)** — Data-driven late-recovery dash-cancel timing lets skilled players spend dash resources to recover from heavy landings faster without hardcoded behavior
- **Landing Recovery Dash Input Buffer (3D prototype)** — Data-driven recovery-buffer timing now queues dash input pressed shortly before landing recovery ends, improving movement responsiveness after hard landings without bypassing stamina/cooldown checks
- **Dash-to-Jump Input Buffer Assist (3D prototype)** — Data-driven dash jump-buffer bonus timing now preserves jump presses made near dash end, improving movement chain responsiveness without bypassing stamina or grounded/air-jump rules
- **Landing Recovery HUD (3D prototype)** — Modular HUD now tracks hard-landing recovery remaining time (data-driven duration), clarifying when movement lockout ends after heavy falls
- **Camera Impulse Feedback (3D prototype)** — Data-driven camera impulse kick now reacts to dashes and hard landings (with tunable decay/max offset), improving movement impact without hardcoded camera behavior
- **Air Dash Stamina Scaling (3D prototype)** — Data-driven airborne dash stamina multiplier now increases in-air dash cost versus grounded dashes, improving mobility tradeoff clarity in combat routing
- **Light Melee Combat Contract (3D prototype)** — Added a modular `DamageResolver` + `CombatActor3D` pipeline and wired player `attack` input through `request_damage()` against a prototype combat dummy, establishing a reusable data-driven damage path for future enemy/skill integration
- **Data-Driven Armor Penetration + Minimum Damage Floors (3D prototype)** — `DamageResolver` now supports optional payload fields (`armor_penetration_flat`, `armor_penetration_ratio`, `minimum_damage`, `minimum_damage_ratio`) so skills/items can shape mitigation outcomes without hardcoded per-skill combat math
- **Combat Dummy Damage Popups (3D prototype)** — Data-driven world-space damage popup tuning (`damage_popup_*`) now spawns rising/fading hit numbers over the combat dummy, improving impact readability while keeping combat feedback modular and script-configurable
- **Light Attack Cleave Targets (3D prototype)** — Data-driven light attack target count (`light_attack_max_targets`) now allows each swing to hit multiple nearby enemies in-arc (nearest-first), improving crowd-control readability while preserving modular combat-resolver flow
- **Critical Hit Camera Punch (3D prototype)** — Data-driven crit camera impulse tuning (`light_attack_crit_camera_impulse_strength`, `light_attack_crit_camera_impulse_vertical`) now listens to modular `DamageResolver` combat results and adds a short camera kick on player critical hits for stronger impact readability
- **Combat** — Real-time melee attacks with cooldowns and hit feedback
- **Health System** — Health bar with damage flash effects
- **Leveling** — XP gain, level-ups with stat increases

### Equipment System
- **3 Equipment Slots** — Weapon, Armor, Accessory
- **Equipment Types** — Various weapons, armor pieces, and accessories
- **Stat Modifiers** — Equipment affects damage, defense, and max health
- **Auto-Equip** — Walk over equipment to equip instantly

### Enemy AI
- **State Machine** — Idle, Chase, Attack, Retreat states
- **Enemy Types** — Grunt, Fast, Tank, Ranged, Bruiser, Assassin (varied stats and behaviors)
- **Smart Behavior** — Enemies detect player, chase when in range, attack when close
- **Visual Feedback** — Alert indicators when enemies spot player

### World
- **Procedural Spawning** — Random enemies and items throughout world
- **Item Drops** — Health potions and XP orbs
- **Equipment Drops** — Weapons, armor, and accessories spawn in world
- **Starter Level Zone Marker Query API (3D scaffold)** — `StarterLevelController` now builds a data-driven cache from JSON zone IDs to in-scene marker nodes, exposing modular lookup helpers for encounter systems (`get_zone_data`, `get_zone_marker_nodes`, `get_random_zone_marker`)
- **World Chunk Grid Index Streaming (3D scaffold)** — `WorldStreamer` now resolves loadable chunk IDs from explicit JSON `chunks[]` grid coordinates (`grid_x`,`grid_y`) instead of relying only on placeholder generated IDs, improving modular world-streaming correctness as layout data scales

## Download

Get the latest builds from [Releases](../../releases).

## Release Automation

This repo uses a single GitHub Action (`Build and Release ARPG`) that runs on **push to master/main**, **every hour**, and manual dispatch, and:
- Builds Windows + Linux exports
- Creates a GitHub Release with generated notes
- Auto-increments version tags in this format: `v0.0.02`, `v0.0.03`, ...
- Supports legacy previous version format `v0.0.0.1` (next becomes `v0.0.02`)
- Runs preflight checks (Godot binary, export presets, headless smoke test) to troubleshoot failures faster
- Bootstraps Godot export templates in CI to prevent missing-template export failures

You can also trigger it manually (with `gh` authenticated):

```bash
gh workflow run "Build and Release ARPG" --ref master
```

Optional manual overrides:
- `tag` (example: `v0.0.25`)
- `name` (example: `ARPG v0.0.25`)
- `prerelease` (`true`/`false`)

Optional: watch the run live

```bash
gh run watch
```

Release assets uploaded:
- `arpg-windows.zip`
- `arpg-linux.zip`

## Controls

| Key | Action |
|-----|--------|
| WASD / Arrows | Move |
| Space | Attack |
| Shift / Gamepad LB (in 3D prototype) | Sprint |
| Q / Gamepad B (in 3D prototype) | Dash |
| Space / Gamepad A (in 3D prototype) | Jump (press again in air for air jump) |
| Mouse Move (captured, in 3D prototype) | Orbit Camera |
| Mouse Wheel (in 3D prototype) | Camera Zoom In/Out |
| R (hold, in 3D prototype) | Recenter camera behind player facing |
| Esc (in 3D prototype) | Pause menu (camera sensitivity, invert-Y, HUD/mouse settings) |
| Walk over items | Pick up / Equip |

## Equipment

### Weapons
- **Iron Sword** — +10 damage
- **Steel Blade** — +20 damage
- **Flame Sword** — +35 damage, +10 health

### Armor
- **Leather Armor** — +10 defense, +20 health
- **Chain Mail** — +25 defense, +30 health
- **Dragon Plate** — +50 defense, +5 damage, +50 health

### Accessories
- **Ring of Health** — +40 health, +5 defense
- **Amulet of Power** — +15 damage, +10 health
- **Lucky Charm** — +5 damage, +5 defense, +25 health

## Development

Built with **Godot 4.6**

### Run from source:
```bash
godot --path .
```

### Run the 3D prototype scene directly:
```bash
godot --path . --scene res://prototype3d/main_3d.tscn
```

### Export builds:
```bash
# Windows
godot --export-release "Windows Desktop" build/windows/ARPG.exe

# Linux
godot --export-release "Linux/X11" build/linux/ARPG.x86_64
```

## Project Structure

```
arpg-game/
├── player.gd          # Player controller
├── enemy.gd           # Enemy base class
├── equipment.gd        # Equipment items
├── item.gd            # Consumable items
├── main.gd            # World generation
├── state_machine.gd   # AI state machine
├── *_state.gd         # Individual AI states
└── .github/workflows/ # Auto-build on push
```

## Recent Updates

- ✅ Added data-driven light-attack lunge commitment tuning (`light_attack_lunge_enabled`, `light_attack_lunge_duration`, `light_attack_lunge_speed`, `light_attack_lunge_control_multiplier`) so successful melee swings include a short target-aware forward commit for cleaner impact feel without hardcoded scene logic
- ✅ Added data-driven critical-hit camera punch tuning (`light_attack_crit_camera_impulse_strength`, `light_attack_crit_camera_impulse_vertical`) wired to modular `DamageResolver` results, so player crits now add a short directional camera kick for clearer high-impact melee feedback
- ✅ Added data-driven combat dummy damage popup tuning (`damage_popup_enabled`, `damage_popup_duration`, `damage_popup_rise_distance`, `damage_popup_color`) that spawns rising/fading world-space hit numbers, improving per-hit combat readability without hardcoded scene effects
- ✅ Added a modular combat-dummy world-space health readout with data-driven timing/color tuning (`health_label_visible_time_on_hit`, `health_label_color_*`, `health_label_show_when_full`) to improve 3D combat clarity while keeping feedback behavior script-configurable
- ✅ Added data-driven light-attack cleave targeting (`light_attack_max_targets`) so each swing can hit multiple nearest enemies in front arc without hardcoded scene logic, improving crowd-combat readability while keeping combat resolution modular
- ✅ Added data-driven sprint turn responsiveness tuning (`sprint_turn_speed_multiplier`) so sprinting carries intentional steering weight while preserving modular facing controls for non-sprint movement
- ✅ Added data-driven stamina pickup dash-charge recharge boost tuning (`dash_charge_recovery_boost_duration`, `dash_charge_recovery_boost_multiplier`) plus modular `apply_dash_charge_recovery_boost()` player API and HUD timer readout, so orb routing can temporarily accelerate dash charge refill windows without hardcoded scene logic
- ✅ Added data-driven stamina pickup dash-defense boost tuning (`dash_invulnerability_boost_duration`, `dash_invulnerability_boost_bonus_seconds`) plus modular `apply_dash_invulnerability_boost()` player API and HUD timer readout, so pickup routing can temporarily extend dash i-frames for higher-risk reposition windows without hardcoded scene logic
- ✅ Added data-driven stamina pickup dash-charge recovery tuning (`dash_charge_restore_count`, collect/magnet missing-dash-charge thresholds) plus modular `restore_dash_charges()` player API, so pickup profiles can refill missing dash charges for cleaner mobility-route planning without hardcoded scene logic
- ✅ Added data-driven dash-to-jump input buffer assist (`jump_buffer_dash_bonus_time`) so jump presses near dash end are preserved into the post-dash window, improving movement-chain responsiveness without bypassing stamina or jump eligibility checks
- ✅ Polished the 3D prototype UI readability: added a translucent HUD backdrop, stronger text outlining for mobility readouts, an in-HUD controls hint strip, and clearer pause-menu subtitle guidance so moment-to-moment movement information remains legible under action
- ✅ Added data-driven landing-recovery dash input buffering (`hard_landing_dash_input_buffer_window`) so dash presses just before recovery ends are queued and fired as soon as dash cancel rules allow, improving post-landing responsiveness without bypassing stamina/cooldown gating
- ✅ Added data-driven sprint-efficiency pickup profile tuning (`sprint_efficiency_boost_duration`, `sprint_efficiency_boost_multiplier`) to `StaminaPickupProfile3D`, so reusable orb profile resources can author mobility-burst behavior without scene-level hardcoding
- ✅ Added data-driven dash-aware camera follow-assist tuning (`camera_follow_assist_dash_multiplier`) so orbit yaw realigns faster during active dashes for clearer burst-mobility framing without hardcoded camera logic
- ✅ Promoted a new default playable open-world scene (`res://world/levels/open_world_3d.tscn`) with chunk-based terrain generation from `data/world/world_map_layout.json`, streaming hooks (`WorldStreamer`), and procedural prop population per chunk for immediate large-world traversal
- ✅ Extended the Phase-1 procedural asset pipeline with an auto-generated player placeholder mesh (`generated_assets/characters/player_knight.tscn`) so character blocking/readability can iterate without manual modeling
- ✅ Added a Phase-1 offline procedural asset pipeline (`tools/procedural_asset_generator.gd`) that auto-generates modular weapons, props, and pickup scenes into `res://generated_assets/`; usage is documented in `docs/PROCEDURAL_ASSET_PIPELINE.md`
- ✅ Added data-driven 3D dash trail visual identity tuning (`dash_trail_color`, `dash_trail_emission_energy`) so afterimage trail readability/style can be authored per tuning resource without hardcoded material values
- ✅ Polished the 2D HUD for readability: split stats and controls into dedicated translucent panels, upgraded the stat readout to BBCode-rich color-coded text, and added an explicit objective line (`Defeat N enemies`) for clearer moment-to-moment UX
- ✅ Added modular starter-level zone marker query helpers to `StarterLevelController` (`get_zone_data`, `get_zone_marker_nodes`, `get_random_zone_marker`) so encounter systems can consume JSON-authored zone IDs and scene marker nodes through a clean, data-driven API
- ✅ Added data-driven neutral dash direction fallback tuning (`dash_neutral_uses_camera_forward`) so neutral-input dashes can follow camera forward when no live/recent move input exists, preserving camera-framed reposition intent
- ✅ Added data-driven stamina pickup profile visual identity tuning (`visual_albedo_color`, `visual_emission_color`, `visual_emission_energy`) so different pickup profile types are readable in-world at a glance without hardcoded scene materials
- ✅ Updated stamina pickup magnet selection to target the nearest player who currently needs stamina/dash/air-jump recovery, improving multiplayer/co-op readiness while keeping the pickup decision flow modular and data-driven
- ✅ Added data-driven stamina pickup regen-surge tuning (`regen_boost_duration`, `regen_boost_multiplier`) plus modular `apply_stamina_regen_boost()` player API and HUD timer/multiplier readout, so pickup routing can create brief high-recovery sustain windows without hardcoded logic
- ✅ Added data-driven 3D camera follow-assist tuning (enable toggle, assist yaw speed, min movement speed, and mouse-look lockout duration) so camera orbit naturally recenters while moving without fighting manual orbit input
- ✅ Added data-driven stamina pickup air-jump recovery tuning (`air_jump_recovery_count`, collect/magnet missing-air-jump thresholds) plus modular `restore_air_jumps()` player API, so pickups can restore vertical mobility when needed without hardcoded scene logic
- ✅ Added data-driven 3D air-jump directional boost tuning (`air_jump_horizontal_boost`, `air_jump_horizontal_speed_cap`) so mid-air jumps carry movement intent and preserve cleaner aerial repositioning without hardcoded impulses
- ✅ Added data-driven 3D hold-to-recenter camera behavior (enable toggle, recenter speed, snap-angle threshold + `camera_recenter` input action) so players can quickly realign camera orbit behind facing direction after manual orbit adjustments
- ✅ Added data-driven 3D mouse orbit camera tuning (sensitivity, pitch clamp, invert-Y toggle) so players can steer combat framing while preserving modular camera-relative movement
- ✅ Added data-driven 3D camera collision layer mask tuning so camera occlusion checks can ignore non-blocking physics layers (like gameplay props/pickups), reducing unwanted camera jitter while preserving level readability
- ✅ Added data-driven stamina pickup anti-waste collect threshold (minimum missing-stamina ratio) so near-full players do not accidentally consume orbs, preserving intentional resource routing
- ✅ Added data-driven 3D stamina pickup respawn telegraph tuning (toggle + telegraph duration + pulse speed + alpha range) so depleted stamina orbs visibly pulse before becoming collectible again, improving pickup timing readability during movement-heavy combat routing
- ✅ Added data-driven stamina pickup spawn-recovery drift correction (return speed + snap distance) so uncollected orbs slide back toward their spawn anchors when magnet pull conditions fail, preserving pickup location readability
- ✅ Added data-driven stamina pickup magnet line-of-sight gating (toggle + collision mask + trace height offset) so pickup orbs no longer pull through walls, improving arena routing clarity and world-space readability
- ✅ Added data-driven 3D dash trail afterimage VFX tuning (enable toggle, spawn interval, lifetime, alpha fade) so dashes read with clearer burst direction and stronger movement impact
- ✅ Added data-driven 3D movement input deadzone remapping (tunable deadzone with normalized post-threshold scaling) to reduce gamepad drift while preserving low-tilt precision
- ✅ Added data-driven dash recent-input direction memory (toggle + memory window tuning) so neutral-position dashes can still follow your latest movement intent for cleaner stop-and-go repositioning
- ✅ Added data-driven low-stamina pickup magnet tuning (radius/speed/missing-stamina threshold) so nearby stamina orbs pull toward resource-starved players for cleaner recovery routing under pressure
- ✅ Added data-driven 3D camera-relative movement toggle (camera-forward/right mapping) so movement intent remains consistent with camera framing and is easier to tune per-scene
- ✅ Added equipment system (weapons, armor, accessories)
- ✅ Implemented enemy AI state machine
- ✅ Added enemy variety (Grunt, Fast, Tank, Ranged types)
- ✅ Auto-build releases for Windows
- ✅ Added data-driven 3D player tuning resource + Shift sprint in prototype
- ✅ Added data-driven 3D dash (Q) with duration/cooldown tuning
- ✅ Added data-driven 3D stamina system (sprint + dash costs, regen delay/rate)
- ✅ Added data-driven 3D jump feel tuning (coyote time + jump buffering)
- ✅ Added data-driven 3D movement smoothing (ground acceleration/deceleration + air control)
- ✅ Added data-driven 3D variable jump height (jump-release gravity multiplier + terminal fall speed)
- ✅ Added data-driven 3D jump apex hang-time tuning (apex gravity multiplier + vertical speed threshold) for cleaner aerial control near jump peak
- ✅ Added data-driven 3D directional turn smoothing (turn speed + minimum movement threshold)
- ✅ Added modular 3D stamina HUD wired to player stamina_changed signal for real-time stamina readability
- ✅ Added modular 3D dash cooldown HUD wired to player dash_cooldown_changed signal for clearer dash timing windows
- ✅ Added data-driven 3D camera zoom controls (mouse wheel) with min/max/step tuning for better combat readability and scene awareness
- ✅ Added data-driven dynamic camera FOV response (base/speed/dash/smoothing) to improve perceived movement and dash impact
- ✅ Added data-driven 3D dash input buffering so near-ready dash presses queue cleanly and fire as cooldown ends
- ✅ Added modular 3D dash queue HUD feedback (queue active vs empty + remaining queue time) wired to player dash-buffer signals for clearer clutch dash timing readability
- ✅ Added data-driven contextual stamina regeneration (separate idle vs moving regen rates) to improve mobility/resource pacing
- ✅ Added data-driven sprint ramp smoothing (separate ramp-up/ramp-down rates) for weightier transitions into and out of sprint movement
- ✅ Added data-driven sprint exhaustion gating (exhaustion/resume stamina thresholds) to prevent near-empty stamina sprint flicker and improve movement pacing readability
- ✅ Added data-driven velocity-based 3D camera look-ahead (distance + smoothing tuning) to improve forward visibility and movement readability
- ✅ Added data-driven 3D jump stamina cost to curb spam-jumping and strengthen stamina tradeoff decisions
- ✅ Added two new enemy archetypes: Bruiser (heavy pressure) and Assassin (high-speed threat)
- ✅ Switched 3D sprint to a dedicated input action and added gamepad bindings for sprint (LB) + dash (B) to improve controller support and input modularity
- ✅ Added a dedicated 3D jump input action (`jump`) with Space + gamepad A bindings and fallback support for cleaner, modular controls
- ✅ Added data-driven 3D air jump support (tunable max extra jumps) for better vertical combat/traversal expression without hardcoding movement rules
- ✅ Added data-driven 3D dash charge system (tunable max charges + recharge time) and HUD charge readout for clearer mobility resource planning
- ✅ Added modular 3D dash charge recharge HUD readout (next-charge refill timer) wired to a new player recharge signal for better dash resource planning under pressure
- ✅ Added data-driven dash charge cooldown bypass toggle so available charges can chain dashes without waiting on cooldown, improving burst repositioning while preserving timed charge recovery
- ✅ Added data-driven 3D dash steering control (tunable steer control + responsiveness) so dash routes allow limited skill-based course correction
- ✅ Added modular 3D air jump HUD readout wired to player air-jump state for clearer vertical reposition planning
- ✅ Added modular 3D sprint state HUD readout (Ready / Active / Exhausted) wired to player sprint-state signals for better stamina pacing readability
- ✅ Added data-driven 3D hard landing recovery tuning (fall-speed threshold + recovery duration) to improve movement weight and curb hyperactive landing chains
- ✅ Added data-driven 3D hard-landing stamina penalty tuning so heavy falls carry a meaningful stamina tradeoff and cleaner traversal discipline
- ✅ Added modular 3D landing recovery HUD readout (remaining time + ready state) wired to player landing-recovery signal for clearer post-landing movement lockout timing
- ✅ Added data-driven 3D hard-landing dash-cancel window tuning so late landing recovery can be skillfully canceled into dash for cleaner combat flow
- ✅ Updated landing recovery HUD messaging to explicitly show when dash-cancel timing is available
- ✅ Added data-driven 3D camera impulse feedback (dash + hard landing impulse, plus decay/max offset tuning) for clearer movement impact and stronger moment-to-moment game feel
- ✅ Added data-driven low-stamina HUD warning pulse (threshold ratio + pulse speed tuning) to make critical stamina states more readable during combat movement decisions
- ✅ Added data-driven low-stamina action failure feedback (warning duration + anti-spam cooldown tuning) so failed jump/dash inputs clearly message resource shortages during combat movement chains
- ✅ Added data-driven low-stamina movement drag (threshold ratio + minimum movement multiplier) so critical stamina states carry a clear movement pacing tradeoff
- ✅ Added modular 3D stamina regen-delay HUD readout (remaining lockout timer + regen-active state) wired to a new player regen-delay signal for clearer resource recovery timing after movement actions
- ✅ Added data-driven airborne stamina regeneration tuning (separate in-air regen rate) to keep aerial mobility chains as a meaningful stamina commitment
- ✅ Added data-driven sprint-jump momentum carry tuning (momentum multiplier + speed cap) so jumping out of sprint preserves cleaner forward flow without hardcoded movement boosts
- ✅ Added data-driven airborne dash stamina scaling (tunable airborne multiplier) so in-air dash chains carry a clearer stamina tradeoff than grounded repositioning
- ✅ Added data-driven impact-scaled hard-landing penalties (max penalty speed + min penalty multiplier) so recovery lockout, stamina cost, and landing camera impulse scale by fall severity instead of using a binary full-penalty landing model
- ✅ Added data-driven 3D dash invulnerability duration tuning plus modular HUD i-frame readout wired to a new player dash-invulnerability signal, improving defensive timing clarity and combat-system integration readiness
- ✅ Added data-driven 3D fall recovery safety reset (height + stamina/recovery penalties) so out-of-bounds falls respawn cleanly at the start anchor instead of risking softlocks
- ✅ Added data-driven airborne jump stamina scaling (tunable air-jump multiplier) so mid-air jump chains carry a clearer stamina tradeoff than grounded jumps
- ✅ Added modular 3D stamina pickup orb nodes (contact restore + timed respawn) and wired player-side stamina restoration API so arena routing can support deliberate resource recovery without hardcoded scene logic

## License

MIT
