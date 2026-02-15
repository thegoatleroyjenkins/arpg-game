# Procedural Asset Pipeline (Phase 1)

This project now includes an **offline procedural asset generator** for rapid, consistent prototype art production.

## Goals

- Generate shippable placeholder assets automatically.
- Keep visuals readable and style-consistent.
- Avoid blocking gameplay iteration on manual modeling.

## Generator Script

- Script: `res://tools/procedural_asset_generator.gd`
- Output root: `res://generated_assets/`

### Generated Asset Categories

- `generated_assets/weapons/`
  - 6 weapon meshes (sword + axe variants)
- `generated_assets/props/`
  - 6 environment props (crates, pillars, rocks)
- `generated_assets/pickups/`
  - 3 pickup orbs (common/uncommon/rare)
- `generated_assets/characters/`
  - 1 player placeholder mesh (`player_knight.tscn`)

## Run

From repository root:

```bash
.tools/godot/Godot_v4.2.1-stable_linux.x86_64 --headless --path . --script res://tools/procedural_asset_generator.gd
```

(Or use your system `godot` binary if available.)

## Implementation Notes

- Uses Godot primitive meshes (`BoxMesh`, `CylinderMesh`, `SphereMesh`, `TorusMesh`).
- Applies rarity-driven material styling (common/uncommon/rare).
- Saves each output as a `.tscn` scene for direct drag/drop usage.
- Intended as **phase-1 automation**: quick generation first, manual polish later.

## Next Phase Ideas

- Collision-shape auto-generation for all assets.
- JSON-driven generator config for designer-authored batches.
- Theme presets (ruins, infernal, arcane, forest).
- Optional random-seed variation mode and batch snapshots.
