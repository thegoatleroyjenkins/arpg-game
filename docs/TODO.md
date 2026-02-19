# TODO

## Core Systems Backlog

- [ ] Build a full quest system where NPCs can give players quests.
  - [ ] Quest offer / accept / decline flow from NPC dialogue interaction.
  - [ ] Quest journal UI (active, completed, failed).
  - [ ] Objective tracking + waypoint hooks.
  - [ ] Reward pipeline (XP, gold, items, reputation).
  - [ ] Data-driven quest definitions (JSON/SQL) with versioning.

- [x] Build out a full inventory system.
  - [x] Inventory data model (stacking rules, slot types, capacity) — `systems/inventory/inventory_data.gd` + `inventory_item.gd`
  - [x] Pickup-to-inventory flow with overflow handling — `systems/inventory/pickup_3d.gd/.tscn`
  - [x] Inventory UI grid + drag/drop + equip/unequip integration — `systems/inventory/inventory_ui.gd/.tscn`, `item_slot_ui.gd/.tscn`
  - [x] Item tooltip/stat comparison panel — `systems/inventory/item_tooltip_ui.gd/.tscn`
  - [x] Save/load persistence and schema versioning for inventory data — JSON at `user://inventory.json`
  - [x] Item definitions JSON + LootTable helper — `data/items/item_definitions.json`, `systems/inventory/loot_table.gd`
  - [x] Wired into `open_world_3d.tscn` — `I` key opens, sample pickup spawned near player start

- [ ] Build **The Garden** as a major city hub players can travel to.
  - [ ] Create city scene + district layout (market, quest square, crafting quarter).
  - [ ] Set fast-travel/entry routing from early frontier zones.
  - [ ] Place NPC Gnome as a permanent resident and city guide/quest giver.

- [ ] Build out a full open-world map system.
  - [ ] World map UI with pan/zoom and biome overlays.
  - [ ] Discovery fog + reveal state per chunk/POI.
  - [ ] Player/NPC/quest markers with filtering.
  - [ ] Fast-travel node integration and unlock states.
