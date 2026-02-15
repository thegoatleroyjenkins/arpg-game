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
- **Sprint (3D prototype)** — Sprint now uses an input action (Shift / gamepad LB) for modular remapping and burst movement speed
- **Dedicated Jump Input (3D prototype)** — Jump now uses its own `jump` action (Space / gamepad A) with fallback support, improving control clarity and input modularity
- **Dash (3D prototype)** — Tap Q (or gamepad B) for a short directional dash with cooldown (data-driven tuning)
- **Stamina (3D prototype)** — Sprint, dash, and jump now consume stamina with configurable regen/delay for better combat pacing
- **Forgiving Jump Timing (3D prototype)** — Data-driven coyote time + jump buffering make jumps more responsive and reliable in moment-to-moment combat movement
- **Weighted Movement Feel (3D prototype)** — Data-driven acceleration/deceleration + air control make movement feel less twitchy and more intentional
- **Variable Jump Height (3D prototype)** — Data-driven jump-release gravity and terminal fall speed improve aerial control and landing readability
- **Directional Turn Smoothing (3D prototype)** — Data-driven turn speed + movement threshold smooth facing changes so directional control feels weightier without sacrificing responsiveness
- **Stamina HUD (3D prototype)** — Modular UI layer now reads player stamina signal and displays live stamina values for clearer sprint/dash decision-making
- **Dash Cooldown HUD (3D prototype)** — Modular UI now also tracks dash cooldown state (ready vs remaining time) to improve ability timing readability
- **Buffered Dash Input (3D prototype)** — Press dash slightly before cooldown ends to queue it (data-driven timing window), making combat movement chains more responsive under pressure
- **Contextual Stamina Regen (3D prototype)** — Stamina regeneration is now data-driven with separate idle vs moving rates, improving combat pacing and recovery decision-making
- **Camera Zoom (3D prototype)** — Mouse wheel zoom is now data-driven (min/max/step in tuning resource) so players can quickly adjust combat readability and spatial awareness
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
| Space / Gamepad A (in 3D prototype) | Jump |
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
- ✅ Added data-driven 3D directional turn smoothing (turn speed + minimum movement threshold)
- ✅ Added modular 3D stamina HUD wired to player stamina_changed signal for real-time stamina readability
- ✅ Added modular 3D dash cooldown HUD wired to player dash_cooldown_changed signal for clearer dash timing windows
- ✅ Added data-driven 3D camera zoom controls (mouse wheel) with min/max/step tuning for better combat readability and scene awareness
- ✅ Added data-driven 3D dash input buffering so near-ready dash presses queue cleanly and fire as cooldown ends
- ✅ Added data-driven contextual stamina regeneration (separate idle vs moving regen rates) to improve mobility/resource pacing
- ✅ Added data-driven 3D jump stamina cost to curb spam-jumping and strengthen stamina tradeoff decisions
- ✅ Added two new enemy archetypes: Bruiser (heavy pressure) and Assassin (high-speed threat)
- ✅ Switched 3D sprint to a dedicated input action and added gamepad bindings for sprint (LB) + dash (B) to improve controller support and input modularity
- ✅ Added a dedicated 3D jump input action (`jump`) with Space + gamepad A bindings and fallback support for cleaner, modular controls

## License

MIT
