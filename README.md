# ARPG Game

A Godot 4 action RPG currently transitioning from 2D prototype systems to a 3D gameplay target (Project Emberfall).

## Current Direction

- **Target:** Full 3D ARPG experience
- **Status:** Existing 2D systems remain playable while 3D foundations are being built in parallel.
- **Prototype Scene:** `res://prototype3d/main_3d.tscn`
- **Data-driven 3D tuning:** `res://prototype3d/default_player_tuning_3d.tres`

## Current Features

### Player Systems
- **Movement** — WASD/Arrow key movement with directional facing
- **Camera-Relative Movement (3D prototype)** — Data-driven movement mapping now follows camera forward/right vectors (with a toggle in tuning), improving directional readability and future-proofing control feel for camera-driven combat spaces
- **Sprint (3D prototype)** — Sprint now uses an input action (Shift / gamepad LB) for modular remapping and burst movement speed
- **Dedicated Jump Input (3D prototype)** — Jump now uses its own `jump` action (Space / gamepad A) with fallback support, improving control clarity and input modularity
- **Dash (3D prototype)** — Tap Q (or gamepad B) for a short directional dash with cooldown (data-driven tuning)
- **Stamina (3D prototype)** — Sprint, dash, and jump now consume stamina with configurable regen/delay for better combat pacing
- **Forgiving Jump Timing (3D prototype)** — Data-driven coyote time + jump buffering make jumps more responsive and reliable in moment-to-moment combat movement
- **Weighted Movement Feel (3D prototype)** — Data-driven acceleration/deceleration + air control make movement feel less twitchy and more intentional
- **Variable Jump Height (3D prototype)** — Data-driven jump-release gravity and terminal fall speed improve aerial control and landing readability
- **Air Jump (3D prototype)** — Data-driven extra mid-air jump count enables cleaner vertical repositioning and more expressive traversal/combat routing
- **Jump Apex Hang Time (3D prototype)** — Data-driven apex gravity tuning softens gravity near jump peak for cleaner aerial control and better mid-air repositioning readability
- **Sprint Jump Momentum Carry (3D prototype)** — Data-driven sprint-jump momentum boost and speed cap preserve forward flow when jumping out of sprint, improving traversal/combat movement continuity without hardcoded values
- **Directional Turn Smoothing (3D prototype)** — Data-driven turn speed + movement threshold smooth facing changes so directional control feels weightier without sacrificing responsiveness
- **Stamina HUD (3D prototype)** — Modular UI layer now reads player stamina signal and displays live stamina values for clearer sprint/dash decision-making
- **Low-Stamina Warning Pulse (3D prototype)** — Data-driven HUD warning ratio + pulse speed now drive a pulsing stamina alert when resources get critical, improving combat pacing readability
- **Low-Stamina Action Feedback (3D prototype)** — Data-driven warning timing/cooldown now surface short HUD alerts when jump or dash fails from low stamina, improving input clarity during high-pressure movement chains
- **Dash Cooldown HUD (3D prototype)** — Modular UI now also tracks dash cooldown state (ready vs remaining time) to improve ability timing readability
- **Buffered Dash Input (3D prototype)** — Press dash slightly before cooldown ends to queue it (data-driven timing window), making combat movement chains more responsive under pressure
- **Dash Queue HUD Feedback (3D prototype)** — Modular HUD now surfaces buffered dash queue state and remaining queue time, improving readability for clutch mobility timing
- **Contextual Stamina Regen (3D prototype)** — Stamina regeneration is now data-driven with separate idle vs moving rates, improving combat pacing and recovery decision-making
- **Stamina Regen Delay HUD (3D prototype)** — Modular HUD now surfaces stamina regen lockout remaining time and active state via player signals, improving readability of post-action resource recovery windows
- **Dash I-Frame HUD Readout (3D prototype)** — Modular HUD now tracks remaining dash invulnerability time via player signals, making defensive timing windows readable during high-pressure movement chains
- **Airborne Stamina Regen Tuning (3D prototype)** — Data-driven airborne stamina regen rate now decouples in-air recovery from grounded movement, making jump/dash chains a clearer resource tradeoff
- **Low-Stamina Movement Drag (3D prototype)** — Data-driven low-stamina movement threshold + minimum speed multiplier now add gentle fatigue drag when stamina is critically low, reinforcing resource pacing without hardcoded movement penalties
- **Camera Zoom (3D prototype)** — Mouse wheel zoom is now data-driven (min/max/step in tuning resource) so players can quickly adjust combat readability and spatial awareness
- **Dynamic Camera FOV (3D prototype)** — Data-driven FOV kick scales with movement speed and dash state, adding stronger sensation of momentum without hardcoding camera behavior
- **Sprint Ramp Smoothing (3D prototype)** — Data-driven sprint ramp-up/ramp-down blends acceleration into and out of sprint for weightier, cleaner movement transitions
- **Sprint Exhaustion Gate (3D prototype)** — Data-driven stamina thresholds now gate sprint re-engage after exhaustion, preventing rapid on/off sprint jitter at near-zero stamina
- **Velocity Look-Ahead Camera (3D prototype)** — Data-driven camera look-ahead shifts focus toward movement direction based on speed, improving forward readability during traversal and combat repositioning
- **Dash Charges (3D prototype)** — Data-driven multi-charge dash model (max charges + recharge time) adds tactical mobility pacing without hardcoding ability logic
- **Dash Charge Recharge HUD (3D prototype)** — Modular HUD now surfaces next-charge refill timing, improving dash resource planning in high-pressure movement chains
- **Charge-Bypass Dash Chaining (3D prototype)** — Data-driven toggle now allows available dash charges to bypass cooldown gating, enabling cleaner back-to-back reposition bursts while depleted charges still recover on timer
- **Dash Steering Control (3D prototype)** — Data-driven in-dash steering (control + responsiveness tuning) allows limited course correction for more skill-expressive repositioning
- **Dash Invulnerability Window (3D prototype)** — Data-driven dash i-frame duration now grants a short post-activation safety window, setting up cleaner combat integration without hardcoded timings
- **Air Jump HUD Readout (3D prototype)** — Modular HUD now shows remaining air jumps in real time, improving vertical mobility clarity during combat and traversal
- **Sprint State HUD (3D prototype)** — Modular HUD now surfaces Sprint Ready / Active / Exhausted states for clearer stamina pacing and sprint re-engage timing during combat movement
- **Hard Landing Recovery (3D prototype)** — Data-driven landing impact tuning adds a brief recovery after high-speed falls, making movement weightier and reducing bunny-hop style chaining
- **Impact-Scaled Landing Penalties (3D prototype)** — Data-driven landing penalty scaling now lerps recovery lockout, stamina loss, and camera impact based on fall speed severity (threshold → max penalty speed), preserving readability while rewarding cleaner landings
- **Hard Landing Stamina Penalty (3D prototype)** — Data-driven hard-landing stamina cost makes rough falls a meaningful mobility tradeoff and reinforces cleaner traversal/combat routing
- **Fall Recovery Safety Reset (3D prototype)** — Data-driven fall reset height now safely respawns the player at their start anchor with tunable stamina/recovery penalties, preventing softlocks from arena falls while preserving movement tradeoffs
- **Landing Recovery Dash Cancel Window (3D prototype)** — Data-driven late-recovery dash-cancel timing lets skilled players spend dash resources to recover from heavy landings faster without hardcoded behavior
- **Landing Recovery HUD (3D prototype)** — Modular HUD now tracks hard-landing recovery remaining time (data-driven duration), clarifying when movement lockout ends after heavy falls
- **Camera Impulse Feedback (3D prototype)** — Data-driven camera impulse kick now reacts to dashes and hard landings (with tunable decay/max offset), improving movement impact without hardcoded camera behavior
- **Air Dash Stamina Scaling (3D prototype)** — Data-driven airborne dash stamina multiplier now increases in-air dash cost versus grounded dashes, improving mobility tradeoff clarity in combat routing
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
| Mouse Wheel (in 3D prototype) | Camera Zoom In/Out |
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

## License

MIT
