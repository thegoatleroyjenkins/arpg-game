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
- **Sprint (3D prototype)** — Hold Shift for burst movement speed in the 3D scene
- **Dash (3D prototype)** — Tap Q for a short directional dash with cooldown (data-driven tuning)
- **Stamina (3D prototype)** — Sprint and dash now consume stamina with configurable regen/delay for better combat pacing
- **Forgiving Jump Timing (3D prototype)** — Data-driven coyote time + jump buffering make jumps more responsive and reliable in moment-to-moment combat movement
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

This repo uses a single GitHub Action (`Build + Release ARPG`) that now runs **every hour** and:
- Builds Windows + Linux exports
- Creates a GitHub Release with generated notes
- Auto-increments version tags in this format: `v0.0.02`, `v0.0.03`, ...
- Supports legacy previous version format `v0.0.0.1` (next becomes `v0.0.02`)
- Runs preflight checks (Godot binary, export presets, headless smoke test) to troubleshoot failures faster

You can also trigger it manually (with `gh` authenticated):

```bash
gh workflow run "Build + Release ARPG" --ref master
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
| Shift (in 3D prototype) | Sprint |
| Q (in 3D prototype) | Dash |
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

Built with **Godot 4.2**

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
- ✅ Added two new enemy archetypes: Bruiser (heavy pressure) and Assassin (high-speed threat)

## License

MIT
