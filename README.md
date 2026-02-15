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
- **Enemy Types** — Grunt, Fast, Tank, Ranged (varied stats and behaviors)
- **Smart Behavior** — Enemies detect player, chase when in range, attack when close
- **Visual Feedback** — Alert indicators when enemies spot player

### World
- **Procedural Spawning** — Random enemies and items throughout world
- **Item Drops** — Health potions and XP orbs
- **Equipment Drops** — Weapons, armor, and accessories spawn in world

## Download

Get the latest **Windows build** from [Releases](../../releases).

- Every push to `master` now auto-builds and publishes a GitHub Release artifact (`arpg-windows.zip`).

## Controls

| Key | Action |
|-----|--------|
| WASD / Arrows | Move |
| Space | Attack |
| Shift (in 3D prototype) | Sprint |
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

## License

MIT
