# Patch Notes

## v0.1.1 (unreleased)

### UI / UX
- Added a dedicated **Objective panel** with kill progress text and a progress bar for clearer combat goals.
- Moved objective tracking out of the dense stats block to improve readability.
- Added a **minimap legend** to clarify icon colors (player, enemies, loot).
- Polished the prototype movement HUD with state-driven progress bar colors (ready vs. active) and stamina severity colors (high/mid/low) for faster glance readability.
- Added darker HUD bar backgrounds and rounded fills to improve legibility against bright 3D scenes.

### Visual Polish
- Added a lightweight `WorldEnvironment` to the prototype 3D scene (procedural sky, ambient light, ACES tonemapping, and SSAO) for better depth and contrast.
- Enabled directional light shadows and added simple material color passes for player, floor, combat dummy, and stamina pickups to improve gameplay readability.

### Starter Level
- Added **Goblin Scout** enemy archetype to early-game encounter pool.
- Updated starter encounter composition so Zone 1 and Zone 2 now spawn goblins at high weight.
- Added goblin-specific ability (`goblin_shiv`) and loot table (`loot_goblin`).
- Updated starter layout encounter IDs to reflect goblin-focused early skirmishes.
- Updated starter level spec roster/stat table to include goblins.
